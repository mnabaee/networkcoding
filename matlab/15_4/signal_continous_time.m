classdef signal_continous_time < handle
	properties (Hidden)
		mInitTime;
		mEndTime;
		mSamplingRes;
		mNumSamples;
		mSampleData;
		mSampleTimes;
	end
	methods
		function [signal]=signal_continous_time(initTime,endTime,sampleData)
			if(initTime >= endTime)
				error('Init and End Times can not be the same!');
			end
			numSamples = length(sampleData);
			if(numSamples<=0)
				error('Number of Samples have to be positive!');
			end
			signal.mInitTime = initTime;
			signal.mEndTime = endTime;
			signal.mNumSamples = numSamples;
			signal.mSampleTimes = linspace(initTime,endTime,numSamples);
			signal.mSamplingRes = signal.mSampleTimes(2)-signal.mSampleTimes(1);
			signal.mSampleData = sampleData;
		end
		function res = clone(th_sig)
			res = signal_continous_time(th_sig.mInitTime,th_sig.mEndTime,th_sig.mSampleData);
		end
		function energy_avg = measure_avg_energy(th_sig,time_at,time_window)
			if(nargin == 1)
				t1 = th_sig.get_init_time;
				t2 = th_sig.get_end_time;
				energy_avg = mean(th_sig.get_sample_data .^ 2);
				return;
			elseif(nargin == 3)
				if(th_sig.get_end_time < time_at - time_window)
					energy_avg = 0;
					return;
				end
				t1 = max(time_at-time_window,th_sig.get_init_time);
				t2 = time_at;
				if(t1==t2)
					energy_avg = th_sig.read_values(t1) ^ 2 ;
					return;
				end
				[sig,data] = th_sig.get_sample_data_partially(t1,t2);
				energy_avg = mean(data.^2);
				return;
			else
				error('Number of Input Arguments is not Appropriate!');
			end
		end
		function energy = get_energy(th_sig)
			energy = sum(th_sig.get_sample_data .^ 2) * (th_sig.get_time_res);
		end
		function set_all_data(signal,inData)
			if(length(inData)<2)
				error('Number of sample points are not enough!');
			end	
			signal.mSampleData = inData;
			signal.mNumSamples = length(inData);
			signal.mSamplingRes = (signal.mEndTime-signal.mInitTime)/signal.mNumSamples;
			signal.mSampleTimes = linspace(signal.mInitTime,signal.mEndTime,signal.mNumSamples);
		end
		function shift_signal_in_time(signal,timeShift)
			signal.mInitTime = signal.mInitTime + timeShift;
			signal.mEndTime = signal.mEndTime + timeShift;
			signal.mSampleTimes = signal.mSampleTimes + timeShift;
		end
		function [left_index,right_index,new_data_s] = set_as_part(th,in_sig)
			if(th.get_init_time > in_sig.get_init_time)
				%th.pad_zero_before(th.get_init_time - in_sig.get_init_time);
			end
			if(th.get_end_time < in_sig.get_end_time)
				%th.pad_zero_after(in_sig.get_end_time - th.get_end_time);
			end
			[left_index,right_index,new_data_s] = th.set_as_part_(in_sig);
			return;
		end
		function [left_index,right_index,new_data_s] = set_as_part_(signal,inSignal)
			if((inSignal.mInitTime < signal.mInitTime)||(inSignal.mEndTime > signal.mEndTime))
			%	error('Inner signal limits are outside the limits of Signal!');
			end
			[fInit,fInitTimeIndex] = min(abs(signal.mSampleTimes - inSignal.mSampleTimes(1)));
			if(signal.mSampleTimes(fInitTimeIndex) < inSignal.mSampleTimes(1))
				fInitTimeIndex = fInitTimeIndex +1;
			end
			[fEnd,fEndTimeIndex] = min(abs(signal.mSampleTimes - inSignal.mSampleTimes(end)));
			if(signal.mSampleTimes(fEndTimeIndex) > inSignal.mSampleTimes(end))
				fEndTimeIndex = fEndTimeIndex - 1;
			end
			innerTimesVec = signal.mSampleTimes(fInitTimeIndex:fEndTimeIndex);
			index_len = fEndTimeIndex - fInitTimeIndex + 1;
			index_len = min(index_len , length(inSignal.mSampleData));
			%signal.mSampleData(fInitTimeIndex:fEndTimeIndex) = inSignal.mSampleData(1:index_len);
			%new_data_s = interp1(inSignal.mSampleTimes,inSignal.mSampleData,innerTimesVec,'nearest');
			new_data_s = inSignal.mSampleData(1:index_len);
			signal.mSampleData(fInitTimeIndex:fInitTimeIndex + index_len - 1) = new_data_s;
			left_index = fInitTimeIndex;
			right_index = fEndTimeIndex;
		end
		%function set_as_part_at_time(signal,inSignal,atTime)
		%	shiftedInSignal = inSignal;
		%	shift_signal_in_time(shiftedInSignal,atTime - inSignal.mInitTime);
		%	set_as_part(signal,shiftedInSignal);
		%end
		function pad_zero_after(signal,extraTimeLength)
			if(extraTimeLength <=0 )
				error('Time length should be positive!');
			end
			
			new_time_vec = [signal.mInitTime:signal.mSamplingRes:signal.mEndTime + extraTimeLength];
			new_sig = signal_continous_time(signal.get_init_time,signal.get_end_time + extraTimeLength,new_time_vec * 0);
			new_sig.set_as_part(signal);
			signal.mSampleData = new_sig.get_sample_data;
			signal.mSampleTimes = new_sig.get_sample_times;
			signal.mEndTime = new_sig.get_end_time;
			signal.mNumSamples = length(new_time_vec);
			%disp(['new sig end3:' num2str(signal.get_end_time)]);


			%padTimeVec = [signal.mEndTime:signal.mSamplingRes:signal.mEndTime+extraTimeLength];
			%signal.mSampleTimes = [signal.mSampleTimes padTimeVec(2:end)];
			%signal.mSampleData = [signal.mSampleData padTimeVec(2:end)*0];
			%signal.mNumSamples = length(signal.mSampleTimes);
			%signal.mEndTime = padTimeVec(end);
		end
		function pad_zero_before(signal,extraTimeLength)
			if(extraTimeLength <=0 )
				error('Time length should be positive!');
			end
			new_time_vec = [signal.mInitTime - extraTimeLength:signal.mSamplingRes:signal.mEndTime];
			new_data_vec = new_time_vec * 0;
			new_data_vec(end-signal.get_num_samples+1:end) = signal.mSampleData;
			signal.mSampleData = new_data_vec;
			signal.mSampleTimes = new_time_vec;
			signal.mInitTime = signal.mInitTime - extraTimeLength;
			signal.mNumSamples = length(new_time_vec);

			return;
			padTimeVec = [signal.mInitTime - extraTimeLength:signal.mSamplingRes:signal.mInitTime];
			signal.mSampleTimes = [padTimeVec(1:end-1) signal.mSampleTimes];
			signal.mSampleData = [padTimeVec(1:end-1)*0 signal.mSampleData];
			signal.mNumSamples = length(signal.mSampleTimes);
			signal.mInitTime = padTimeVec(1);
		end
		function [readVals]=read_values(signal,timesVec)
			readVals = interp1(signal.mSampleTimes,signal.mSampleData,timesVec);
		end
		function [out_sample_times]=get_sample_times(signal)
			out_sample_times = signal.mSampleTimes;
		end
		function [out_sample_data]=get_sample_data(signal)
			out_sample_data = signal.mSampleData;
		end
		function [partial_signal,sample_data,sample_times]=get_sample_data_partially(signal,time_from,time_to)
			if((signal.mInitTime > time_from)||(signal.mEndTime < time_to))
			%	disp(signal.mInitTime)
			%	disp(signal.mEndTime)
			%	disp(time_from)
			%	disp(time_to)
			%	error('Signal limits are violated!');
			end
			[fInit,fInitTimeIndex] = min(abs(signal.mSampleTimes - time_from));
			[fEnd,fEndTimeIndex] = min(abs(signal.mSampleTimes - time_to));
			sample_times = signal.mSampleTimes(fInitTimeIndex:fEndTimeIndex);
			sample_data = signal.mSampleData(fInitTimeIndex:fEndTimeIndex);
			if(fInitTimeIndex == fEndTimeIndex)
				sample_times = [sample_times(1) , sample_times(1) + signal.get_time_res];
				sample_data = [sample_data(1) sample_data(1)];
			end
			partial_signal = signal_continous_time(sample_times(1),sample_times(end),sample_data);
			%partial_signal = signal_continous_time(time_from,time_to,sample_data);
		end
		function res_sig = mult(th_sig,mult_coef)
			res_sig = signal_continous_time(th_sig.get_init_time,th_sig.get_end_time,th_sig.get_sample_data * mult_coef);
		end
		function res_sig = mult_and_add_(th,mult_sig,mult_coef)
			res_sig = th.clone;
			buff_sig = th.clone;
			[left_index,right_index] = buff_sig.set_as_part(mult_sig);
			res_sig.mSampleData(left_index:right_index) = res_sig.mSampleData(left_index:right_index) + buff_sig.mSampleData(left_index:right_index) * mult_coef;
		end
		function res_sig = mult_and_add(th_sig,multed_sig,mult_coef)
			t1 = min(th_sig.get_init_time,multed_sig.get_init_time);
			t2 = max(th_sig.get_end_time,multed_sig.get_end_time);
			tRes = th_sig.get_time_res;
			res_sig = signal_continous_time(t1,t2,[t1:tRes:t2]*0);
			res_sig.set_as_part(th_sig);
			buff_sig = res_sig.clone;
			buff_sig.set_as_part(multed_sig);
			res_sig.set_all_data(res_sig.get_sample_data + mult_coef * buff_sig.get_sample_data);
			clear buff_sig;	
			return;
		end
		function res=get_init_time(signal)
			res = signal.mInitTime;
		end
		function res=get_end_time(signal)
			res = signal.mEndTime;
		end
		function res = get_time_duration(signal);
			res = signal.mEndTime - signal.mInitTime;
		end
		function res=get_time_res(signal)
			res = signal.mSamplingRes;
		end
		function res = get_num_samples(signal)
			res = signal.mNumSamples;
		end
		function print_this(signal)
			disp([' Init Time:' num2str(signal.mInitTime) ' End Time:' num2str(signal.mEndTime) '\n']);
			disp([' Sample Times: ' num2str(signal.mSampleTimes)]);
			disp([' Sample Data: ' num2str(signal.mSampleData)]);
		end
		function plot_this(signal,plotStr)
			plot(signal.mSampleTimes,signal.mSampleData,plotStr);
		end
	end
end


