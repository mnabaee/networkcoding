classdef phy_module < handle
	properties (Hidden)
		m_modulator;
	end
	methods
		function th_phy = phy_module(in_mod)
			th_phy.m_modulator = in_mod;
		end
		function p = create_phy_packet(th_phy,pay_load)
			m_preamble = zeros(1,4*8);
			m_SFD = [1 1 1 0 0 1 0 1];
			pay_load_copy = pay_load.clone;
			if(mod(pay_load_copy.getSize,8)~=0)
				pay_load_copy.addToEnd(zeros(1,8-mod(pay_load_copy.getSize,8)));
			end
			if(pay_load_copy.getSize/8 >= 2^7)
				error('PHY payload is too big!');
			end
			m_len = de2bi(round(pay_load_copy.getSize/8),7);
			m_PHR(1,1:7) = m_len;
			m_PHR(1,8) = [0]; %RESERVED BIT!
			p = packet_general();
			p.addToEnd(m_preamble);
			p.addToEnd(m_SFD);
			p.addToEnd(m_PHR);
			p.addToEnd(pay_load_copy.popFromBegin(pay_load_copy.getSize));
		end
		function [mod_sig,ppdu]=create_after_phy_signal(th_phy,pay_load,time_at);
			ppdu = th_phy.create_phy_packet(pay_load);
			mod_sig = th_phy.m_modulator.modulate_phy_packet(ppdu,time_at);
		end
		%De-functions
		function [pay_load_packets_array,flag_values,end_indices] = decode_binary_string_to_phy_packets(th_phy,binary_string)
			pay_load_packets_array = [];
			flag_values = [];
			end_indices = [];
		 	%Find Preambles in the binary string
			index = 1;
			preamble_locations = [];
			while(index <= length(binary_string))
				if(index+5*8-1 <= length(binary_string))
					if(binary_string(index:index+5*8-1) == [zeros(1,4*8),1 1 1 0 0 1 0 1])
						%a preamble is discovered
						preamble_locations = [preamble_locations index];
						index = index + 5* 8;
					else
						index = index + 1;
					end
				else
					break;
				end
			end
			%Detach each binary string in a separate string and Process each
			for i=1:length(preamble_locations)
				if(i==length(preamble_locations))
					this_b_str = binary_string(preamble_locations(i):end);
					end_indices{i} = length(binary_string);
				else
					this_b_str = binary_string(preamble_locations(i):preamble_locations(i+1)-1);
					end_indices{i} = preamble_locations(i+1) - 1;
				end
				[pay_load_packets_array{i},flag_values{i}] = th_phy.decode_binary_string_to_phy_packet(this_b_str);
			end
			if(length(preamble_locations)==0)
		%		disp('PHY: no preamble was detected!');
			end
		end
		function [pay_load_packets_array,flag_values,end_indices] = decode_mod_sig_to_phy_packets(th_phy,rx_sig)
			binary_string = th_phy.m_modulator.demodulate_signal_to_phy_packet(rx_sig).get_all;	
			[pay_load_packets_array,flag_values,end_indices] = th_phy.decode_binary_string_to_phy_packets(binary_string);
		end
		function [pay_load_packet,OK_flag] = decode_binary_string_to_phy_packet(th_phy,b_str)
			OK_flag = false;
			pay_load_packet = packet_general;
			if(length(b_str) < 6*8)
			%	disp('PHY: small size1!');
				return;
			end
			m_headers = b_str(1:6*8);
			m_preamble = m_headers(1:4*8);
			m_SFD = m_headers(4*8+1:5*8);
			m_PHR = m_headers(5*8+1:6*8);
			m_pay_load_len = bi2de(m_PHR(1:7));
			if(sum(abs(m_preamble - zeros(1,4*8))) > 0)
			%	disp('PHY: wrong preamble!');
				return;
			end
			if(sum(abs(m_SFD - [1 1 1 0 0 1 0 1])) > 0)
			%	disp('PHY: wrong SFD!');
				return;
			end
			if(length(b_str) - 6*8 < m_pay_load_len * 8)
			%	disp('PHY: small payload length!');
				return;
			end
			pay_load_packet.addToEnd(b_str(6*8+1:6*8+m_pay_load_len*8));
			OK_flag = true;
			return;
		end
		function [pay_load,OKed] = decode_mod_signal(th_phy,rx_sig)
		oct_len = th_phy.m_modulator.get_base_pulse.get_time_duration * 16.5 * 2;
		pay_load = packet_general;
		OKed = false;
		if(rx_sig.get_time_duration < oct_len * 6 )
			return;
		end
		m_headers = th_phy.m_modulator.demodulate_signal_to_phy_packet(rx_sig.get_sample_data_partially(rx_sig.get_init_time,rx_sig.get_init_time + oct_len * 6));
		m_preamble = m_headers.popFromBegin(4*8);
		m_SFD = m_headers.popFromBegin(8);
		m_PHR = m_headers.popFromBegin(8);
		m_pay_load_len = bi2de(m_PHR(1:7));
		if(sum(abs(m_preamble - zeros(1,4*8))) > 0)
			return;
		end
		if(sum(abs(m_SFD - [1 1 1 0 0 1 0 1])) > 0)
			return;
		end
		if(rx_sig.get_time_duration < oct_len * (6+m_pay_load_len))
			%return;
		end
		pay_load = th_phy.m_modulator.demodulate_signal_to_phy_packet(rx_sig.get_sample_data_partially(rx_sig.get_init_time + oct_len * 6,rx_sig.get_init_time + oct_len * (6+m_pay_load_len)));
		OKed = true;
		end
		function [pay_load,OKed] = decode_phy_packet(th_phy,p);
			pay_load = packet_general;
			OKed = false;
			p_cp = p.clone;
			if(p_cp.getSize >= 4*8)
				m_preamble = p_cp.popFromBegin(4*8);
				if(m_preamble == zeros(1,4*8))
					if(p_cp.getSize >= 8)
						m_SFD = p_cp.popFromBegin(8);
						if(m_SFD == [1 1 1 0 0 1 0 1])
							if(p_cp.getSize >= 8)
								m_PHR = p_cp.popFromBegin(8);
								m_pay_load_len = bi2de(m_PHR(1:7));
								if(p_cp.getSize == m_pay_load_len)
									pay_load.addToEnd(p_cp.popFromBegin(m_pay_load_len * 8));
									OKed = true;
								end
							end
						end
					end
				end
			end
		end
	end
end



