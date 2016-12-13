classdef mac_module < handle
	properties (Hidden)
		m_mac_address;
		m_pan_id;
		m_beacon_pay_load_field;
		m_associated_devices;
	
		m_phy;
	end
	methods
		function th_mac = mac_module(mac_address,pan_id,phy)
			aMaxBeaconPayloadLength = 3;
			th_mac.m_mac_address = mac_address;
			th_mac.m_pan_id = pan_id;
			th_mac.m_associated_devices = [];
			th_mac.m_beacon_pay_load_field = rand(1, aMaxBeaconPayloadLength * 8) > .5;
			th_mac.m_phy = phy;
		end
		function address = get_mac_address(th_mac)
				address = th_mac.m_mac_address;
		end
		function associate_device(th_mac,ass_mac_address,ass_pan_id)
			th_mac.m_associated_devices{length(th_mac.m_associated_devices)+1}.m_mac_address = ass_mac_address;
			th_mac.m_associated_devices{length(th_mac.m_associated_devices)}.m_pan_id = ass_pan_id;

		end
		function resTime = calculate_IFS_signal_time(th_mac,mpdu_size)
				%IFS: each symb = 4bits , for 2500meg, IFS should be 12/40 symbols= 6/20 octets
				aMaxSIFSFrameSize = 18; %octets
				IFS_signal_delay_time_0 = th_mac.m_phy.m_modulator.get_base_pulse.get_time_duration * 16.5;
			if(mpdu_size <= aMaxSIFSFrameSize * 8)
				resTime = IFS_signal_delay_time_0 * 12; 
			else
				resTime = IFS_signal_delay_time_0 * 40; 
			end
		end
		function [res_payload_FCS]=calculate_FCS(th_mac,payload_bitstream);
			res_payload_FCS=zeros(1,16);      % Remainder register initialization
			for index=1:length(payload_bitstream)
			    s1=bitxor((payload_bitstream(index)),res_payload_FCS(1));    % XOR between r0 and the message bit
			    s2=bitxor(s1,res_payload_FCS(12));        % XOR r11
			    s3=bitxor(s1,res_payload_FCS(5));         % XOR r4
			    res_payload_FCS=[res_payload_FCS(2:16) s1];             % Left shift of r, and r15 update
			    res_payload_FCS(11)=s2;                   % r10 update
			    res_payload_FCS(4)=s3;                    % r3 update
			end
		end
		function [p] = create_mac_packet(th_mac,m_frame_type,m_frame_pending,m_ack_req,m_panID_comp,m_dest_add_mode,m_src_add_mode,m_seq_number,m_dest_panID,m_dest_add,m_src_panID,m_src_add,mac_pay_load_packet)
			mac_pay_load_packet_cp = mac_pay_load_packet.clone;
			p = packet_general();
			m_frame_version = [0 0];
			m_sec_enb = [0];
			m_frame_control = [m_frame_type,m_sec_enb,m_frame_pending,m_ack_req,m_panID_comp,0,0,0,m_dest_add_mode,m_frame_version,m_src_add_mode];
			p.addToEnd(m_frame_control);
			p.addToEnd(m_seq_number);
			m_addressing_field = [m_dest_panID , m_dest_add , m_src_panID , m_src_add];
			p.addToEnd(m_addressing_field);
			m_aux_sec_header = [];
			p.addToEnd(m_aux_sec_header);
			mac_pay_load = mac_pay_load_packet_cp.popFromBegin(mac_pay_load_packet_cp.getSize);
			p.addToEnd(mac_pay_load);	
			m_FCS = th_mac.calculate_FCS(mac_pay_load);
			p.addToEnd(m_FCS);
		end
		function [p] = create_mac_beacon_frame(th_mac,m_src_panID,m_src_add)
			%MHR Field
			m_frame_type = [0 0 0];
			m_frame_pending = 0;
			m_ack_req = 0;
			m_panID_comp = 0;
			m_dest_add_mode = [0 0];
			m_src_add_mode = [1 0];
			m_dest_panID = [];
			m_dest_add = [];
			m_seq_number = rand(1,8)>.5;
			%PayLoad
				%superframe specification field
				m_beacon_order = [0 0 0 0];
				m_superframe_order = [0 0 0 0];
				m_final_cap_slot = [0 0 0 0];
				m_battery_life_expansion = [0];
				m_pan_coordinator = [1];
				m_association_permit = [1];
				m_superframe_spec = [m_beacon_order,m_superframe_order,m_final_cap_slot,m_battery_life_expansion,0,m_pan_coordinator,m_association_permit];
				%GTS
				m_GTS_spec_field = zeros(1,8);
				m_GTS_directions_field = [];
				m_GTS_list = [];
				m_GTS_fields = [m_GTS_spec_field m_GTS_directions_field m_GTS_list];
				%Pending Address Fields
			        m_pending_address_spec_field = [0 0 0,0 0, 0 0 0, 0];	
				m_address_list = [];
				m_pending_address_fields = [m_pending_address_spec_field,m_address_list];
				%Beacon Payload Field
				m_beacon_pay_load_field = th_mac.m_beacon_pay_load_field;
			mac_pay_load = [m_superframe_spec,m_GTS_fields,m_pending_address_fields,m_beacon_pay_load_field];
			mac_pay_load_packet = packet_general;
			%mac_pay_load = str2num(mac_pay_load);
			mac_pay_load_packet.addToEnd(mac_pay_load);
			p = th_mac.create_mac_packet(m_frame_type,m_frame_pending,m_ack_req,m_panID_comp,m_dest_add_mode,m_src_add_mode,m_seq_number,m_dest_panID,m_dest_add,m_src_panID,m_src_add,mac_pay_load_packet);
		end
		function [p] = create_mac_data_frame(th_mac,m_ack_req,m_dest_panID,m_dest_add,m_src_panID,m_src_add,m_seq_number,data_packet)
			%MHR Field
			m_frame_type = [0 0 1];
			m_frame_pending = 0;
			m_panID_comp = 0;
			m_dest_add_mode = [1 0];
			m_src_add_mode = [1 0];
			%PayLoad
			mac_pay_load_packet = data_packet.clone;
			p = th_mac.create_mac_packet(m_frame_type,m_frame_pending,m_ack_req,m_panID_comp,m_dest_add_mode,m_src_add_mode,m_seq_number,m_dest_panID,m_dest_add,m_src_panID,m_src_add,mac_pay_load_packet);
		end
		function [p] = create_mac_ack_frame(th_mac,m_dest_panID,m_dest_add,m_src_panID,m_src_add,m_seq_number)
			%MHR Field
			m_frame_type = [0 1 0];
			m_ack_req  =[0];
			m_frame_pending = 0;
			m_panID_comp = 0;
			m_dest_add_mode = [1 0];
			m_src_add_mode = [1 0];
			%PayLoad
			mac_pay_load_packet = packet_general;
			p = th_mac.create_mac_packet(m_frame_type,m_frame_pending,m_ack_req,m_panID_comp,m_dest_add_mode,m_src_add_mode,m_seq_number,m_dest_panID,m_dest_add,m_src_panID,m_src_add,mac_pay_load_packet);
		end
		function [signal,phy_packet] = convert_mac_packet_to_signal(th_mac,mac_frame,time_at)
			[signal,phy_packet] = th_mac.m_phy.create_after_phy_signal(mac_frame,time_at);
		end
		function [dn_superframe_sig,phy_packets,mac_frames]=schedule_superframe_dn_allGTS(th_mac,mac_pay_loads_array,pay_loads_seq_numbers_array,time_0)
			if(length(mac_pay_loads_array) ~= length(th_mac.m_associated_devices))
				error('Length of mac_pay_loads_array has to be the same as the number of associated devices!');
			end
			m_src_panID = th_mac.m_pan_id;
			m_src_add = th_mac.m_mac_address;
			%Create Beacon Frame
			mac_beacon_frame = th_mac.create_mac_beacon_frame(m_src_panID,m_src_add);	
			mac_frames{1} = mac_beacon_frame;
			[beacon_sig,phy_packets{1}]=th_mac.m_phy.create_after_phy_signal(mac_beacon_frame,time_0);
			time_at = time_0 + beacon_sig.get_time_duration + th_mac.calculate_IFS_signal_time(mac_beacon_frame.getSize) ;
			%Create Data Frames
			data_pay_load_size = mac_pay_loads_array{1}.getSize;
			for node = 1:length(mac_pay_loads_array)
				if(mac_pay_loads_array{node}.getSize ~= data_pay_load_size)
					error('Size of all data loads should be the same!');
				end
				m_dest_panID = th_mac.m_associated_devices{node}.m_pan_id;
				m_dest_add = th_mac.m_associated_devices{node}.m_mac_address;
				m_seq_number = pay_loads_seq_numbers_array{node};
				mac_data_frames{node} = th_mac.create_mac_data_frame([0],m_dest_panID,m_dest_add,m_src_panID,m_src_add,m_seq_number,mac_pay_loads_array{node});
				mac_frames{1+node} = mac_data_frames{node};
				[data_sig{node},phy_packets{node+1}] = th_mac.m_phy.create_after_phy_signal(mac_data_frames{node},time_at);
				time_at = time_at + data_sig{node}.get_time_duration + th_mac.calculate_IFS_signal_time(mac_data_frames{node}.getSize);
			end	
			%Merge Signals together
			tVec = [beacon_sig.get_init_time:beacon_sig.get_time_res:data_sig{end}.get_end_time];
			dn_superframe_sig = signal_continous_time(tVec(1),tVec(end),tVec * 0);
			dn_superframe_sig.set_as_part(beacon_sig);
			for node =1:length(data_sig)
				dn_superframe_sig.set_as_part(data_sig{node});
			end
		end
		%Decrept MAC packets
		function [packets_] = decode_binary_string_to_mac_pay_loads(th_mac,binary_string)
			packets_ = [];
			[mac_packets,phy_dec_flags,end_indices] = th_mac.m_phy.decode_binary_string_to_phy_packets(binary_string);
			for i = 1:length(mac_packets)
				%if(phy_dec_flags{i}==false)
				%	disp(['PHY packet with flag=' num2str(phy_dec_flags{i})]);
				%end
				if(phy_dec_flags{i}==true)
					[pay_load_packet{i},flag{i},mac_frame_type{i},m_seq_number{i},m_dest_pan_id{i},m_dest_add{i},m_src_pan_id{i},m_src_add{i},m_mac_frame_size{i}] = th_mac.decode_mac_frame(mac_packets{i});
					packets_{i}.pay_load = pay_load_packet{i}.clone;
					packets_{i}.flag = flag{i};	
					packets_{i}.frame_type = mac_frame_type{i};
					packets_{i}.addresses.dest_panID = m_dest_pan_id{i};
					packets_{i}.addresses.src_panID = m_src_pan_id{i};
					packets_{i}.addresses.dest_add = m_dest_add{i};
					packets_{i}.addresses.src_add = m_src_add{i};
					packets_{i}.seq_number = m_seq_number{i};
					packets_{i}.mac_frame_size = m_mac_frame_size{i};
					packets_{i}.end_index = end_indices{i};
				else
					packets_{i}.flag =false;
				end
			end
		end
		function [packets_] = decode_mod_sig_to_pay_loads(th_mac,mod_sig)
			packets_ = [];
			[mac_packets,phy_dec_flags,end_indices] = th_mac.m_phy.decode_mod_sig_to_phy_packets(mod_sig);
			for i = 1:length(mac_packets)
				if(phy_dec_flags{i}==true)
					[pay_load_packet{i},flag{i},mac_frame_type{i},m_seq_number{i},m_dest_pan_id{i},m_dest_add{i},m_src_pan_id{i},m_src_add{i},m_mac_frame_size{i}] = th_mac.decode_mac_frame(mac_packets{i});
					packets_{i}.pay_load = pay_load_packet{i}.clone;
					packets_{i}.flag = flag{i};	
					packets_{i}.frame_type = mac_frame_type{i};
					packets_{i}.addresses.dest_panID = m_dest_pan_id{i};
					packets_{i}.addresses.src_panID = m_src_pan_id{i};
					packets_{i}.addresses.dest_add = m_dest_add{i};
					packets_{i}.addresses.src_add = m_src_add{i};
					packets_{i}.seq_number = m_seq_number{i};
					packets_{i}.mac_frame_size = m_mac_frame_size{i};
					packets_{i}.end_index = end_indices{i};
				else
					packets_{i}.flag = false;
				end
			end
		end
		function [pay_load_packet,flag,mac_frame_type,m_seq_number,m_dest_pan_id,m_dest_add,m_src_pan_id,m_src_add,m_mac_frame_size] = decode_mac_frame(th_mac,p)
			p_cp = p.clone;
			pay_load_packet = packet_general;
			flag = false;
			m_mac_frame_size = p_cp.getSize;
			mac_frame_type = [];
			m_seq_number = [];
			m_dest_pan_id = [];
			m_dest_add = [];
			m_src_pan_id = [];
			m_src_add = [];
			if(p_cp.getSize < (2+1)*8)
			%	disp('MAC: small size!');
				return;
			end
			m_frame_control_field = p_cp.popFromBegin(2*8);
			m_seq_number = p_cp.popFromBegin(8);
			m_frame_type = m_frame_control_field(1:3);
			m_sec_enb = m_frame_control_field(4);
			m_dest_add_mode = m_frame_control_field(11:12);
			m_src_add_mode = m_frame_control_field(15:16);
			m_dest_pan_id = [];
			m_dest_add = [];
			m_src_pan_id = [];
			m_src_add = [];
			if(m_frame_type == [0 0 0])
				mac_frame_type = 'MAC_BEACON_FRAME';
			elseif(m_frame_type == [0 0 1])
				mac_frame_type = 'MAC_DATA_FRAME';
			elseif(m_frame_type == [0 1 0])
				mac_frame_type = 'MAC_ACK_FRAME';
			elseif(m_frame_type == [0 1 1])
				mac_frame_type = 'MAC_COMMAND_FRAME';
			else
				mac_frame_type = 'MAC_RESERVED FRAME';
			end
			if(m_dest_add_mode == [0 0])
				%No addressing Field
			elseif(m_dest_add_mode == [1 0])
				% 16-bit Addressing
				if(p_cp.getSize < 4*8)
			%		disp('MAC: small size2!');
					return;
				end
				m_dest_pan_id = p_cp.popFromBegin(2*8);
				m_dest_add = p_cp.popFromBegin(2*8);
			elseif(m_dest_add_mode == [1 1])
				% 16-bit Addressing
				if(p_cp.getSize < 10*8)
			%		disp('MAC: small size2!');
					return;
				end
				m_dest_pan_id = p_cp.popFromBegin(2*8);
				m_dest_add = p_cp.popFromBegin(8*8);
			else
			%	disp('MAC: wrong addressing type!');
				return;
			end	
			if(m_src_add_mode==[0 0])
				%No addressing Field
			elseif(m_src_add_mode == [1 0])
				% 16-bit Addressing
				if(p_cp.getSize < 4*8)
			%		disp('MAC: small size2!');
					return;
				end
				m_src_pan_id = p_cp.popFromBegin(2*8);
				m_src_add = p_cp.popFromBegin(2*8);
			elseif(m_src_add_mode == [1 1])
				% 16-bit Addressing
				if(p_cp.getSize < 10*8)
			%		disp('MAC: small size2!');
					return;
				end
				m_src_pan_id = p_cp.popFromBegin(2*8);
				m_src_add = p_cp.popFromBegin(8*8);
			else
			%	disp('MAC: wrong addressing type!');
				return;
			end	
			%Security Header Aux
			if(m_sec_enb == [0])
				m_sec_header_len = 0;
			else
				m_seq_header_len = 0;
			end
			m_pay_load_len = p_cp.getSize - 2*8;
			if(m_pay_load_len < 0)
			%	disp('MAC: pay_load_len is negative!');
				return;
			end
			m_pay_load_bit_str = p_cp.popFromBegin(m_pay_load_len);
			m_FCS = p_cp.popFromBegin(2*8);
			%Verify FCS and issue flags
			calc_FCS = th_mac.calculate_FCS(m_pay_load_bit_str);
			if(sum(abs(calc_FCS - m_FCS)) > 0)
			%	disp('MAC: wrong FCS!');
			%	disp(['   decoded FCS: ' num2str(m_FCS)]);
			%	disp(['calculated FCS: ' num2str(calc_FCS)]);
				return;
			end
			flag = true;
			pay_load_packet.addToEnd(m_pay_load_bit_str);
			%disp('MAC: successfull!');
			return;
		end
	end
end
