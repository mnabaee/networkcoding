classdef channel_holder < handle
	properties (Hidden)
		m_channel;
		m_sensor_depl;
		m_freqs;
		m_time_res;
		m_end_time;
		m_init_time = 0;
		m_time_unit;
		m_rx_signals;
		m_pairwise_attenuations;

		m_released_time_before;
		m_bit_offset;
		m_decoded_binary_stream;
		m_modulators;

		m_used_rx_freqs;
		m_total_tx_energy;
	end
	methods
		function th = channel_holder(channel,sensor_depl)
			th.m_channel = channel;
			th.m_sensor_depl = sensor_depl;
			for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				th.m_used_rx_freqs {node} = [];
			end
		end
		function res = get_noise_level(th)
			res = th.m_channel.get_params.m_noise_level;
		end
		function release_all_memories(th)
			th.p_release_all_memories;
		end
		function release_all_memories_v2(th,time)
			th.p_release_all_memories_v2(time);
		end
		function res = get_total_tx_energy(th)
			res = th.m_total_tx_energy;
		end
		function flag = add_rx_freq(th,rx_node,freq)
			flag = false;
			freq_index = find(th.m_freqs == freq);
			if(isempty(freq_index))
				return;
			end
			node_index = find([1:th.m_sensor_depl.get_params.m_number_of_nodes]==rx_node);
			if(isempty(node_index))
				return;
			end
			th.m_used_rx_freqs{rx_node} = [th.m_used_rx_freqs{rx_node} , freq];
		end
		function initialize_freq_time_params(th,freqs,time_res,end_time)
			th.set_freq_time_params(freqs,time_res,end_time);
			th.initialize;
		end
		function set_time_unit(th,value)
			th.m_time_unit = value;
		end
		function set_modulators(th,mod_s)
			for i = 1:length(mod_s)
				th.m_modulators{i} = mod_s{i};
			end
		end
		function set_freqs(th,freqs)
			th.m_freqs = freqs;
		end
		function set_time_params(th,time_res,end_time)
			th.m_time_res = time_res;
			th.m_end_time = end_time;
		end
		function set_freq_time_params(th,freqs,time_res,end_time)
			th.m_freqs = freqs;
			th.m_time_res = time_res;
			th.m_end_time = end_time;
		end
		function res = get_params(th)
			res.m_freqs = th.m_freqs;
			res.m_time_res = th.m_time_res;
			res.m_end_time = th.m_end_time;
		end
		function flag = release_bits_before(th,rx_node,rx_freq,index)
			flag = th.p_release_bits_before(rx_node,rx_freq,index);
		end
		function flag = propagate_tx_signal(th,in_sig,tx_node,tx_freq)
			flag = th.p_propagate_tx_signal(in_sig,tx_node,tx_freq);
		end
		function [binary_string,flag,meas_sig] = read_binary_string(th,rx_node,rx_freq,bit_index_from,time_to,time_from);
			[binary_string,flag,meas_sig] = th.p_read_binary_string(rx_node,rx_freq,bit_index_from,time_to,time_from);
		end
		function [meas_sig,flag] = measure_rx_signal_at(th,rx_node,rx_freq,t1,t2);
			[meas_sig,flag] = th.p_measure_rx_signal_at(rx_node,rx_freq,t1,t2);
		end
		function [energy_avg,flag] = measure_energy(th,rx_node,rx_freq,t,time_window)
			energy_avg = 0;
			flag = 1;
			[f1] = find(th.m_freqs == rx_freq);
			if(isempty(f1))
				flag = -1;
				return;
			end
			f2 = find(rx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(f2))
				flag = -1;
				return;
			end
			energy_avg = th.m_rx_signals{f2,f1}.measure_avg_energy(t,time_window);
		end
		function initialize(th)
			bulk_signal = signal_continous_time(th.m_init_time,th.m_end_time,[th.m_init_time:th.m_time_res:th.m_end_time]*0);
			for node = 1 : th.m_sensor_depl.get_params.m_number_of_nodes
				for freqIndex = 1:length(th.m_freqs)
					th.m_rx_signals{node,freqIndex} = th.m_channel.add_by_noise(bulk_signal);
					th.m_released_time_before(node,freqIndex) = th.m_init_time;
					th.m_decoded_binary_stream{node,freqIndex} = [];
					th.m_bit_offset(node,freqIndex) = 0;
				end
			end
			for node_tx = 1 : th.m_sensor_depl.get_params.m_number_of_nodes
				for node_rx = 1: th.m_sensor_depl.get_params.m_number_of_nodes
					if(node_tx ~= node_rx)
						th.m_pairwise_attenuations(node_tx,node_rx) = th.m_channel.simulate_attenuation_in_dB(th.m_sensor_depl.get_params.m_node_distances(node_tx,node_rx),1);
					end
				end
			end
			th.m_total_tx_energy = 0;
		end
	end
	methods (Hidden)
		function flag = p_propagate_tx_signal(th,in_sig,tx_node,tx_freq)
			flag = false;
			[f1] = find(th.m_freqs == tx_freq);
			if(isempty(f1))
				return;
			end
			f2 = find(tx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(f2))
				return;
			end
			freq_index = f1;
			tx_node_index = f2;
			mod_sig_power = th.m_modulators{f1}.get_avg_signal_energy;
			th.m_total_tx_energy = th.m_total_tx_energy + in_sig.get_energy;
			for rx_node =1:th.m_sensor_depl.get_params.m_number_of_nodes
			%	if(~isempty(th.m_sensor_depl.find_edge(rx_node,tx_node)))
				if(~isempty(find(th.m_used_rx_freqs{rx_node}==tx_freq)))
					if(rx_node ~= tx_node)
						t1 = th.m_rx_signals{rx_node,freq_index}.get_init_time;
						t2 = th.m_rx_signals{rx_node,freq_index}.get_end_time;
						t3 = in_sig.get_end_time;
						if(t3 > t2)
							th.m_rx_signals{rx_node,freq_index}.pad_zero_after(t3-t2);
							noise_sig = th.m_rx_signals{rx_node,freq_index}.get_sample_data_partially(t2,t3);
							noise_sig = th.m_channel.add_by_noise(noise_sig);
							th.m_rx_signals{rx_node,freq_index}.set_as_part(noise_sig);
						end
						coef =  10^((th.m_sensor_depl.get_tx_power - th.m_pairwise_attenuations(tx_node,rx_node)) / 10 ) * (10^(-3)) / mod_sig_power;
						th.m_rx_signals{rx_node,freq_index} = th.m_rx_signals{rx_node,freq_index}.mult_and_add(in_sig,sqrt(coef));
					end
				end
			%	end
			end
			flag = true;
		end
		function flag = p_release_bits_before(th,rx_node,rx_freq,index)
			flag = false;
			[f1] = find(th.m_freqs == rx_freq);
			if(isempty(f1))
				return;
			end
			f2 = find(rx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(f2))
				return;
			end
			freq_index = f1;
			node_index = f2;
			if((index <= th.m_bit_offset(node_index,freq_index))||(index > length(th.m_decoded_binary_stream{node_index,freq_index}) + th.m_bit_offset(node_index,freq_index) ))
				return;
			end
			th.m_decoded_binary_stream{node_index,freq_index}(1:index - th.m_bit_offset(node_index,freq_index) - 1) = [];
			th.m_bit_offset(node_index,freq_index) = index - 1;
			flag = true;
		end
		function [binary_string,flag,meas_sig] = p_read_binary_string(th,rx_node,rx_freq,bit_index_from,time_to,time_from);
			flag = false;
			binary_string = [];
			[f1] = find(th.m_freqs == rx_freq);
			if(isempty(f1))
				disp('node error!');
				return;
			end
			f2 = find(rx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(f2))
				disp('freq error!');
				return;
			end
			freq_index = f1;
			node_index = f2;
			[decoding_flag,meas_sig] = th.p_measure_and_decode_signal_to_symbols(rx_node,rx_freq,time_to,time_from);
			if((bit_index_from - th.m_bit_offset(node_index,freq_index) < 1) || (bit_index_from-th.m_bit_offset(node_index,freq_index) > length(th.m_decoded_binary_stream{node_index,freq_index})))
				%disp('bit indexing error!');
				return;
			end
			binary_string = th.m_decoded_binary_stream{node_index,freq_index}(bit_index_from - th.m_bit_offset(node_index,freq_index):end);		
			flag = true;
		end
		function [flag,meas_sig] = p_measure_and_decode_signal_to_symbols(th,rx_node,rx_freq,time_to,time_from)
			flag = false;
			meas_sig = [];		
			[freq_index] = find(th.m_freqs == rx_freq);
			if(isempty(freq_index))
				return;
			end
			node_index = find(rx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(node_index))
				return;
			end
			if(nargin == 4)
				time_from = th.m_released_time_before(node_index,freq_index);
				time_from = max(time_from , th.m_rx_signals{node_index,freq_index}.get_init_time);
			end
			if(time_from == -1)
				time_from = th.m_released_time_before(node_index,freq_index);
				time_from = max(time_from , th.m_rx_signals{node_index,freq_index}.get_init_time);
			end
			time_to = time_to;
			meas_sig = th.m_rx_signals{node_index,freq_index}.get_sample_data_partially(time_from,time_to);
			decoded_4bits = th.m_modulators{freq_index}.demodulate_signal_to_phy_packet(meas_sig);
			if(mod(decoded_4bits.getSize,4) ~= 0 )
				decoded_4bits.print_this;
				error('4bits!');
			end
			th.m_decoded_binary_stream{node_index,freq_index} = [th.m_decoded_binary_stream{node_index,freq_index} , decoded_4bits.get_all];
			th.m_released_time_before(node_index,freq_index) = time_to;
			flag = true;
		end
		function p_release_rx_memory(th,rx_node,rx_freq)
			freq_index = find(th.m_freqs == rx_freq);
			if(isempty(freq_index))
				error('CHANNEL_HOLDER: wrong freq!');
			end
			time_0 = th.m_released_time_before(rx_node,freq_index) - th.m_time_unit * 50;
			time_00 = max(th.m_rx_signals{rx_node,freq_index}.get_init_time , time_0);
			th.m_rx_signals{rx_node,freq_index} = th.m_rx_signals{rx_node,freq_index}.get_sample_data_partially(time_00,th.m_rx_signals{rx_node,freq_index}.get_end_time);
		end
		function p_release_all_memories_v2(th,time)
			old_samples = 0;
			new_samples = 0;
			time_0 = time - th.m_time_unit * 5;
			time_1 = time;
			for i1 = 1:size(th.m_rx_signals,1)
				for i2 = 1:size(th.m_rx_signals,2)
					m_init_time = th.m_rx_signals{i1,i2}.get_init_time;
					m_end_time = th.m_rx_signals{i1,i2}.get_end_time;
					m_time_res = th.m_rx_signals{i1,i2}.get_time_res;
					old_samples = old_samples + th.m_rx_signals{i1,i2}.get_num_samples;		
					if(m_end_time < time_0)
						th.m_rx_signals{i1,i2} = signal_continous_time(time_0,time_1,[time_0:m_time_res:time_1]*0);
					else
						th.m_rx_signals{i1,i2} = th.m_rx_signals{i1,i2}.get_sample_data_partially(max(m_init_time,time_0),m_end_time);
					end
					new_samples = new_samples + th.m_rx_signals{i1,i2}.get_num_samples;
				end
			end
%			disp([' OOO released memory... OOO with ' num2str(old_samples) ' old samples and ' num2str(new_samples) ' new samples, RELEASED_PORTION: ' num2str((old_samples -new_samples)/(old_samples))]);
		end
		function p_release_all_memories_v2_(th,time)
			%disp([' OOO releasing memory... OOO ']);
			old_samples = 0;
			new_samples = 0;
			for i1 = 1:size(th.m_rx_signals,1)
				for i2 = 1:size(th.m_rx_signals,2)
					time_0 = time - th.m_time_unit * 10;
					time_00 = max(th.m_rx_signals{i1,i2}.get_init_time , time_0);
					t_end = th.m_rx_signals{i1,i2}.get_end_time;
					old_samples = old_samples + th.m_rx_signals{i1,i2}.get_num_samples;		
			%		disp(['time_00=' num2str(time_00) ',t_end=' num2str(t_end)]);
					if(time_00 < t_end)
						th.m_rx_signals{i1,i2} = th.m_rx_signals{i1,i2}.get_sample_data_partially(time_00,t_end);
					end
					new_samples = new_samples + th.m_rx_signals{i1,i2}.get_num_samples;
				end
			end
			disp([' OOO released memory... OOO with ' num2str(old_samples) ' old samples and ' num2str(new_samples) ' new samples, RELEASED_PORTION: ' num2str((old_samples -new_samples)/(old_samples))]);
		end
		function p_release_all_memories(th)
			for i1 = 1:size(th.m_rx_signals,1)
				for i2 = 1:size(th.m_rx_signals,2)
					m_init_time = th.m_rx_signals{i1,i2}.get_init_time;
					m_end_time = th.m_rx_signals{i1,i2}.get_end_time;	
					m_time_res = th.m_rx_signals{i1,i2}.get_time_res;
					time_0 = th.m_released_time_before(i1,i2) - th.m_time_unit * 5;
					if(m_end_time < time_0)
%						th.m_rx_signals{i1,i2} = signal_continous_time();
					else

					end

					time_0 = th.m_released_time_before(i1,i2) - th.m_time_unit * 5;
					time_00 = max(th.m_rx_signals{i1,i2}.get_init_time , time_0);
					t_end = th.m_rx_signals{i1,i2}.get_end_time;
					if(time_00 < t_end)
						
					end
					th.m_rx_signals{i1,i2} = th.m_rx_signals{i1,i2}.get_sample_data_partially(time_00,th.m_rx_signals{i1,i2}.get_end_time);
				end
			end
		end
		function [meas_sig,flag] = p_measure_rx_signal_at(th,rx_node,rx_freq,t1,t2)
			meas_sig = [];
			flag = 1;
			[f1] = find(th.m_freqs == rx_freq);
			if(isempty(f1))
				flag = -1;
				return;
			end
			f2 = find(rx_node == [1:th.m_sensor_depl.get_params.m_number_of_nodes]);
			if(isempty(f2))
				flag = -1;
				return;
			end
			meas_sig = th.m_rx_signals{f2,f1}.get_sample_data_partially(t1,t2).clone;
		end
		function clear_all(th)
			th.m_rx_signals = [];
		end
	end
end
