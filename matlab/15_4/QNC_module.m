classdef QNC_module < handle
	properties (Hidden)
		m_write_log;
		m_carriers;
		m_modulators;
		m_phys;
		m_tx_macs;
		m_rx_macs;
		m_channel_holder;
		m_sensor_depl;
		m_q;
		m_packet_len;
		m_values_range;
		m_freqs_array;
		m_tx_freq;
		m_tx_time_slot;
		m_tx_freq_time;
		m_rx_freq_time;
		m_rx_freqs;
		m_rx_time_slots;
		m_node_prev_coordinators;
		m_RX_index;
		m_timer;
		m_timer_index;
		m_time_unit;
		m_it_index;
		m_node_state;
		m_BEACON_TO_BEACON_DELAY;
		m_SUPERFRAME_SIGNAL_TIME;
		m_BEACON_SIGNAL_TIME;
		m_DATA_FRAME_SIGNAL_TIME;
		m_IT_TO_IT_DELAY;
		m_num_time_sharing_slots;
		m_MAX_NUM_RXERS;
		m_MAX_NUM_RXERS_t_s;

		m_buffers;
		m_buffers_real_values;
		m_messages;
		m_decoded_messages;
		m_results;
		m_results_final;
		m_decoded_messages_final;		

		m_gateway_buffer_real_values;
		m_A_matrix;
		m_F_matrix;
		m_B_matrix;
		m_Psi;
		m_Psi_tot;
		m_eps_coef;
		m_F_prod;
		m_z_tot;

		m_log_file_name;
		m_save_file_name;

		m_txs;
		m_packet_drops;
	end
	methods
		function th = QNC_module(sensor_depl,packet_len,message_range,log_file_name)
			th.m_sensor_depl = sensor_depl;
			th.m_packet_len = packet_len;
			th.m_values_range = message_range;
			th.m_log_file_name = log_file_name;
			th.m_channel_holder = th.m_sensor_depl.get_params.m_channel_holder;
			th.initialize;
		end
		function enable_write_log(th)
			th.m_write_log = true;
		end
		function disable_write_log(th)
			th.m_write_log = false;
		end
		function initialize_simulation(th,message)
			th.p_simulation_initialize(message);
		end
		function perform_QNC_times(th,n_times)
			t_index = 0;
			while(true)
				th.perform_QNC;
				t_index = t_index + 1;
				if(t_index >= n_times)
					break;
				end	
				if(t_index > 2)
					if(th.m_results_final{t_index}.decoding_snr - th.m_results_final{t_index-1}.decoding_snr < -10)
						break;
					end
					for ind=2:length(th.m_results_final)
						res_snr(ind-1) = th.m_results_final{ind}.decoding_snr;
					end
					cntr = 0;
					for ind = length(res_snr) : -1 : 1
						if(res_snr(ind) == res_snr(end))
							cntr = cntr + 1;
						end
					end
					if(cntr >= 4)
					%	break;
					end					
				end
			end
		end
		function res = get_results(th,plot_str)
			res = th.m_results_final;
			if(nargin==2)
				for t=1:length(th.m_results_final)
					delay_snr_curve.x_values(t) = th.m_results_final{t}.delay * 1000;
					delay_snr_curve.y_values(t) = th.m_results_final{t}.decoding_snr;
				end
				plot(delay_snr_curve.x_values,delay_snr_curve.y_values,plot_str);
				xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on;
			end
		end
	end
	methods (Hidden)
		function initialize(th)
			th.m_q = uniform_quantizer(th.m_values_range,th.m_packet_len);
		end
		function p_simulation_initialize(th,message)
			num_nodes = th.m_sensor_depl.get_params.m_number_of_nodes;
			th.write_log([' - Setting Up CVX...']);
			addpath(genpath('cvx'));
			cvx_setup;
			th.m_txs = 0;
			th.m_packet_drops = 0;
			th.m_messages = message;
			th.m_timer = 0;
			th.m_timer_index = 1;
			th.m_it_index = 1;
			th.m_decoded_messages_final = zeros(num_nodes,1);
			for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				incoming_nodes = th.m_sensor_depl.get_incoming_nodes(node);
				for i = 1:length(incoming_nodes)
					th.m_buffers{node,i} = th.m_q.quantize_and_convert_to_binary(0);
					th.m_buffers_real_values(node,i) = 0;
				end
			end
			%Initialize Pairs for NC and Find maximum number of subscribers
			%Initialize Modulators, PHYs, and MACs
			[num_freqs,freqs_array,num_time_sharing_slots] = th.m_sensor_depl.set_tx_freqs_for_QNC;
			th.m_freqs_array = freqs_array;
			th.m_channel_holder.set_freqs(freqs_array);
			for f_ind = 1:num_freqs
				th.m_carriers{f_ind} = carrier_signal(freqs_array(f_ind) * 1e6 ,0);
				t_c = 1/(2e+6);
				th.m_modulators{f_ind} = modulator_2500meg(th.m_carriers{f_ind},t_c,th.m_channel_holder.get_params.m_time_res);
				th.m_phys{f_ind} = phy_module(th.m_modulators{f_ind});
			end
			th.m_channel_holder.set_modulators(th.m_modulators);
			max_num_rxers = 0;
			for tx_node = 1:num_nodes
				max_num_rxers = max(max_num_rxers , length(th.m_sensor_depl.get_dn_rx_nodes(tx_node)));
				mac_address = th.m_sensor_depl.get_address(tx_node);
				pan_id = mac_address;
				tx_freq = th.m_sensor_depl.get_params.m_tx_freqs{tx_node}.m_tx_freq;
				fi = find(freqs_array == tx_freq);
				th.m_tx_macs{tx_node} = mac_module(mac_address,pan_id,th.m_phys{fi});
				th.m_tx_freq_time{tx_node}(1,1) = tx_freq;
				th.m_tx_freq_time{tx_node}(1,2) = th.m_sensor_depl.get_params.m_tx_freqs{tx_node}.m_tx_time;
			end
			th.m_MAX_NUM_RXERS = max_num_rxers;
			for t_s_index = 1:num_time_sharing_slots
				max_num_rxers_t_s(t_s_index) = 0;
				for tx_node = 1:num_nodes
					if(th.m_tx_freq_time{tx_node}(1,2) == t_s_index)
						max_num_rxers_t_s(t_s_index) = max(max_num_rxers_t_s(t_s_index) , length(th.m_sensor_depl.get_dn_rx_nodes(tx_node)));
					end
				end
			end
			th.m_MAX_NUM_RXERS_t_s = max_num_rxers_t_s;
			for rx_node = 1:num_nodes
				tx_nodes = th.m_sensor_depl.get_incoming_nodes(rx_node);
				mac_address = th.m_sensor_depl.get_address(rx_node);
				pan_id = mac_address;
				th.m_rx_freq_time{rx_node} = zeros(0,2);
				th.m_rx_freqs{rx_node} = [];
				for tx_node_index=1:length(tx_nodes)
					tx_node = tx_nodes(tx_node_index);
					tx_freq = th.m_sensor_depl.get_params.m_tx_freqs{tx_node}.m_tx_freq;
					tx_time = th.m_sensor_depl.get_params.m_tx_freqs{tx_node}.m_tx_time;
					if(sum(ismember(th.m_rx_freq_time{rx_node},[tx_freq,tx_time],'rows')) > 0)
						error('Time/Freq Allocation Error!');
					end
					fi = find(freqs_array == tx_freq);	
					th.m_rx_macs{rx_node,fi} = mac_module(mac_address,pan_id,th.m_phys{fi});
					th.m_rx_freq_time{rx_node} = [th.m_rx_freq_time{rx_node};[tx_freq , tx_time]];
					th.m_rx_freqs{rx_node} = [th.m_rx_freqs{rx_node} , tx_freq];
					th.m_channel_holder.add_rx_freq(rx_node,tx_freq);
					th.m_RX_index(rx_node,fi) = 1;
				end

			end
			th.m_num_time_sharing_slots = num_time_sharing_slots;
			th.m_time_unit = th.m_modulators{1}.get_byte_signal_duration * 1;
			th.m_channel_holder.set_time_unit(th.m_time_unit);	
			th.m_channel_holder.initialize;
			[th.m_BEACON_SIGNAL_TIME , th.m_DATA_FRAME_SIGNAL_TIME] = th.calculate_superframe_length(max_num_rxers);
			th.write_log(['- Time Values:: Time Resolution:' num2str(1000*th.m_channel_holder.get_params.m_time_res) 'ms, Time Unit:' num2str(th.m_time_unit*1000) 'ms, BeaconSignalTime:' num2str(th.m_BEACON_SIGNAL_TIME*1000) 'ms, DataFrameSignalTime:' num2str(th.m_DATA_FRAME_SIGNAL_TIME*1000) 'ms, MaxTimeSharingSlots:' num2str(num_time_sharing_slots) ', MaxNumRXers:' num2str(max_num_rxers) ]);
			th.write_log(['- Gateway Node: ' num2str(th.m_sensor_depl.get_params.m_gateway_node)]);
		end
		function perform_QNC(th)
			th.m_it_index = th.m_it_index + 1;
			th.generate_coefficients(th.m_it_index);
			th.calculate_QNC(th.m_it_index);
			%Reset buffers
			for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				incoming_nodes = th.m_sensor_depl.get_incoming_nodes(rx_node);
				for i=1:length(incoming_nodes)
					th.m_buffers{rx_node,i} = th.m_q.quantize_and_convert_to_binary(0);
				end
			end
			for_gateway = 0;
			for_gateway_list = [];
			for t_s_index = 1:th.m_num_time_sharing_slots
				%TX and RX of Beacons
				for tx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
					tx_freq = th.m_tx_freq_time{tx_node}(1,1);
					tx_time = th.m_tx_freq_time{tx_node}(1,2);
					if(tx_time == t_s_index)
						time_at = th.m_timer;
				%		beacon_mac_frame = th.create_mac_beacon_packet(tx_node);
				%		tx_signal = th.m_tx_macs{tx_node}.convert_mac_packet_to_signal(beacon_mac_frame,time_at);
				%		th.m_channel_holder.propagate_tx_signal(tx_signal,tx_node,tx_freq);
				%		th.write_log([num2str(th.m_timer*1000) 'ms:: -> beacon is sent from node ' num2str(tx_node) ' at tx_freq=' num2str(tx_freq) ', tx_time_slot=' num2str(tx_time) ' to nodes: ' num2str(th.m_sensor_depl.get_dn_rx_nodes(tx_node)')]);
					end
				end
				th.m_timer = th.m_timer + th.m_BEACON_SIGNAL_TIME;
				th.m_timer_index = th.m_timer_index + 1;
				for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				%	incoming_nodes = th.m_sensor_depl.get_incoming_nodes(rx_node);
				%	for incoming_node_index = 1:length(incoming_nodes)
				%		incoming_node = incoming_nodes(incoming_node_index);
				%		rx_freq = th.m_tx_freq_time{incoming_node}(1,1);
				%		rx_time = th.m_tx_freq_time{incoming_node}(1,2);
				%		if(rx_time == t_s_index)
				%			time_to_rx = th.m_timer;
				%			[flag_rx_beacon(rx_node,incoming_node_index),source_node_beacon] = th.wait_for_beacon(rx_node,rx_freq,time_to_rx);
				%			if(flag_rx_beacon(rx_node,incoming_node_index) == true)
				%				th.write_log([num2str(th.m_timer*1000) 'ms:: <- beacon is RXed from node ' num2str(source_node_beacon) ' at node ' num2str(rx_node) ', freq=' num2str(rx_freq)]);
				%			end
				%		end
				%	end
				end
				th.m_channel_holder.release_all_memories_v2(th.m_timer);
				%TX and RX of Data Frames
				for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
					wait_for_rx_freq{rx_node} = th.m_rx_freqs{rx_node};
				end
				for rxer_index = 1:th.m_MAX_NUM_RXERS_t_s(t_s_index)
					num_txs = 0;
					num_rxs = 0;
					for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
						rx_freqs_for_this_rxer_index{rx_node} = [];
					end
					for tx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
						tx_freq = th.m_tx_freq_time{tx_node}(1,1);
						tx_time = th.m_tx_freq_time{tx_node}(1,2);
						if(tx_time == t_s_index)
							outgoing_nodes = th.m_sensor_depl.get_dn_rx_nodes(tx_node);
							if(length(outgoing_nodes) >= rxer_index)
								outgoing_node = outgoing_nodes(rxer_index);
								freq_index = find(th.m_freqs_array == tx_freq);
								time_at = th.m_timer;
								real_value_linear_comb = th.calculate_real_value_linear_comb(tx_node,outgoing_node,th.m_it_index);
								table_values(tx_node,outgoing_node) = real_value_linear_comb;
								data_mac_frame = th.create_mac_qnc_data_packet(tx_node,outgoing_node,real_value_linear_comb);
								phy_packet = th.m_phys{freq_index}.create_phy_packet(data_mac_frame);
								tx_signal = th.m_modulators{freq_index}.modulate_phy_packet(phy_packet,time_at);
								th.m_channel_holder.propagate_tx_signal(tx_signal,tx_node,tx_freq);
								%th.write_log([num2str(th.m_timer * 1000) 'ms:: -> a data packet is TXed from node ' num2str(tx_node) ' to node ' num2str(outgoing_node) ' with QNC_real_value= ' num2str(real_value_linear_comb) ' at tx_freq=' num2str(tx_freq) ' .']);
								num_txs = num_txs + 1;
								rx_freqs_for_this_rxer_index{outgoing_node} = [rx_freqs_for_this_rxer_index{outgoing_node} , tx_freq];	
							end
						end
					end
					th.collect_results;
					th.m_timer = th.m_timer + th.m_DATA_FRAME_SIGNAL_TIME;
					th.m_timer_index = th.m_timer_index + 1;
					for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
						rx_freqs = rx_freqs_for_this_rxer_index{rx_node};
						for rx_freq_index = 1: length(rx_freqs)
							rx_freq = rx_freqs(rx_freq_index);
							time_to_rx = th.m_timer;
							[flag_data,data,dec_binary,meas_sig] = th.wait_for_data(rx_node,rx_freq,time_to_rx);
							if(flag_data == true)
								incoming_nodes = th.m_sensor_depl.get_incoming_nodes(rx_node);
								incoming_node = th.m_sensor_depl.get_node_index_from_mac_address(data.addresses.src_add);
								incoming_node_index = find(incoming_nodes == incoming_node);
								th.m_buffers{rx_node,incoming_node_index} = data.pay_load.get_all;
								scalar_value_error = th.m_q.convert_binary_to_q_val(data.pay_load.get_all) - table_values(incoming_node,rx_node);
								num_rxs = num_rxs + 1;
								if(rx_node == th.m_sensor_depl.get_params.m_gateway_node)
									%th.write_log([num2str(th.m_timer * 1000) 'ms:: <-** a data packet is RXed from node ' num2str(incoming_node) ' to node ' num2str(rx_node) ' (GATEWAY) at rx_freq=' num2str(rx_freq) ' with decoded_real_value= ' num2str(th.m_q.convert_binary_to_q_val(data.pay_load.get_all)) ', scalar_error_of_TX=' num2str(scalar_value_error) ' .']);
									%Decode using this partial measurements
									for_gateway_list = [for_gateway_list , incoming_node];

									th.store_gateway_content(th.m_it_index,for_gateway_list);
									th.m_decoded_messages_final = th.decode_messages(th.m_it_index,for_gateway_list);
									th.collect_results(true);
									%th.write_log(th.m_results_final{end});	
								else
									%th.write_log([num2str(th.m_timer * 1000) 'ms:: <- a data packet is RXed from node ' num2str(incoming_node) ' to node ' num2str(rx_node) ' at rx_freq=' num2str(rx_freq) ' with decoded_real_value= ' num2str(th.m_q.convert_binary_to_q_val(data.pay_load.get_all)) ', scalar_error_of_TX=' num2str(scalar_value_error) ' .']);
								end
							end
						end
					end	
					th.m_channel_holder.release_all_memories_v2(th.m_timer);
					th.m_txs = th.m_txs + num_txs;
					th.m_packet_drops = th.m_packet_drops + (num_txs - num_rxs);
					if((t_s_index == th.m_num_time_sharing_slots)&(rxer_index == th.m_MAX_NUM_RXERS_t_s(t_s_index)))
						%WAS THE LAST
						th.write_log([num2str(th.m_timer * 1000) 'ms:: Time Iteration ' num2str(th.m_it_index) ' is finished.']);
						th.write_log(th.m_results_final{end});
						%De-Quantize All Buffers
						for rx_node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
							incoming_nodes = th.m_sensor_depl.get_incoming_nodes(rx_node);
							for i = 1:length(incoming_nodes)
								th.m_buffers_real_values(rx_node,i) = th.m_q.convert_binary_to_q_val(th.m_buffers{rx_node,i});
							end
						end
					end
					th.collect_results;
				end
			end	
		end
		function collect_results(th,is_last)
			th.m_results_final{th.m_timer_index}.message_norm = norm(th.m_messages.x_vector,2);
			th.m_results_final{th.m_timer_index}.error_norm = norm(th.m_decoded_messages_final - th.m_messages.x_vector,2);
			th.m_results_final{th.m_timer_index}.decoding_snr = 20*log10(norm(th.m_messages.x_vector,2)/norm(th.m_decoded_messages_final - th.m_messages.x_vector,2));
			th.m_results_final{th.m_timer_index}.delay = th.m_timer * 1000;
			th.m_results_final{th.m_timer_index}.it_index = th.m_it_index;
			th.m_results_final{th.m_timer_index}.number_of_txs = th.m_txs;
			th.m_results_final{th.m_timer_index}.number_of_packet_drops = th.m_packet_drops;
			th.m_results_final{th.m_timer_index}.total_tx_energy = th.m_channel_holder.get_total_tx_energy;
			th.m_results_final{th.m_timer_index}.packet_len = th.m_packet_len;
			if(nargin==1)
				is_last = false;
			end
			if(is_last == true)
				m_meas_noise = th.m_z_tot - th.m_Psi_tot{th.m_it_index} * th.m_messages.x_vector;
				th.m_results_final{th.m_timer_index}.meas_noise_norm = norm(m_meas_noise,2);
				th.m_results_final{th.m_timer_index}.decoding_error_margin_norm = th.m_eps_coef(th.m_it_index) ^ .5 * th.m_q.get_params.m_q_step;
			else
				th.m_results_final{th.m_timer_index}.meas_noise_norm = 0;
				th.m_results_final{th.m_timer_index}.decoding_error_margin_norm = 0;
			end
		end
		function [mac_packet,flag] = create_mac_qnc_data_packet(th,tx_node,rx_node,real_value_linear_comb)
			tx_freq = th.m_tx_freq_time{tx_node}(1,1);	
			linear_comb_binary = th.m_q.quantize_and_convert_to_binary(real_value_linear_comb);
			m_ack_req = 0;
			m_dest_add = th.m_sensor_depl.get_address(rx_node);
			m_dest_panID = m_dest_add;
			m_src_add = th.m_tx_macs{tx_node}.get_mac_address;
			m_src_panID = m_src_add;
			m_seq_number = rand(1,8) > .5;
			data_packet = packet_general;
			data_packet.addToEnd(linear_comb_binary);
			mac_packet = th.m_tx_macs{tx_node}.create_mac_data_frame(m_ack_req,m_dest_panID,m_dest_add,m_src_panID,m_src_add,m_seq_number,data_packet);	
			flag = true;
		end
		function [mac_packet] = create_mac_beacon_packet(th,tx_node);
			mac_packet = th.m_tx_macs{tx_node}.create_mac_beacon_frame(th.m_tx_macs{tx_node}.get_mac_address,th.m_tx_macs{tx_node}.get_mac_address);	
		end 
		function [beacon_signal_end_time,data_frame_signal_time_with_IFS] = calculate_superframe_length(th,num_rx_nodes)
			time_0 = 0;
			tx_node = 1;
			beacon_frame = th.create_mac_beacon_packet(tx_node);
			beacon_sig = th.m_tx_macs{tx_node}.convert_mac_packet_to_signal(beacon_frame,time_0);
			time_0 = beacon_sig.get_end_time + th.m_tx_macs{tx_node}.calculate_IFS_signal_time(beacon_frame.getSize);
			beacon_signal_end_time = time_0;
			dn_rx_nodes = th.m_sensor_depl.get_dn_rx_nodes(tx_node);
			rx_node = dn_rx_nodes(1);
			mac_data_packet = th.create_mac_qnc_data_packet(tx_node,rx_node,0);
			this_sig = th.m_tx_macs{tx_node}.convert_mac_packet_to_signal(mac_data_packet,time_0);
			time_0 = this_sig.get_end_time + th.m_tx_macs{tx_node}.calculate_IFS_signal_time(mac_data_packet.getSize);
			data_frame_signal_time_with_IFS = time_0 - this_sig.get_init_time;
		end
		function [dn_superframe_signal,end_time,num_rxers] = create_dn_superframe_signal(th,tx_node,time_at)
			time_0 = time_at;
			beacon_frame = th.create_mac_beacon_packet(tx_node);
			beacon_sig = th.m_tx_macs{tx_node}.convert_mac_packet_to_signal(beacon_frame,time_0);
			time_0 = beacon_sig.get_end_time + th.m_tx_macs{tx_node}.calculate_IFS_signal_time(beacon_frame.getSize);
			dn_rx_nodes = th.m_sensor_depl.get_dn_rx_nodes(tx_node);
			for rx_node_index = 1:length(dn_rx_nodes)
				rx_node = dn_rx_nodes(rx_node_index);
				real_value_linear_comb = th.calculate_real_value_linear_comb(tx_node,rx_node,th.m_it_index);
				mac_data_packet{rx_node_index} = th.create_mac_qnc_data_packet(tx_node,rx_node,real_value_linear_comb);
				this_sig{rx_node_index} = th.m_tx_macs{tx_node}.convert_mac_packet_to_signal(mac_data_packet{rx_node_index},time_0);
				time_0 = this_sig{rx_node_index}.get_end_time + th.m_tx_macs{tx_node}.calculate_IFS_signal_time(mac_data_packet{rx_node_index}.getSize);
			end
			end_time = time_0;
			if(length(dn_rx_nodes) > 0)
				time_vec = [beacon_sig.get_init_time : this_sig{1}.get_time_res : this_sig{end}.get_end_time ];
				dn_superframe_signal = signal_continous_time(time_vec(1),time_vec(end),time_vec * 0);
				dn_superframe_signal.set_as_part(beacon_sig);
				for rx_node_index = 1:length(dn_rx_nodes)
					dn_superframe_signal.set_as_part(this_sig{rx_node_index});
				end
			end
			num_rxers = length(dn_rx_nodes);
		end
		function F_prod = calculate_F_prod(th,t_1,t_2)
			num_edges = th.m_sensor_depl.get_params.m_number_of_edges;
			F_prod = eye(num_edges,num_edges);
			if(t_2 >= t_1)
				for t = t_1 : 1 : t_2
					F_prod = th.m_F_matrix{t} * F_prod;
				end	
			end
		end	
		function calculate_QNC(th,time_iteration_index)
			num_edges = th.m_sensor_depl.get_params.m_number_of_edges;
			if(time_iteration_index == 2)
				th.calculate_B_matrix;
				th.m_F_prod = eye(num_edges,num_edges);	
				th.m_Psi{2} = th.m_B_matrix * th.m_A_matrix{2};
				th.m_Psi_tot{2} = th.m_Psi{2};
			elseif(time_iteration_index > 2)
				th.m_F_prod = th.m_F_matrix{time_iteration_index} * th.m_F_prod;
				th.m_Psi{time_iteration_index} = th.m_B_matrix * th.m_F_prod * th.m_A_matrix{2};
				th.m_Psi_tot{time_iteration_index} = [th.m_Psi_tot{time_iteration_index -1};th.m_Psi{time_iteration_index}];
			end
			this_portion = 0;
			if(time_iteration_index < 20)
				in_v0 = th.m_sensor_depl.get_incoming_edges(th.m_sensor_depl.get_params.m_gateway_node);
				if(time_iteration_index == 2)
					this_portion = length(in_v0) / 4;
				else
					for e_ind = 1:length(in_v0)
						e = in_v0(e_ind);
						sum_2 = 0;
						for t_2prime = 2:time_iteration_index
							sum_1 = 0;
							this_F_prod = th.calculate_F_prod(t_2prime,time_iteration_index);
							for e_prime = 1:num_edges
								sum_1 = sum_1 + abs(this_F_prod(e,e_prime));
							end	
							sum_2 = sum_2 + sum_1;
						end
						sum_2_squared = sum_2 ^2;
						this_portion = this_portion + sum_2_squared / 4;
					end
				end
			end
			if(time_iteration_index > 2)
				th.m_eps_coef(time_iteration_index) = th.m_eps_coef(time_iteration_index-1) + this_portion;
			else
				th.m_eps_coef(time_iteration_index) = this_portion;
			end

%			if(time_iteration_index < 21)
%				sum_ = zeros(num_edges,num_edges);
%				f_prod = eye(num_edges,num_edges);
%				for t_prime = 1:time_iteration_index - 1
%					for t_2_prime = time_iteration_index : -1 : t_prime + 2
%						f_prod = f_prod * th.m_F_matrix{t_2_prime};
%					end
%					sum_ = sum_ + abs(f_prod);
%				end
%				th.m_eps_coef(time_iteration_index) = 1/4*ones(1,num_edges)*sum_' * th.m_B_matrix' * th.m_B_matrix * sum_ * ones(num_edges,1);
%				if(time_iteration_index > 2)
%					th.m_eps_coef(time_iteration_index) = th.m_eps_coef(time_iteration_index-1) + th.m_eps_coef(time_iteration_index);
%				end
%			else	
%				th.m_eps_coef(time_iteration_index) = th.m_eps_coef(time_iteration_index-1);
%			end
		end
		function calculate_B_matrix(th)
			num_edges = th.m_sensor_depl.get_params.m_number_of_edges;
			gateway_node = th.m_sensor_depl.get_params.m_gateway_node;
			incoming_nodes = th.m_sensor_depl.get_incoming_nodes(gateway_node);
			for i = 1:length(incoming_nodes)
				th.m_B_matrix(i,:) = zeros(1,num_edges);
				e_in = th.m_sensor_depl.find_edge(gateway_node,incoming_nodes(i));
				th.m_B_matrix(i,e_in) = 1;
			end
		end
		function [this_A,this_F] = generate_coefficients(th,time_iteration_index)
			num_nodes = th.m_sensor_depl.get_params.m_number_of_nodes;
			num_edges = th.m_sensor_depl.get_params.m_number_of_edges;
			this_A = zeros(num_edges,num_nodes);
			this_F = zeros(num_edges,num_edges);
			for node = 1:num_nodes
				incoming_nodes = th.m_sensor_depl.get_incoming_nodes(node);
				incoming_edges = find(th.m_sensor_depl.get_params.m_ht_list(:,1)==node);
				outgoing_edges = find(th.m_sensor_depl.get_params.m_ht_list(:,2)==node);
				if( time_iteration_index == 2 )
					for e_out_index = 1:length(outgoing_edges)
						e_out = outgoing_edges(e_out_index);
						this_A(e_out,node) = sign(randn);
					end
				elseif( time_iteration_index > 2 )
					basis_vectors = RandOrthMat(length(incoming_edges));
					if(length(outgoing_edges) > length(incoming_edges))
						outgoing_edges(length(incoming_edges)+1:end) = [];
					end
					for e_out_index = 1:length(outgoing_edges)
						e_out = outgoing_edges(e_out_index);
						for e_in_index = 1:length(incoming_edges)
							e_in = incoming_edges(e_in_index);
							this_F(e_out,e_in) = basis_vectors(e_out_index,e_in_index);
						end
						if(norm(this_F(e_out,:),1) > 0)
							this_F(e_out,:) = this_F(e_out,:) / norm(this_F(e_out,:),1);
						end
					end
				end
			end
			th.m_A_matrix{time_iteration_index} = this_A;
			th.m_F_matrix{time_iteration_index} = this_F;
		end
		function real_value = calculate_real_value_linear_comb(th,tx_node,rx_node,time_iteration_index)
			e_out = th.m_sensor_depl.find_edge(rx_node,tx_node);
			incoming_nodes = th.m_sensor_depl.get_incoming_nodes(tx_node);
			real_value = 0;
			for i = 1:length(incoming_nodes)
				e_in = th.m_sensor_depl.find_edge(tx_node,incoming_nodes(i));
				real_value = real_value + th.m_buffers_real_values(tx_node,i) * th.m_F_matrix{time_iteration_index}(e_out,e_in);
			end
			if(time_iteration_index >= 2)
				real_value = real_value + th.m_A_matrix{time_iteration_index}(e_out,tx_node) * th.m_messages.x_vector(tx_node);
			else
				real_value = 0;
			end
		end
		function [flag,source_node] = wait_for_beacon(th,rx_node,rx_freq,time_at)
			flag = false;
			source_node = [];
			rx_freq_index = find(th.m_freqs_array== rx_freq);
			if(isempty(rx_freq_index))
				return;
			end
			binary_str = th.m_channel_holder.read_binary_string(rx_node,rx_freq,th.m_RX_index(rx_node,rx_freq_index),time_at);
			packets_ = th.m_rx_macs{rx_node,rx_freq_index}.decode_binary_string_to_mac_pay_loads(binary_str);
			index_0 = th.m_RX_index(rx_node,rx_freq_index);
			for p_ind = 1:length(packets_)
				if(packets_{p_ind}.flag == false)
					continue;
				end
				th.m_RX_index(rx_node,rx_freq_index) = index_0 + packets_{p_ind}.end_index ;
				th.m_channel_holder.release_bits_before(rx_node,rx_freq,th.m_RX_index(rx_node,rx_freq_index));
				if(strcmp(packets_{p_ind}.frame_type,'MAC_BEACON_FRAME') == false)
					continue;
				end
				m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.src_add);
				if(m_src_node == -1) 
					continue;
				end
				if(isempty(find(th.m_sensor_depl.get_incoming_nodes(rx_node) == m_src_node)));
					continue;
				end
				if(th.m_tx_freq_time{m_src_node}(1,1) ~= rx_freq)
					continue;
				end
				source_node = m_src_node;
				flag = true;
			end
		end
		function [flag,pay_load,binary_str,meas_sig]=wait_for_data(th,rx_node,rx_freq,time_at)
			rx_freq_index = find(th.m_freqs_array == rx_freq);
			flag = false;
			pay_load = [];
			meas_sig = [];
			if(isempty(rx_freq_index))
				return;
			end
			[binary_str,read_flag,meas_sig] = th.m_channel_holder.read_binary_string(rx_node,rx_freq,th.m_RX_index(rx_node,rx_freq_index),time_at,time_at - th.m_DATA_FRAME_SIGNAL_TIME);
			if(read_flag == false)
				%th.write_log('read error!');
			end
			packets_ = th.m_rx_macs{rx_node,rx_freq_index}.decode_binary_string_to_mac_pay_loads(binary_str);
			index_0 = th.m_RX_index(rx_node,rx_freq_index);
			for p_ind = 1:length(packets_)
				if(packets_{p_ind}.flag ==false)
					continue;
				end
				th.m_RX_index(rx_node,rx_freq_index) = index_0 + packets_{p_ind}.end_index ;
				th.m_channel_holder.release_bits_before(rx_node,rx_freq,th.m_RX_index(rx_node,rx_freq_index));
				if(strcmp(packets_{p_ind}.frame_type,'MAC_DATA_FRAME') == false)
					continue;
				end
				m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.src_add);
				m_dest_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.dest_add);
				if(m_src_node == -1) 
					continue;
				end
				if(m_dest_node == -1)
					continue;
				end
				if(rx_node ~= m_dest_node)
					continue;
				end
				if(isempty(find(m_src_node == th.m_sensor_depl.get_incoming_nodes(m_dest_node))))
					continue;
				end
				flag = true;
				pay_load = packets_{p_ind};
			end
			if(flag == false)
				%th.write_log([num2str(th.m_timer*1000) 'ms:: !!!! RX-failed at rx_node=' num2str(rx_node) ', rx_freq=' num2str(rx_freq) ', length=' num2str(length(packets_)) ', bin_len=' num2str(length(binary_str)) '!!!!']);
				%figure,meas_sig.plot_this('r'); title('meas sig for decoding');
			end
		end
		function store_gateway_content(th,time_iteration_index,for_gateway_list)
			gw_node = th.m_sensor_depl.get_params.m_gateway_node;
			incoming_nodes = th.m_sensor_depl.get_incoming_nodes(gw_node);
			for incoming_node_index = 1:length(incoming_nodes)
				if(~isempty(find(for_gateway_list == incoming_nodes(incoming_node_index))))
					th.m_z_tot((time_iteration_index - 2)*length(incoming_nodes)+incoming_node_index,1) = th.m_q.convert_binary_to_q_val(th.m_buffers{gw_node,incoming_node_index});
				else
					th.m_z_tot((time_iteration_index - 2)*length(incoming_nodes)+incoming_node_index,1) = 0;
				end
			end
		end
		function rec_x_vector = decode_messages(th,time_iteration_index,for_gateway_list)
			phi_ = th.m_messages.phi;
			gw_node = th.m_sensor_depl.get_params.m_gateway_node;
			incoming_nodes = th.m_sensor_depl.get_incoming_nodes(gw_node);
			z_tot_ = th.m_z_tot;
			Theta_tot_ =  th.m_Psi_tot{time_iteration_index} * phi_;
			for i=size(Theta_tot_,1):-1:1
				time_it = 2 + floor((i-1)/length(incoming_nodes));
				incoming_node_index = mod(i-1,length(incoming_nodes)) + 1; 
				incoming_node = incoming_nodes(incoming_node_index);
				if((time_iteration_index == time_it) & (isempty(find(incoming_node == for_gateway_list))))
					z_tot_(i) = [];
					Theta_tot_(i,:) = [];
				end
			end
			norm_noise_bound_ = th.m_eps_coef(time_iteration_index) ^ .5 * th.m_q.get_params.m_q_step;
			cvx_begin quiet
				variable s_vec(size(phi_,1));
				minimize( norm(s_vec,1) );
					subject to
						norm(z_tot_ - Theta_tot_ * s_vec,2) <= norm_noise_bound_ ;
			cvx_end	
			if(strcmp(cvx_status,'Solved')==false)
				th.write_log([num2str(th.m_timer*1000) 'ms:: !! CVX has failed to find a solution!!!']);
				if(time_iteration_index > 2)
					rec_x_vector = th.m_decoded_messages_final;
				else
					for i=1:length(s_vec)
						if(isnan(s_vec(i)))
							s_vec(i) = 0;
						end
					end	
					rec_x_vector = phi_ * s_vec;
					for i=1:length(rec_x_vector)
						if(abs(rec_x_vector(i)) > th.m_values_range )
							rec_x_vector(i) = th.m_values_range * sign(rec_x_vector(i));
						end
					end
				end
			else
				rec_x_vector = phi_ * s_vec;
				for i=1:length(rec_x_vector)
					if(abs(rec_x_vector(i)) > th.m_values_range )
						rec_x_vector(i) = th.m_values_range * sign(rec_x_vector(i));
					end
				end
			end
		end
		function write_log(th,text)
			if(th.m_write_log==false)
				return;
			end
			disp(text);
		end
	end
end

