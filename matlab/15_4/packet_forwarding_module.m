classdef packet_forwarding_module < handle
	properties (Hidden)
			m_write_log;

			m_sensor_depl;
			m_channel_holder;
			m_packet_len;
			m_freqs_array;
			m_freq_list;
			m_coordinator_freq;
			m_carriers;
			m_modulators;
			m_phys;
			m_mac_node;
			m_mac_coordinator;
			m_buffers;
			m_gateway_buffer;
			m_q;
			m_timer;	%unit is seconds
			m_time_unit;
			m_cluster_coordinator;
			m_coordinators;
			m_original_messages;
			m_decoded_messages;
			m_results;
			m_seq_numbers;
			coordinator_RX_index;
			node_RX_index;
			m_release_memory_timer;
			m_beacon_energy;
			%CONSTANTS
			BEACON_TO_BEACON_TIME_DIFFERENCE;	
			AVG_MOD_SIG_ENERGY;
			MAC_MIN_BE = 3;
			MAC_MAX_BE = 5;
			MAC_MAX_CSMA_BACKOFFS = 100;
			PF_END_TIME = 250e-3;
		BACKOFF_UNIT;
		ENERGY_DETECTION_TIME_WINDOW_UNITS = 5;
		ENERGY_DETECTION_DIFF_WITH_BEACON = 150;
		%Evaluation Parameters
		e_number_of_CSMA_failures;
		e_number_of_packet_drops;
		e_number_of_backoffs;
		e_number_of_inter_node_tx;
		m_save_file_name;

		m_adds;
		m_removes;
	end
	methods 
		function PF_m = packet_forwarding_module(depl)
			PF_m.m_sensor_depl = depl;
			PF_m.m_channel_holder = PF_m.m_sensor_depl.get_params.m_channel_holder;
			
			PF_m.m_adds = 0;
			PF_m.m_removes = 0;
		end
		function enable_write_log(th)
			th.m_write_log = true;
		end
		function disable_write_log(th)
			th.m_write_log = false;
		end
		function initialize_default_freqs(th_PF,Q_range,packet_len)
			freqs_array = [];
			for k = 11:26
				freqs_array = [freqs_array , 2405 + 5 * (k-11)];
			end
			th_PF.initialize(freqs_array,Q_range,packet_len);
		end
		function set_save_file_name(th,name)
			th.m_save_file_name = name;
		end
		function initialize(th_PF,freqs_array,Q_range,packet_len,save_file_name)
			th_PF.m_packet_len = packet_len;
			th_PF.m_q = uniform_quantizer(Q_range,th_PF.m_packet_len);
			th_PF.m_freqs_array = freqs_array;
			if nargin == 4
				save_file_name = ['TEMP_RANDOM_' num2str(round(rand * 10000))];
			end
			th_PF.set_save_file_name(save_file_name);
		end
		function simulation_initialize(th,messages)
			th.p_simulation_initialize(messages);
		end
		function deliver_messages(th)
			th.p_deliver_messages;
		end
		function [results] = get_results(th)
			results = th.m_results;
		end
	end
	methods (Hidden)
		function p_simulation_initialize(th,messages)
			if(length(messages) ~= th.m_sensor_depl.get_params.m_number_of_nodes)
				error('Number of Messages should be the same as number of nodes!');
			end
			th.e_number_of_CSMA_failures = 0;
			th.e_number_of_packet_drops = 0;
			th.e_number_of_backoffs = 0;
			th.e_number_of_inter_node_tx = 0;
			%cluster nodes and identify coordinators-associated nodes
			th.m_coordinators = [];
			for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				if(node ~= th.m_sensor_depl.get_params.m_gateway_node)
					this_path = th.m_sensor_depl.get_path_to_gateway(node);
					th.m_cluster_coordinator(node) = this_path(2);
					if(isempty(find(th.m_coordinators == th.m_cluster_coordinator(node))))
						th.m_coordinators = [th.m_coordinators , th.m_cluster_coordinator(node)];
					end
				end
			end	
			%assign frequency to coordinators and their associated nodes
			available_freqs = length(th.m_freqs_array);
			cntr = 1;
			for i = 1:length(th.m_coordinators)
				th.m_coordinator_freq(th.m_coordinators(i)) = th.m_freqs_array(cntr);
				if(cntr==available_freqs)
					cntr = 1;
				else
					cntr = cntr + 1;
				end
			end
			for node=1:th.m_sensor_depl.get_params.m_number_of_nodes
				if(node ~= th.m_sensor_depl.get_params.m_gateway_node)
					th.m_freq_list(node) = th.m_coordinator_freq(th.m_cluster_coordinator(node));
				end
			end
			%Instantiate Carrier, Modulator, PHY and MAC modules necessary
			for k = 1:length(th.m_freqs_array)
				th.m_carriers{k} = carrier_signal(th.m_freqs_array(k) * 1e6,0);
				t_c = 1 / (2e+6);
				th.m_modulators{k} = modulator_2500meg(th.m_carriers{k},t_c,th.m_channel_holder.get_params.m_time_res);
				th.m_phys{k} = phy_module(th.m_modulators{k});
			end
			th.m_time_unit = th.m_modulators{1}.get_byte_signal_duration * 1;
			th.m_release_memory_timer = th.m_time_unit * 50;
			th.BACKOFF_UNIT = th.m_modulators{1}.get_byte_signal_duration * 10;	% 20 symbols (4bits)
			th.BEACON_TO_BEACON_TIME_DIFFERENCE = th.m_time_unit / 2 * 16*60 * 2^(1); %power can be from 0 to 14
			th.AVG_MOD_SIG_ENERGY = th.m_modulators{1}.get_avg_signal_energy;
			th.m_channel_holder.set_freqs(th.m_freqs_array);
			th.m_channel_holder.set_modulators(th.m_modulators);
			th.m_channel_holder.initialize;
			th.m_channel_holder.set_time_unit(th.m_time_unit);
			for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				if(node ~= th.m_sensor_depl.get_params.m_gateway_node)
					th.m_channel_holder.add_rx_freq(node,th.m_freq_list(node));
				end
				if(~isempty(find(th.m_coordinators==node)))
					th.m_channel_holder.add_rx_freq(node,th.m_coordinator_freq(node));
				end
			end
			th.write_log(['    TIME RESOLUTION: ' num2str(th.m_channel_holder.get_params.m_time_res*1000) 'ms']);
			th.write_log(['    TIME UNIT: ' num2str(th.m_time_unit*1000) 'ms']);
			th.write_log(['    BEACON-to-BEACON DELAY: ' num2str(th.BEACON_TO_BEACON_TIME_DIFFERENCE*1000) 'ms']);
			th.write_log(['    Backoff Unit: ' num2str(th.BACKOFF_UNIT*1000) 'ms']);
			str_ = [];
			for i=1:length(th.m_coordinators)
				node_ = th.m_coordinators(i);
				freq_ = th.m_coordinator_freq(node_);
				str_ = [str_ num2str(node_) ' (f=' num2str(freq_) '), '];
			end
			th.write_log([ 'COORDINATORS: ' str_]);
			th.write_log([' GATEWAY NODE: ' num2str(th.m_sensor_depl.get_params.m_gateway_node)]);
			for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
				if(node ~= th.m_sensor_depl.get_params.m_gateway_node)
					node_freq = th.m_freq_list(node);
					freq_index = find(node_freq == th.m_freqs_array);
					corresponding_coordinator_node = th.m_cluster_coordinator(node);
					mac_address = th.m_sensor_depl.get_address(node);
					pan_id = th.m_sensor_depl.get_address(corresponding_coordinator_node);
					th.m_mac_node{node} = mac_module(mac_address,pan_id,th.m_phys{freq_index});
				end
			end
			for i = 1:length(th.m_coordinators)
				co_node = th.m_coordinators(i);
				co_freq = th.m_coordinator_freq(co_node);
				co_freq_index = find(co_freq == th.m_freqs_array);
				co_mac_address = th.m_sensor_depl.get_address(co_node);
				co_pan_id = co_mac_address;
				th.m_mac_coordinator{co_node} = mac_module(co_mac_address,co_pan_id,th.m_phys{co_freq_index});
			end
			%Quantize Messages at the Source Nodes
			th.m_original_messages = messages;
			mess_binaries = th.m_q.quantize_and_convert_to_binary(messages);
			%Initialize the buffers
			for node=1:th.m_sensor_depl.get_params.m_number_of_nodes
				node_index = de2bi(node,8);
				if(node == th.m_sensor_depl.get_params.m_gateway_node)
					th.m_gateway_buffer{1} = [node_index , mess_binaries(node,:)];
				else
					th.m_buffers{node} = [ node_index , mess_binaries(node,:)];
					th.m_adds = th.m_adds + 1;
				end
			end
			th.m_timer = 0;	
		end
		function p_deliver_messages(th,log_arg)
			if(nargin == 1)
				log_arg = 1;
			end
			%Perform Packet Forwarding over PHY-MAC layers		
			num_nodes = th.m_sensor_depl.get_params.m_number_of_nodes;
			for node=1:num_nodes
				node_stat{node} = 'idle';
				backoff_exponent(node) = th.MAC_MIN_BE;
				th.coordinator_RX_index(node) = 1;
				th.node_RX_index(node) = 1;
			end
			time_of_next_beacon = th.m_time_unit * 0;
			still_full = true;
			while(still_full)
				if(abs(th.m_timer - time_of_next_beacon) < th.m_time_unit / 10)
%					th.m_channel_holder.release_all_memories_v2(th.m_timer);
				end
				if(th.m_timer > time_of_next_beacon + th.m_time_unit / 10)
					time_of_next_beacon = time_of_next_beacon + th.BEACON_TO_BEACON_TIME_DIFFERENCE;
				end
				% As a coordinator:
				for node = th.m_coordinators
					coordinator_freq = th.m_coordinator_freq(node);
					if(abs(th.m_timer - time_of_next_beacon) < th.m_time_unit / 10)
						coordinator_stat{node} = 'idle';
					end
					switch coordinator_stat{node} 
						case 'idle'
							coordinator_stat{node} = 'tx_beacon';
							beacon_frame = th.m_mac_coordinator{node}.create_mac_beacon_frame(th.m_mac_coordinator{node}.get_mac_address,th.m_mac_coordinator{node}.get_mac_address);
							signal = th.m_mac_coordinator{node}.convert_mac_packet_to_signal(beacon_frame,th.m_timer);
							time_to_end_tx_beacon(node) = signal.get_end_time + th.m_mac_coordinator{node}.calculate_IFS_signal_time(beacon_frame.getSize);
							th.m_channel_holder.propagate_tx_signal(signal,node,coordinator_freq);
							if(log_arg > 0)
								%th.write_log([ num2str(th.m_timer*1000) 'ms: TXing BEACON at node ' num2str(node) ' at freq=' num2str(coordinator_freq) ' which ends at ' num2str(signal.get_end_time * 1000) ' ms, to: ' num2str(find(th.m_cluster_coordinator(:)==node)')]);
							end
						case 'tx_beacon'
							if(time_to_end_tx_beacon(node) >= th.m_timer)
								coordinator_stat{node} = 'waiting_listening_to_rx_signal';
							end
						case 'waiting_listening_to_rx_signal'
							%decode signal and if new data packet is recovered:
							% store it in buffer and send an ACK
							[flag , packet] = th.wait_for_data(node,coordinator_freq);
							if(flag == true)
								m_src_panID = packet.addresses.src_panID;
								m_src_add = packet.addresses.src_add;
								m_dest_panID = packet.addresses.dest_panID;
								m_dest_add = packet.addresses.dest_add;
								m_seq_number = packet.seq_number ;
								m_dest_node = th.m_sensor_depl.get_node_index_from_mac_address(m_dest_add);
								m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(m_src_add);
								if(node == th.m_sensor_depl.get_params.m_gateway_node)
									%th.m_gateway_buffer{1} = [th.m_gateway_buffer{1} , packet.pay_load.get_all ];
									th.m_gateway_buffer{length(th.m_gateway_buffer) + 1} = packet.pay_load.get_all;
								else
									th.m_buffers{node} = [th.m_buffers{node} ; packet.pay_load.get_all];
									th.m_adds = th.m_adds + 1;
								end
								if(log_arg > 0)
									%th.write_log([ num2str(th.m_timer*1000) 'ms: -- a data packet with seq_num=' num2str(bi2de(m_seq_number)) ' is RXed at node ' num2str(node) ' from node ' num2str(m_src_node) ' ACK-TX will finish at ' num2str(signal.get_end_time*1000) ' ms .']);
								end
								ack_packet = th.m_mac_coordinator{node}.create_mac_ack_frame(m_src_panID,m_src_add,m_dest_panID,m_dest_add,m_seq_number);
								signal = th.m_mac_coordinator{node}.convert_mac_packet_to_signal(ack_packet,th.m_timer + th.m_time_unit);
								if(signal.get_end_time < time_of_next_beacon) 
									th.m_channel_holder.propagate_tx_signal(signal,node,coordinator_freq);
									coordinator_stat{node} = 'tx_ack';
									time_to_end_tx_ack(node) = signal.get_end_time;
									if(log_arg > 0)
										%th.write_log([ num2str(th.m_timer*1000) 'ms: ACK TXing with seq_number=' num2str(bi2de(m_seq_number))]);
									end
								end
							end
						case 'tx_ack'
							if(time_to_end_tx_ack(node) <= th.m_timer)
								coordinator_stat{node} = 'waiting_listening_to_rx_signal';
							end
					end
				end
				% As an associated node to a coordinator:
				%Transmit the buffer contents using CSMA/CA
				%Consider all period of time as Contention-Access-Period except for the beacon TX
				for node = 1:num_nodes
				if(node ~= th.m_sensor_depl.get_params.m_gateway_node)
					if(abs(time_of_next_beacon - th.m_timer) < th.m_time_unit / 10 )
						node_stat{node} = 'waiting_listening_to_beacon';
						%node_stat{node} = 'cap_idle';
						%th.m_beacon_energy(node) = 10e-17;
					end
					switch node_stat{node}
						case 'idle'
							%%!!
							node_stat{node} = 'waiting_listening_to_beacon';
						case 'waiting_listening_to_beacon'
							[flag,energy,beacon_from] = th.wait_for_beacon(node,th.m_freq_list(node));
							if(flag == true)
								if(log_arg > 0)
									%th.write_log([num2str(th.m_timer*1000) 'ms: beacon-detected at node=' num2str(node) ' originating from node ' num2str(beacon_from) ', freq=' num2str(th.m_freq_list(node)) ' with avg_energy= ' num2str(energy)]);
								end
								th.m_beacon_energy(node) = energy;
								node_stat{node} = 'cap_idle';
							end	
						case 'cap_idle'
							backoff_exponent(node) = th.MAC_MIN_BE;
							number_of_backoffs(node) = 0;
							CW_counter(node) = 3 * th.m_time_unit;
							if(length(th.m_buffers{node}) > 0)
								time_to_stay_in_backoff(node) = ceil(rand * 2^(backoff_exponent(node))-1) * th.BACKOFF_UNIT + th.m_timer;
								%th.write_log([num2str(th.m_timer*1000) 'ms: Backing off from TX for the ' num2str(number_of_backoffs(node)) ' time until ' num2str(time_to_stay_in_backoff(node)*1000) 'ms at node ' num2str(node) ' to node ' num2str(th.m_cluster_coordinator(node)) ' at freq=' num2str(th.m_freq_list(node)) ' +++++++']);
								node_stat{node} = 'cap_in_backoff';
								%node_stat{node} = 'cap_perform_csmaca';
							end
						case 'cap_perform_csmaca'
							[cca_res,energy,energy_th] = th.is_channel_cleared(node);
							if(cca_res == true)
								if(CW_counter(node) <= 0)
									th.remove_multiple_copies(node);
									[time_end,signal,ack_end_time,sig_end,th.m_seq_numbers{node}] = th.get_tx_binary_time_duration(th.m_buffers{node}(1,:),node,th.m_timer);
									if( ( ack_end_time < time_of_next_beacon) )
										node_stat{node} = 'cap_in_tx';
										if(log_arg > 0)
											%th.write_log([num2str(th.m_timer*1000) 'ms: TXing Data which ends at: ' num2str(sig_end * 1000) ' ms from node ' num2str(node) ' to  node ' num2str(th.m_cluster_coordinator(node)) ' at freq=' num2str(th.m_freq_list(node)) ' expecting ACK by ' num2str(ack_end_time) ' meas_energy=' num2str(energy) ',th_energy=' num2str(energy_th) ',seq_num=' num2str(bi2de(th.m_seq_numbers{node}))]);
										end
										time_to_end_tx(node) = sig_end;
										this_freq = th.m_freq_list(node);
										th.m_channel_holder.propagate_tx_signal(signal,node,this_freq);
										th.e_number_of_inter_node_tx = th.e_number_of_inter_node_tx + 1;
										time_to_wait_for_ack(node) = ack_end_time;
									else
										%Should not try to TX anything until the next beacon		
									end
								else
										CW_counter(node) = CW_counter(node) - th.m_time_unit;
								end
							else
								%Move to backoff 
								th.e_number_of_backoffs = th.e_number_of_backoffs + 1;
								number_of_backoffs(node) = number_of_backoffs(node) + 1;
								backoff_exponent(node) = min(backoff_exponent(node) + 1, th.MAC_MAX_BE);
								if(number_of_backoffs(node) > th.MAC_MAX_CSMA_BACKOFFS)
									%CSMA failed!
									if(log_arg > 0)
										%th.write_log([num2str(th.m_timer*1000) 'ms: CSMA has failed at node ' num2str(node) ' ooooo']);
									end
									th.e_number_of_CSMA_failures = th.e_number_of_CSMA_failures + 1;
									th.m_buffers{node}(1,:) = [];
									th.m_removes = th.m_removes + 1;
									node_stat{node} = 'cap_idle';
								else
									node_stat{node} = 'cap_in_backoff';
									time_to_stay_in_backoff(node) = ceil(rand * (2^(backoff_exponent(node)) -1)) * th.BACKOFF_UNIT + th.m_timer;
									CW_counter(node) = 3 * th.m_time_unit;
									if(log_arg > 0)
										%th.write_log([num2str(th.m_timer*1000) 'ms: Backing off from TX for the ' num2str(number_of_backoffs(node)) ' time until ' num2str(time_to_stay_in_backoff(node)*1000) 'ms at node ' num2str(node) ' to node ' num2str(th.m_cluster_coordinator(node)) ' meas_energy=' num2str(energy) ' ,th_energy=' num2str(energy_th) ' at freq=' num2str(th.m_freq_list(node)) ' +++++++']);
									end
								end
							end
						case 'cap_waiting_ack'
							if(th.wait_for_ack(node,th.m_freq_list(node)) == true)
								%TX was successful!
								if(log_arg > 0)
									%th.write_log([num2str(th.m_timer*1000) 'ms: -- ACK is RXed at node=' num2str(node) ' from node ' num2str(th.m_cluster_coordinator(node)) ' with seq_num=' num2str(bi2de(th.m_seq_numbers{node}))]);
								end
								th.m_buffers{node}(1,:) = [];
								th.m_removes = th.m_removes + 1;
								node_stat{node} = 'cap_idle';
							else
								if(time_to_wait_for_ack(node) <= th.m_timer)
									%TX has failed!
									if(log_arg > 0)
										%th.write_log([num2str(th.m_timer*1000) 'ms: -- ACK is NOT RXed at node=' num2str(node) ' from node ' num2str(th.m_cluster_coordinator(node)) ' seq_number=' num2str(bi2de(th.m_seq_numbers{node})) ' !!!!!!!!!!']);
									end
									node_stat{node} = 'cap_idle';
									th.e_number_of_packet_drops = th.e_number_of_packet_drops + 1;
								end
							end
						case 'cap_in_tx'
							if(time_to_end_tx(node) <= th.m_timer)
								node_stat{node} = 'cap_waiting_ack';
							end
						case 'cap_in_backoff'
							if(time_to_stay_in_backoff(node) <= th.m_timer)
								node_stat{node} = 'cap_perform_csmaca';
							end
					end
				end
				end
				th.m_timer = th.m_timer + th.m_time_unit;
				th.m_channel_holder.release_all_memories_v2(th.m_timer);
				if(th.m_release_memory_timer <= th.m_timer)
%					th.m_channel_holder.release_all_memories;
					th.m_release_memory_timer = th.m_release_memory_timer + th.m_time_unit * 50;
				end
				th.p_arrange_gateway_content;
				if((log_arg > 0) & (length(th.m_results) > 1))
					if((th.m_results{end}.served_nodes) > (th.m_results{end-1}.served_nodes))
						%th.write_log([num2str(th.m_timer*1000) 'ms: a new data packet is delivered to the GATEWAY node: ' num2str(length(th.m_results{end}.served_nodes)) ' nodes served.']);
						th.write_log(th.m_results{end});
					end
				end
				%th.write_log(['adds= ' num2str(th.m_adds) ' removes= ' num2str(th.m_removes) ' gateway buffer len=' num2str(length(th.m_gateway_buffer)) ' their difference: ' num2str(th.m_adds - th.m_removes + length(th.m_gateway_buffer)) '  .']);
				if(log_arg > 1)
					th.write_log(th.m_results{end});
				end
				if(th.m_results{end}.served_nodes == th.m_sensor_depl.get_params.m_number_of_nodes)
					still_full = false;
					th.write_log(th.m_results{end});
					th.write_log([num2str(th.m_timer*1000) 'ms: SIMULATION IS FINISHED.']);
					break;
				end
				still_full = false;
				for node = 1:th.m_sensor_depl.get_params.m_number_of_nodes
					if(length(th.m_buffers{node} > 0))
						still_full = true;
						break;
					end
				end
				if(th.m_timer >= th.PF_END_TIME)
					still_full = false;
				end
				if((log_arg > 0) & (still_full == false))
					th.write_log(th.m_results{end});
					th.write_log([num2str(th.m_timer*1000) 'ms: SIMULATION IS FINISHED.']);
				end
			end
		end
		function p_arrange_gateway_content(th)
			time_index = length(th.m_decoded_messages) + 1;
			if(time_index ==1)
				th.m_decoded_messages{time_index} = zeros(th.m_sensor_depl.get_params.m_number_of_nodes,1);
			else
				th.m_decoded_messages{time_index} = th.m_decoded_messages{time_index -1};
			end
			served_nodes = [];
			unit_packet_len = th.m_packet_len + 8;
			for i = 1:length(th.m_gateway_buffer)
				num_sub_packets = length(th.m_gateway_buffer{i}) / unit_packet_len;
				for u_i = 1:num_sub_packets
					sub_packet_binary = th.m_gateway_buffer{i}((u_i-1)*unit_packet_len + 1:u_i * unit_packet_len);
					node_Index = bi2de(sub_packet_binary(1:8));
					if((node_Index > 0 ) & (node_Index <= th.m_sensor_depl.get_params.m_number_of_nodes) )
						binaryMessage = sub_packet_binary(9:end);
						th.m_decoded_messages{time_index}(node_Index) = th.m_q.convert_binary_to_q_val(binaryMessage);
						if(isempty(find(served_nodes == node_Index)))
							served_nodes = [served_nodes , node_Index];
						end
					end
				end
			end 
			signal_power = norm(th.m_original_messages,2);
			noise_power = norm(th.m_original_messages - th.m_decoded_messages{time_index},2);
			res_snr = 20*log10(signal_power / noise_power);
			delay = th.m_timer;
			%res.decoded_messages = th.m_decoded_messages{time_index};
			%res.original_messages = th.m_original_messages;
			res.decoding_snr = res_snr;
			res.delay = delay * 1000; 	%in milliseconds
			res.signal_power = signal_power;
			res.noise_power = noise_power;
			res.served_nodes = length(served_nodes);
			res.e_number_of_backoffs = th.e_number_of_backoffs;
			res.e_number_of_inter_node_tx = th.e_number_of_inter_node_tx;
			res.e_number_of_packet_drops = th.e_number_of_packet_drops;
			res.e_number_of_CSMA_failures = th.e_number_of_CSMA_failures;
			res.total_tx_energy = th.m_channel_holder.get_total_tx_energy;
			res.packet_len = th.m_packet_len;
			th.m_results{time_index} = res;
			this_res = th.m_results;
			%whos('this_res');
		end
		function [res,energy,coordinator_node] = wait_for_beacon(th,rx_node,rx_freq)
			res = false;
			t_at = th.m_timer;
			energy = th.m_channel_holder.measure_energy(rx_node,rx_freq,t_at,5 * th.m_time_unit);
			coordinator_node = [];
			binary_string = th.m_channel_holder.read_binary_string(rx_node,rx_freq,th.node_RX_index(rx_node),th.m_timer,-1);
			packets_ = th.m_mac_node{rx_node}.decode_binary_string_to_mac_pay_loads(binary_string);
			index_0 = th.node_RX_index(rx_node);
			for p_ind = 1:length(packets_)
				if(packets_{p_ind}.flag == false)
					continue;
				end
				th.node_RX_index(rx_node) = packets_{p_ind}.end_index + index_0;
				th.m_channel_holder.release_bits_before(rx_node,rx_freq,th.node_RX_index(rx_node));
				if(strcmp(packets_{p_ind}.frame_type,'MAC_BEACON_FRAME') == false)
					continue;
				end
				m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.src_add);
				m_dest_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.dest_add);
				coordinator_node = m_src_node;
				if(m_src_node ~= th.m_cluster_coordinator(rx_node))
					continue;
				end
				%IF ALL OK!
				res = true;
			end
		end
		function res = wait_for_ack(th,rx_node,rx_freq)
			res = false;
			binary_string = th.m_channel_holder.read_binary_string(rx_node,rx_freq,th.node_RX_index(rx_node),th.m_timer,-1);
			packets_ = th.m_mac_node{rx_node}.decode_binary_string_to_mac_pay_loads(binary_string);
			index_0 = th.node_RX_index(rx_node);
			for p_ind = 1:length(packets_)
				if(packets_{p_ind}.flag == false)
					continue;
				end
		%		th.write_log(['-- a packet is detected at node ' num2str(rx_node) ',freq=' num2str(rx_freq)]);
		%		th.write_log(packets_{p_ind});
				th.node_RX_index(rx_node) = index_0 + packets_{p_ind}.end_index;
				th.m_channel_holder.release_bits_before(rx_node,rx_freq,th.node_RX_index(rx_node));
				if(strcmp(packets_{p_ind}.frame_type,'MAC_ACK_FRAME') == false)
					continue;
				end
				m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.src_add);
				m_dest_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.dest_add);
				m_seq_number = packets_{p_ind}.seq_number;
				if(m_dest_node ~= rx_node)
					continue;
				end
				if(th.m_seq_numbers{rx_node} ~= m_seq_number)
					continue;
				end
				%IF ALL OK!
				res = true;
			end
		end
		function [flag,pay_load] = wait_for_data(th,rx_node,rx_freq)
			flag = false;
			pay_load = [];
			binary_string = th.m_channel_holder.read_binary_string(rx_node,rx_freq,th.coordinator_RX_index(rx_node),th.m_timer,-1);
			packets_ = th.m_mac_coordinator{rx_node}.decode_binary_string_to_mac_pay_loads(binary_string);
			index_0 = th.coordinator_RX_index(rx_node);
			for p_ind = 1:length(packets_)
				if(packets_{p_ind}.flag == false)
					continue;
				end
				th.coordinator_RX_index(rx_node) = index_0 + packets_{p_ind}.end_index;
				th.m_channel_holder.release_bits_before(rx_node,rx_freq,th.coordinator_RX_index(rx_node));
				if(strcmp(packets_{p_ind}.frame_type,'MAC_DATA_FRAME') == false)
					continue;
				end
				m_src_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.src_add);
				m_dest_node = th.m_sensor_depl.get_node_index_from_mac_address(packets_{p_ind}.addresses.dest_add);
				if(packets_{p_ind}.addresses.dest_add ~= th.m_mac_coordinator{rx_node}.get_mac_address)
					continue;
				end
				if(m_src_node == -1)
					continue;
				end
				if(m_dest_node == -1)
					continue;
				end
				if( rx_node ~= m_dest_node)
					continue;
				end
				if( rx_node ~= th.m_cluster_coordinator(m_src_node))
					continue;
				end
				if(packets_{p_ind}.pay_load.getSize ~= th.m_packet_len + 8)
					continue;
				end
				%IF ALL OK!
				flag = true;
				pay_load = packets_{p_ind};
			end
		end	
		function [signal_and_IFS_end_time,signal,end_wait_for_ack,time_end_of_data_sig_only,m_seq_number] = get_tx_binary_time_duration(th,binary,node,time_at)
			src_node = node;
			dest_node = th.m_cluster_coordinator(src_node);
			this_mac = th.m_mac_node{src_node};
			m_ack_req = 1;
			m_dest_panID = th.m_mac_coordinator{dest_node}.get_mac_address;
			m_dest_add = th.m_mac_coordinator{dest_node}.get_mac_address;
			m_src_panID = th.m_mac_node{src_node}.get_mac_address;
			m_src_add = th.m_mac_node{src_node}.get_mac_address;
			m_seq_number = rand(1,8) > .5 ;
			data_packet = packet_general;
			data_packet.addToEnd(binary);
			mac_packet = th.m_mac_node{src_node}.create_mac_data_frame(m_ack_req,m_dest_panID,m_dest_add,m_src_panID,m_src_add,m_seq_number,data_packet);
			signal = th.m_mac_node{src_node}.convert_mac_packet_to_signal(mac_packet,time_at);
			signal_and_IFS_end_time = signal.get_end_time;% + th.m_mac_node{src_node}.calculate_IFS_signal_time(mac_packet.getSize);
			time_end_of_data_sig_only = signal.get_end_time;

			%For Ack Frame
			ack_packet = th.m_mac_coordinator{dest_node}.create_mac_ack_frame(m_src_panID,m_src_add,m_dest_panID,m_dest_add,m_seq_number);
			ack_signal = th.m_mac_coordinator{dest_node}.convert_mac_packet_to_signal(ack_packet,time_end_of_data_sig_only + th.m_time_unit);
			end_wait_for_ack = ack_signal.get_end_time + th.m_mac_node{src_node}.calculate_IFS_signal_time(mac_packet.getSize);
		end
		function [channel_cleared,energy,energy_th] = is_channel_cleared(th,rx_node)
			rx_freq = th.m_freq_list(rx_node);
			energy_th = 10^((th.m_sensor_depl.get_params.m_min_rx_sig_power - 35 )/ 10) * th.ENERGY_DETECTION_TIME_WINDOW_UNITS * 10^(-3);
			[energy,flag] = th.m_channel_holder.measure_energy(rx_node,rx_freq,th.m_timer,th.ENERGY_DETECTION_TIME_WINDOW_UNITS * th.m_time_unit);
			if(flag ~= 1)
				th.write_log('CHANNEL HOLDER ERROR!');
			end
			if( energy > energy_th )
				channel_cleared = false;
			else
				channel_cleared = true;
			end
		end
		function allocatie_frequencies(th)
			V = [1:length(th.m_coordinators)];
			
			
			E = th.m_sensor_depl.m_ht_list;			
			% From: http://armanboyaci.com/?p=487				
			n = length(V);
			coloring = zeros(n,1);			
			%available_colors = 1;			
			available_colors = length(th.m_freqs_array);			
			% Start with the node that has the maximum degree.			
			% Color the current node with the lowest available color.			
			% Select the next node by selecting the node with the maximum degree of saturation. 			
			% This means that you have to select the node that has the most number of unique neighboring colors. 			
			% In case of a tie, use the node with the largest degree.			
			% Goto step 2. until all nodes are colored.			
			% Degrees			
			for i = V
				v = i;			    
				Degrees(i,1) = size([E(find(E(:,1)==v),2); 
				E(find(E(:,2)==v),1)],1);			
			end			
			% Degrees of saturation			
			Degrees_of_saturation = zeros(n,1);			
			% Coloring			
			for i=V	    
				if i == 1				
					[value index] = max(Degrees);				
					v = index(1);				
					coloring(v) = 1;				
					assigned_color_v = 1;			    
				else				
					Uncolored = find(coloring==0);				
					index_temp = find(Degrees_of_saturation(Uncolored)==max(Degrees_of_saturation(Uncolored)));		
					index = Uncolored(index_temp);				
					if(size(index,1)>1)				    
						[value1 index1] = max(Degrees(index));				    
						v = index(index1);				
					else				    
						v = index;				
					end				
					% Assign first available color to v				
					neighbors = [E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)];				
					for j=1:available_colors				    
						if size(find(coloring(neighbors)==j),1)==0					
							coloring(v) = j;					
							assigned_color_v = j;					
							break;				    
						end				
					end				
					if coloring(v) == 0	
						%Number of frequencies are not enough!					
						flag = -1;					
						rr = randperm(available_colors);					
						coloring(v) = rr(1);					
						assigned_color_v = coloring(v);					    
						%available_colors = available_colors + 1;					    
						%coloring(v) = available_colors;					    
						%assigned_color_v = available_colors;				
					end			    
				end			    
				% Update Degrees of saturation			    
				neighbors_v = [E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)];			    
				for j=1:size(neighbors_v,1)			       
					u = neighbors_v(j);			       
					neighbors_u = [E(find(E(:,1)==u),2); E(find(E(:,2)==u),1)];			       
					if size(find(coloring(neighbors_u)==assigned_color_v),1) == 1				   
						Degrees_of_saturation(u,1) = Degrees_of_saturation(u,1) + 1;			       
					end			    
				end				
				th.m_coordinator_freq = coloring;
			end
		end
		function len = write_log(th,text)
			if(th.m_write_log==false)
				return;
			end
			disp(text);
			%fID = fopen([th.m_save_file_name '_log.txt'],'a');
			if(isstruct(text))
				%c = struct2cell(text);
				%len = fprintf(fID,c{:});
			else
				%len = fprintf(fID,[text '\n']);
			end
		end
		function remove_multiple_copies(th,node)
			cnt = 1;
			while(cnt <= length(th.m_buffers{node}))
				for i = size(th.m_buffers{node},1) :-1: cnt + 1
					if(th.m_buffers{node}(cnt,:) == th.m_buffers{node}(i,:))
						th.m_buffers{node}(i,:) = [];
					end
				end
				cnt = cnt + 1;
			end
		end
end
end
