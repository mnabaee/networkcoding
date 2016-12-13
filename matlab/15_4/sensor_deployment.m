classdef sensor_deployment < handle
	properties
		m_t_ht_list;
	end
	properties (Hidden)
		m_location_range;
		m_node_locations;
		m_node_distances;
		m_gateway_node;

		m_tx_power;
		m_min_rx_sig_power;
		m_channel;
		m_channel_holder;

		m_nodes_in_tx_range;
		m_nodes_in_rx_range;
		m_ht_list;
		m_ht_list_interference;
		m_path_to_gateway;

		m_tx_freqs;
		m_rx_freqs;

		m_addresses;	%Each MAC address should be a 16-bit binary string

	end
	methods
		function th_depl = sensor_deployment(channel)
			th_depl.initialize_defaults(channel);
		end
		function res = get_tx_power(th)
			res = th.m_tx_power;
		end
		function mult_coef = get_tx_power_coef(th)
			mult_coef = 10^(th.m_tx_power/10);
		end
		function node = get_node_index_from_mac_address(th,mac_address)
			node = -1;
			if(length(mac_address) ~= length(th.m_addresses{1}))
				return;
			end
			for i = 1:th.get_params.m_number_of_nodes
				if(th.m_addresses{i} == mac_address)
					node = i;
					return;
				end
			end
		end		
		function address = get_address(th,node)
			address = th.m_addresses{node};
		end
		function path = get_path_to_gateway(th_depl,node)
			path = th_depl.m_path_to_gateway{node};
		end
		function [num_freqs,freqs_array,num_time_slots] = set_tx_freqs_for_QNC(th_depl)
			freqs_array = th_depl.get_freqs_array_at_2500;
			num_freqs = length(freqs_array);
			nodes_set = [1 : length(th_depl.m_node_locations)];
			th_depl.find_radio_connected_nodes_minus_dB(5);
			edges_ht_list = th_depl.find_two_hop_connected_nodes_interference;
			edges_ht_list = [edges_ht_list ; th_depl.m_ht_list_interference];
			th_depl.m_t_ht_list = edges_ht_list;
			[res_coloring] = th_depl.graph_coloring_freqs_main(nodes_set,edges_ht_list);
			num_time_slots = 1;
			for node = 1:length(res_coloring)
				th_depl.m_tx_freqs{node}.m_tx_freq = freqs_array(mod(res_coloring(node)-1,num_freqs) + 1);
				th_depl.m_tx_freqs{node}.m_tx_time = floor((res_coloring(node)-1)/num_freqs) + 1;
				num_time_slots = max(th_depl.m_tx_freqs{node}.m_tx_time,num_time_slots);
			end
		end
		function [num_freqs,freqs_array,num_time_slots] = set_tx_freqs_for_QNC_old_version(th_depl)
			freqs_array = th_depl.get_freqs_array_at_2500;
			num_freqs = length(freqs_array);
			nodes_set = [1 : length(th_depl.m_node_locations)];
			edges_ht_list = th_depl.find_two_hop_connected_nodes;
			edges_ht_list = [edges_ht_list ; th_depl.m_ht_list];
			th_depl.m_t_ht_list = edges_ht_list;
			[res_coloring] = th_depl.graph_coloring_freqs_main(nodes_set,edges_ht_list);
			num_time_slots = 1;
			for node = 1:length(res_coloring)
				th_depl.m_tx_freqs{node}.m_tx_freq = freqs_array(mod(res_coloring(node)-1,num_freqs) + 1);
				th_depl.m_tx_freqs{node}.m_tx_time = floor((res_coloring(node)-1)/num_freqs) + 1;
				num_time_slots = max(th_depl.m_tx_freqs{node}.m_tx_time,num_time_slots);
			end
		end
		function res = find_edge(th,head_node,tail_node)
			res = find(ismember(th.m_ht_list,[head_node,tail_node],'rows'));
%			res = find(th.m_ht_list(:,1)==head_node .* th.m_ht_list(:,2)==tail_node);
		end
		function incoming_nodes = get_incoming_nodes(th,node)
			incoming_nodes = th.m_ht_list(find(th.m_ht_list(:,1)==node),2);
		end
		function incoming_edges = get_incoming_edges(th,node)
			incoming_edges = find(th.m_ht_list(:,1)==node);
		end
		function dn_rx_nodes = get_dn_rx_nodes(th,tx_node)
			%dn_rx_nodes = th.m_nodes_in_tx_range{tx_node};
			dn_rx_nodes = th.m_ht_list(find(th.m_ht_list(:,2)==tx_node),1);
		end
		function set_freqs(th_depl,tx_freqs,rx_freqs)
			if((length(tx_freqs) ~= length(th_depl.m_node_locations)) || (length(rx_freqs) ~= length(th_depl.m_node_locations)))
				error('Number of nodes of the frequency array should be the same as the number of nodes!');
			end
			for node =1:length(th_depl.m_node_locations)
				th_depl.m_tx_freqs{node}.m_tx_freq = tx_freqs{node};
				th_depl.m_rx_freqs{node}.m_tx_freq = rx_freqs{node};
			end
		end
		function initialize_defaults(th_depl,channel)
			num_nodes = 50;	%Number of Nodes
			range_in_meter = 250;%280;	%Length of square in which nodes are located
			channel;		%Channel Object
			%JN516x IEEE802.15.4 Wireless Microcontroller
			tx_p_in_dBm = 2.5;	%TX power in dBm
			rx_sensitivity_in_dBm = -95; 	%RX minimum threshold for the received power from the transmitter in dBm

			pick_gateway_mode = 'center';	%center/corner 
			pick_gateway_radius_percentage = .25;	%outer/inner radius percentage [0.00-1.00]
			
			th_depl.initialize(num_nodes,range_in_meter,channel,tx_p_in_dBm,rx_sensitivity_in_dBm,pick_gateway_mode,pick_gateway_radius_percentage);
			th_depl.set_tx_freqs_for_QNC;
		end
		function res = get_params(th_depl)
			res.m_location_range = th_depl.m_location_range;
			res.m_gateway_node = th_depl.m_gateway_node;
			res.m_tx_power = th_depl.m_tx_power;
			res.m_min_rx_sig_power = th_depl.m_min_rx_sig_power;
			
			res.m_number_of_nodes = length(th_depl.m_node_locations);
			res.m_tx_freqs = th_depl.m_tx_freqs;
			res.m_rx_freqs = th_depl.m_rx_freqs;
			res.m_node_distances = th_depl.m_node_distances;
			res.m_channel_holder = th_depl.m_channel_holder;
			res.m_number_of_edges = size(th_depl.m_ht_list,1);
			res.m_ht_list = th_depl.m_ht_list;
			res.m_channel_params = th_depl.m_channel.get_params;
		end
		function initialize(th_depl,num_nodes,range_in_meter,channel,tx_p_in_dBm,rx_sensitivity_in_dBm,pick_gateway_mode,pick_gateway_radius_percentage)
			th_depl.set_random_locations(num_nodes,range_in_meter);
			th_depl.set_channel(channel);
			th_depl.set_power_params(tx_p_in_dBm,rx_sensitivity_in_dBm);
			th_depl.find_radio_connected_nodes;
			if(pick_gateway_mode == 'center')
				th_depl.pick_random_gateway_node(0,pick_gateway_radius_percentage);
			elseif(pick_gateway_mode == 'corner')
				th_depl.pick_random_gateway_node(pick_gateway_radius_percentage,.99);
			else
				error('pick_gateway_mode is not defined!');
			end
			th_depl.find_shortest_routes;
			th_depl.assign_mac_addresses_16_bit;
			th_depl.m_channel_holder = channel_holder(th_depl.m_channel,th_depl);
		end
		function set_time_params(th_depl,time_res,end_time)
			th_depl.m_channel_holder.set_time_params(time_res,end_time);
		end
		function set_channel_holder_freq_time_params(th_depl,freqs,time_res,end_time)
			th_depl.m_channel_holder.set_freq_time_params(freqs,time_res,end_time);
		end
		function initialize_channel_holder_at_2500(th_depl,time_res,end_time)
				th_depl.initialize_channel_holder(th_depl.get_freqs_array_at_2500,time_res,end_time);
		end
		function initialize_channel_holder(th_depl,freqs,time_res,end_time)
			th_depl.m_channel_holder.initialize_freq_time_params(freqs,time_res,end_time);
		end
		function plot_this(th_depl)
			pStr1 = 'ro';
			pStr2 = 'ks';
			hold on;
			for edgeIndex = 1:length(th_depl.m_ht_list)
				head_x = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,1)}.x;
				head_y = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,1)}.y;
				tail_x = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,2)}.x;
				tail_y = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,2)}.y;
				line([tail_x head_x],[tail_y head_y],'LineWidth',1,'Color',[0 1 0]);
			end
			for edgeIndex = 1:length(th_depl.m_ht_list)
				head_x = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,1)}.x;
				head_y = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,1)}.y;
				tail_x = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,2)}.x;
				tail_y = th_depl.m_node_locations{th_depl.m_ht_list(edgeIndex,2)}.y;
				mid_x = tail_x + (head_x-tail_x) * .9;
				mid_y = tail_y + (head_y-tail_y) * .9;
			%	line([mid_x head_x],[mid_y head_y],'LineWidth',1,'Color',[0 0 1]);
			end
			for node = 1:length(th_depl.m_node_locations)
				th_x = th_depl.m_node_locations{node}.x;
				th_y = th_depl.m_node_locations{node}.y;
				text(th_x,th_y,[num2str(th_depl.m_tx_freqs{node}.m_tx_freq) ',' num2str(th_depl.m_tx_freqs{node}.m_tx_time)]);
				plot(th_x,th_y,pStr1,'LineWidth',2);
			end
			node = th_depl.m_gateway_node;
			th_x = th_depl.m_node_locations{node}.x;
			th_y = th_depl.m_node_locations{node}.y;
			plot(th_x,th_y,pStr2,'LineWidth',3);
			grid on;
		end
		function pick_random_gateway_node(th_depl,innerR,outerR)
			Llist = [];
			for node = 1:length(th_depl.m_node_locations)
				radius = sqrt((th_depl.m_node_locations{node}.x-.5*th_depl.m_location_range)^2+(th_depl.m_node_locations{node}.y-.5*th_depl.m_location_range)^2) / sqrt(2) / th_depl.m_location_range;
				if((radius >= innerR)&&(radius<=outerR))
					Llist = [Llist node];
				end
			end
			if(isempty(Llist))
				th_depl.m_gateway_node = randperm(length(th_depl.m_node_locations));
				th_depl.m_gateway_node = th_depl.m_gateway_node(1);
			else
				th_depl.m_gateway_node = randperm(length(Llist));
				th_depl.m_gateway_node = Llist(th_depl.m_gateway_node(1));
			end
			th_depl.find_shortest_routes;
		end
	end
	methods (Hidden)
		function assign_mac_addresses_16_bit(th)
			for node = 1:th.get_params.m_number_of_nodes
				th.m_addresses{node} = de2bi(node,16);
			end
		end
		function set_power_params(th_depl,tx_p,rx_p_th)
			th_depl.m_tx_power = tx_p;
			th_depl.m_min_rx_sig_power = rx_p_th;
		end
		function set_channel(th_depl,in_ch);
			th_depl.m_channel = in_ch;
		end
		function find_radio_connected_nodes_minus_dB(th_depl,dB_difference)
			for node1=1:length(th_depl.m_node_locations)
				for node2=1:length(th_depl.m_node_locations)
					if(node1~=node2)
						if(th_depl.m_channel.calculate_sig_power_at_rx(th_depl.m_tx_power,th_depl.m_node_distances(node1,node2)) > th_depl.m_min_rx_sig_power - dB_difference)

							th_depl.m_ht_list_interference = [th_depl.m_ht_list_interference;[node1,node2]];
						end
					end
				end
			end
		end
		function find_radio_connected_nodes(th_depl)
			for node = 1 : length(th_depl.m_node_locations)
				th_depl.m_nodes_in_tx_range{node} = [];
				th_depl.m_nodes_in_rx_range{node} = [];
			end
			for node1=1:length(th_depl.m_node_locations)
				for node2=1:length(th_depl.m_node_locations)
					if(node1~=node2)
						if(th_depl.m_channel.calculate_sig_power_at_rx(th_depl.m_tx_power,th_depl.m_node_distances(node1,node2)) > th_depl.m_min_rx_sig_power)

							th_depl.m_nodes_in_tx_range{node1} = [th_depl.m_nodes_in_tx_range{node1} node2];
							th_depl.m_nodes_in_rx_range{node2} = [th_depl.m_nodes_in_rx_range{node2} node1];
							th_depl.m_ht_list = [th_depl.m_ht_list;[node1,node2]];
						end
					end
				end
			end
		end
		function set_random_locations(th_depl,num_nodes,range)
			th_depl.m_location_range = range;
			th_depl.m_node_locations = [];
			for i=1:num_nodes
				th_depl.m_node_locations{i}.x = rand * range;
				th_depl.m_node_locations{i}.y = rand * range;
			end
			th_depl.calculate_distances;
		end
		function find_shortest_routes(th_depl)
			for eIndx = 1:size(th_depl.m_ht_list,1)
				weight_vec(eIndx) = th_depl.m_node_distances(th_depl.m_ht_list(eIndx,1),th_depl.m_ht_list(eIndx,2));
			end
			sG = sparse(th_depl.m_ht_list(:,1),th_depl.m_ht_list(:,2),weight_vec * 0 +1);
			for node = 1:length(th_depl.m_node_locations)
				[dist{node},th_depl.m_path_to_gateway{node}] = graphshortestpath(sG,node,th_depl.m_gateway_node); 
%				if((length(th_depl.m_path_to_gateway{node}) > 0)&(node ~= th_depl.m_gateway_node))
%					th_depl.m_path_to_gateway{node} = [th_depl.m_path_to_gateway{node} th_depl.m_gateway_node];
%					disp(th_depl.m_path_to_gateway{node});
%				end
			end
		end
		function calculate_distances(th_depl)
			th_depl.m_node_distances = [];
			for i=1:length(th_depl.m_node_locations)
				for j=1:length(th_depl.m_node_locations)
					th_depl.m_node_distances(i,j) = sqrt((th_depl.m_node_locations{i}.x-th_depl.m_node_locations{j}.x)^2+(th_depl.m_node_locations{i}.y-th_depl.m_node_locations{j}.y)^2);
				end
			end
		end
		function [coloring_res]=graph_coloring_freqs_main(th_depl,nodes_set,edges_ht_list)
			V = nodes_set;
			E = edges_ht_list;
			% From: http://armanboyaci.com/?p=487	
			n = length(V);
			coloring = zeros(n,1);
			available_colors = 1;
			% Degrees
			for i=1:n
			    v = i;
			    Degrees(i,1) = size([E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)],1);
			end
			% Degrees of saturation
			Degrees_of_saturation = zeros(n,1);
			% Coloring
			for i=1:n
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
				if coloring(v) == 0	%Number of frequencies are not enough!
					    available_colors = available_colors + 1;
					    coloring(v) = available_colors;
					    assigned_color_v = available_colors;
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
				coloring_res = coloring;
			end
		end
		function freqs_array = get_freqs_array_at_2500(th_depl)
			%2.5GHz freqs of 15.4
			freqs_array = [];
			for k = 11:26
				freqs_array = [freqs_array , 2405 + 5*(k-11)];
			end
			freqs_array = freqs_array;
		end
		function res_conn_edges = find_two_hop_connected_nodes_interference(th)
			res_conn_edges = zeros(0,2);
			num_nodes = length(th.m_node_locations);
			for node_1 = 1:num_nodes
				outgoing_nodes_1 = th.m_ht_list_interference(find(th.m_ht_list_interference(:,2)==node_1),1);
				for node_2 = 1:num_nodes
					if(node_1 ~= node_2)
						outgoing_nodes_2 = th.m_ht_list_interference(find(th.m_ht_list_interference(:,2)==node_2),1);
						for i = 1:length(outgoing_nodes_2)
							if(~isempty(find(outgoing_nodes_2(i) == outgoing_nodes_1)))
								res_conn_edges = [res_conn_edges ; [node_1 , node_2]];
								break;
							end
						end	
					end
				end
			end
		end
		function res_conn_edges = find_two_hop_connected_nodes(th)
			res_conn_edges = zeros(0,2);
			num_nodes = length(th.m_node_locations);
			for node_1 = 1:num_nodes
				outgoing_nodes_1 = th.get_dn_rx_nodes(node_1);
				for node_2 = 1:num_nodes
					if(node_1 ~= node_2)
						outgoing_nodes_2 = th.get_dn_rx_nodes(node_2);
						for i = 1:length(outgoing_nodes_2)
							if(~isempty(find(outgoing_nodes_2(i) == outgoing_nodes_1)))
								res_conn_edges = [res_conn_edges ; [node_1 , node_2]];
								break;
							end
						end	
					end
				end
			end
		end
	end
end
