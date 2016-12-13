classdef modulator_2500meg < handle
	properties (Hidden)
		m_carrier;
		m_base_pulse;

		m_i_phases;
		m_q_phases;
		m_mod_signals;
		m_baseband_signals;	
		m_time_res;
		m_low_pass_filter;
	end
	methods
		function th_modulator = modulator_2500meg(carrier,Tc,approp_res)
			th_modulator.m_time_res = approp_res;
			th_modulator.m_carrier = carrier;
			tVec = [0:approp_res:2*Tc];
			base_sig_y = sin(pi*tVec/2/Tc);
			th_modulator.m_base_pulse = signal_continous_time(tVec(1),tVec(end),base_sig_y);
			m_i_phases = [];
			m_q_phases = [];
			m_mod_signals = [];
			th_modulator.initialize;
		end
		function res = get_base_pulse(th_mod)
			res = th_mod.m_base_pulse;
		end
		function res = get_byte_signal_duration(th_mod)
			res = th_mod.get_base_pulse.get_time_duration * 16.5 * 2;
		end
		function energy_avg = get_avg_signal_energy(th_mod)
			for i = 1:length(th_mod.m_mod_signals)
				energy(i) = th_mod.m_mod_signals{i}.measure_avg_energy;
			end
			energy_avg = mean(energy);
		end
		function initialize(th_mod)
			if(length(th_mod.m_i_phases)<16)
				%Design Low Pass Filter
				sampling_freq = 1/th_mod.m_time_res;
				sampling_time = th_mod.m_time_res;
				cut_off_freq_analog = 10e6;
				cut_off_freq_digital = 2 * cut_off_freq_analog / sampling_freq;
				th_mod.m_low_pass_filter = fir1(200,cut_off_freq_digital,'low',kaiser(201,3));
				for symbIndex = 1 : 16
					chip_stream = th_mod.convert_symbol_to_chip(symbIndex - 1);
					[th_mod.m_i_phases{symbIndex},th_mod.m_q_phases{symbIndex}]=th_mod.convert_fullChip_to_signals(chip_stream);
				end
				for symbIndex = 1:16
					th_mod.m_mod_signals{symbIndex} = th_mod.convert_symbIndex_to_mod_signal(symbIndex - 1,0);
					y_vals = filter(th_mod.m_low_pass_filter,1,th_mod.m_carrier.mult_by_carrier_cos(th_mod.m_mod_signals{symbIndex}).get_sample_data);	
					th_mod.m_baseband_signals{symbIndex} = signal_continous_time(th_mod.m_mod_signals{symbIndex}.get_init_time,th_mod.m_mod_signals{symbIndex}.get_end_time,y_vals);
				end
			end
		end
		function [resChipBitStream]=convert_symbol_to_chip(th_modulator,symbolIndex) 
			switch(symbolIndex)
		    		case 0
					chipStream='1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0';    
				case 1        
					chipStream='1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0';    
				case 2        
					chipStream='0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0';    
				case 3        
					chipStream='0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1';    
				case 4        
					chipStream='0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1';    
				case 5        
					chipStream='0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0';    
				case 6        
					chipStream='1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1';    
				case 7        
					chipStream='1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1';    
				case 8        
					chipStream='1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1';    
				case 9        
					chipStream='1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1';    
				case 10        
					chipStream='0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1';    
				case 11        
					chipStream='0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0';    
				case 12        
					chipStream='0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0';    
				case 13        
					chipStream='0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1';    
				case 14        
					chipStream='1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0';    
				case 15        
					chipStream='1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0';    
				otherwise        error('-- table_2400meg_chips: The input value is not valid!');
			end
			resChipBitStream=[];
			for i=1:length(chipStream)
		    		if(~(chipStream(i)==' '))
					resChipBitStream=[resChipBitStream str2num(chipStream(i))];
		    		end
			end	
		end
		function [resSignal]=convert_bitStream_to_signal(th_modulator,bitStream,shift_at)
			base_signal = th_modulator.m_base_pulse;
			bitTimePeriod = get_end_time(base_signal)-get_init_time(base_signal);
			time_res = get_time_res(base_signal);
			totalTimeVec = shift_at+[0:time_res:length(bitStream)*bitTimePeriod];
			resSignal = signal_continous_time(shift_at,shift_at+length(bitStream)*bitTimePeriod,totalTimeVec * 0);
			for i = 1:length(bitStream)
				if(bitStream(i)==1)
					coef=+1;
				else
					coef=-1;
				end
				this_fraction_signal = signal_continous_time(0+shift_at+(i-1)*bitTimePeriod,shift_at+i*bitTimePeriod,get_sample_data(base_signal) * coef);
				resSignal.set_as_part(this_fraction_signal);
			end
			
		end
		function [iphase,qphase]=convert_fullChip_to_signals(th_modulator,bitStream)
			base_signal = th_modulator.m_base_pulse;
			if(length(bitStream)~=32)
				error('Length of chip stream is not 32!');
			end
			evenChipBits=[];
			oddChipBits=[];
			for i=1:32
				if(mod(i-1,2)==0)
					%Even Chip Bit
					evenChipBits = [evenChipBits , bitStream(i)];	
				else
					oddChipBits = [oddChipBits , bitStream(i)];
				end
			end
			iphase = th_modulator.convert_bitStream_to_signal(evenChipBits,0);
			qphase = th_modulator.convert_bitStream_to_signal(oddChipBits,0);
			%Pad and Shift
			iphase.pad_zero_after(base_signal.get_time_duration/2);
			qphase.pad_zero_before(base_signal.get_time_duration/2);
			qphase.shift_signal_in_time(base_signal.get_time_duration / 2);
		end
		function [sig_mod]=convert_signals_to_mod_signal_at_time(th_mod,i_phase,q_phase,time_at)
			sig_values = th_mod.m_carrier.get_carrier_cos(i_phase.get_sample_times ) .* i_phase.get_sample_data;
			sig_values = sig_values + th_mod.m_carrier.get_carrier_sin(q_phase.get_sample_times ) .* q_phase.get_sample_data ;
			sig_mod = signal_continous_time(i_phase.get_init_time+time_at,i_phase.get_end_time+time_at,sig_values);
			%figure,i_phase.plot_this('r'); hold on; q_phase.plot_this('b'); title('Mod');
		end
		function [mod_sig]=convert_symbIndex_to_mod_signal(th_mod,symbIndex,time_at)
			mod_sig = th_mod.convert_signals_to_mod_signal_at_time(th_mod.m_i_phases{symbIndex+1},th_mod.m_q_phases{symbIndex+1},time_at);
		end
		function [mod_signal] = modulate_phy_packet(th_modulator,p,time_at)
			p_copy = p.clone;
			num_4bit_blocks = ceil(getSize(p)/4);
			time_res = get_time_res(th_modulator.m_base_pulse);
			time_init = 0+time_at;
			time_end = time_init + 16.5 * get_time_duration(th_modulator.m_base_pulse) * num_4bit_blocks;
			time_vec_total = [time_init : time_res : time_end];
			mod_signal = signal_continous_time(time_init,time_end,time_vec_total * 0);
			%figure,mod_signal.plot_this('c'); title('pre-mod');
			for index = 1:num_4bit_blocks
				this_4bit_init_time_for_mod_sig = time_init+(index-1)*(16.5*th_modulator.m_base_pulse.get_time_duration );
				this_4bit_block_symbol_index = bi2de((popFromBegin(p_copy,4)));
				this_4bit_block_mod_signal = th_modulator.convert_symbIndex_to_mod_signal(this_4bit_block_symbol_index,this_4bit_init_time_for_mod_sig);
				mod_signal.set_as_part(this_4bit_block_mod_signal);
				%if(index>36)
				%if(time_at > .7e-3)
				%	figure,this_4bit_block_mod_signal.plot_this('g'); title(index);
				%	figure,mod_signal.plot_this('c'); title('partly');
				%end
				%end
			end
			%figure,mod_signal.plot_this('c'); title('post-mod');
		end
		%De-Modulation Functions
		function res_sig = low_pass_filter(th,in_sig)
			vals = filter(th.m_low_pass_filter,1,in_sig.get_sample_data);
			res_sig = signal_continous_time(in_sig.get_init_time,in_sig.get_end_time,vals(201:end));
		end
		function [res_bit,x_corr_pos,x_corr_neg] = correlate_with_base_pulse(th,in_sig)
			xyc_positive = xcorr(in_sig.get_sample_data , th.m_base_pulse.get_sample_data);
			xyc_negative = xcorr(in_sig.get_sample_data , -th.m_base_pulse.get_sample_data);
			x_corr_pos = max(xyc_positive);
			x_corr_neg = max(xyc_negative);
			if(x_corr_pos > x_corr_neg)
				res_bit = 1;
			else
				res_bit = 0;
			end
		end

		function [res_binary,res_index] = find_best_symbol_ver3(th,signal_sample,time_at)
			cos_sig_filtered = th.low_pass_filter(th.m_carrier.mult_by_carrier_cos(signal_sample));
			sin_sig_filtered = th.low_pass_filter(th.m_carrier.mult_by_carrier_sin(signal_sample));
		%	figure,cos_sig_filtered.plot_this('r'); hold on; sin_sig_filtered.plot_this('b');
			for symb_index = 1:16
				xyc = xcorr(cos_sig_filtered.get_sample_data , th.m_i_phases{symb_index}.get_sample_data);
				val_i(symb_index) = max(xyc);
				xyc = xcorr(sin_sig_filtered.get_sample_data , th.m_q_phases{symb_index}.get_sample_data);
				val_q(symb_index) = max(xyc);
			end
			val = val_i.^2 + val_q.^2;
			[max1,max_i] = max(val_i);
			[max2,max_q] = max(val_q);
			[max3,max_iq] = max(val);
			res_index = max_iq - 1;
			res_binary = de2bi(res_index,4);	
		end
		function [res_binary,res_index] = find_best_symbol_ver2(th,signal_sample,time_at)
			cos_sig_filtered = th.low_pass_filter(th.m_carrier.mult_by_carrier_cos(signal_sample));
			sin_sig_filtered = th.low_pass_filter(th.m_carrier.mult_by_carrier_sin(signal_sample));
			%Decode Bits
			init_time = cos_sig_filtered.get_init_time;
			end_time = cos_sig_filtered.get_end_time;
			bit_signal_len = th.m_base_pulse.get_time_duration;
			for bit_index = 0:15
				i_phase_init = init_time + bit_index * bit_signal_len;
				i_phase_end = i_phase_init + bit_signal_len;
				q_phase_init = init_time + bit_index * bit_signal_len + bit_signal_len / 2;
				q_phase_end = q_phase_init + bit_signal_len;
				i_phase_signal = cos_sig_filtered.get_sample_data_partially(i_phase_init,i_phase_end);	
				q_phase_signal = sin_sig_filtered.get_sample_data_partially(q_phase_init,q_phase_end);	
				[i_res_bit,i_res_pos(bit_index+1),i_res_neg(bit_index+1)] = th.correlate_with_base_pulse(i_phase_signal);	
				[q_res_bit,q_res_pos(bit_index+1),q_res_neg(bit_index+1)] = th.correlate_with_base_pulse(q_phase_signal);	
			end
			for symb_index = 1:16
				hamming_distance(symb_index) = sum(abs(chip_string - th.convert_symbol_to_chip(symb_index-1)));
				euc_dist(symb_index) = sum();
			end
			[min1,min2] = min(hamming_distance);
			res_index = min2-1;
			res_binary = de2bi(res_index,4);
		end
		function [resBinary,resIndx]=find_best_symbol_ver6(th_mod,signal_sample)
			time_at = signal_sample.get_init_time;
			for symbIndex = 1:16
				this_mod_sig = th_mod.convert_symbIndex_to_mod_signal(symbIndex - 1,time_at);
				%this_mod_sig = th_mod.m_mod_signals{symbIndex};
				xyc = xcorr(this_mod_sig.get_sample_data , signal_sample.get_sample_data) / norm(this_mod_sig.get_sample_data,2);
				x_corr_value(symbIndex) = max(xyc);
			end
			[max1,max2]=max(x_corr_value);
			resIndx = (max2)-1;
			resBinary = de2bi(resIndx,4);
		end
		function [resBinary,resIndx]=find_best_symbol_ver5(th_mod,signal_sample)
			time_at = signal_sample.get_init_time;
			cntr = 0;
			for symbIndex = 1:16
				this_mod_sig = th_mod.convert_symbIndex_to_mod_signal(symbIndex - 1,time_at);
				%this_mod_sig = th_mod.m_mod_signals{symbIndex};
				s_s = signal_sample.get_sample_data;
				if(signal_sample.get_num_samples > this_mod_sig.get_num_samples)
					s_s = s_s(1:this_mod_sig.get_num_samples);
				elseif(signal_sample.get_num_samples < this_mod_sig.get_num_samples)
					s_s(end+1:this_mod_sig.get_num_samples) = s_s(end);
				end
				mv_len = 10;
				this_moved = zeros(1,length(s_s) + 2*mv_len);
				this_moved(mv_len+1:mv_len+length(s_s)) = this_mod_sig.get_sample_data;
				for t_ = 1:mv_len*2
					cntr = cntr + 1;
					symm(cntr) = symbIndex;
					s_s_moved = zeros(1,length(s_s) + 2*mv_len);
					s_s_moved(t_:t_+length(s_s)-1) = s_s;
					x_corr_value(cntr) = sum(s_s_moved .* this_moved) / sqrt(sum(s_s_moved.^2) * sum(this_moved.^2));
					shift_val(cntr) = t_;
				end
			end
			[max1,max2]=max(x_corr_value);
			resIndx = symm(max2)-1;
			resBinary = de2bi(resIndx,4);
		end
		function [resBinary,resIndx]=find_best_symbol(th_mod,signal_sample,time_at)
			for symbIndex = 1:16
				xyc = xcorr(signal_sample.get_sample_data , th_mod.m_mod_signals{symbIndex}.get_sample_data  );
				x_corr_value(symbIndex) = max(xyc);
			end
			[max1,max2]=max(x_corr_value);
			resIndx = max2-1;
			resBinary = de2bi(resIndx,4);
		end
		function [p]=demodulate_signal_to_phy_packet(th_mod,signal)
			timee = th_mod.get_base_pulse.get_time_duration * 16.5;
			if(mod(signal.get_time_duration,timee)==0)
				%error('Length of the signal does not match with the base pulse period!');
			end
			num_4bit_blocks = round(signal.get_time_duration / timee);
			p = packet_general();
			for index_4bit_block = 1:num_4bit_blocks
				time_at=signal.get_init_time;
				time_1 = time_at + (index_4bit_block-1)*timee;
				time_2 = time_at + (index_4bit_block)*timee;
				[partial_signal] = signal.get_sample_data_partially(time_1,time_2);
				%resBinary = th_mod.find_best_symbol(partial_signal,time_at);
				resBinary = th_mod.find_best_symbol_ver6(partial_signal);
				p.addToEnd(resBinary);
			end
		end
	end
end


