function run_collect_results_all
close all;
%clear all;
clc;

file_name_base = 'deployment_1_noise_85_run_';
index_range = [1:8];

curves_delay_init = 0;
curves_delay_end = -1;
for save_file_index = 1:length(index_range)
	file_name = [file_name_base num2str(index_range(save_file_index))];
	m_PF_results = [];
	m_QNC_results = [];
	load(file_name);
	disp(['Loaded ' file_name ' with ' num2str(m_sensor_deployment.get_params.m_number_of_edges) ' edges.']);
	if(save_file_index ==1)
		disp(m_sensor_deployment.get_params);
		disp(m_sensor_deployment.get_params.m_channel_params);
		disp(m_message);
	end

	num_bl = min(length(m_PF_results),length(m_QNC_results));
	num_bl_s(save_file_index) = num_bl;
	for bl_index = 1:num_bl
		curve_PF_ = m_PF_results{bl_index}.results;
		curve_QNC_ = m_QNC_results{bl_index}.results;
		[curve_PF{save_file_index,bl_index},curve_QNC{save_file_index,bl_index}] = pad_extra_2(curve_PF_,curve_QNC_);
		if(curves_delay_end < 0)
			curves_delay_end = curve_PF{save_file_index,bl_index}.delay(end);
		else
			curves_delay_end = min(curves_delay_end , curve_PF{save_file_index,bl_index}.delay(end));
		end
		curves_delay_init = max(curves_delay_init , curve_PF{save_file_index,bl_index}.delay(1));
	end
	num_edges(save_file_index) = m_sensor_deployment.get_params.m_number_of_edges;
end
disp(['avg_num_edges=' num2str(mean(num_edges))]);
disp('Loading Files Finished.');
delays_time_res = curve_PF_.delay(end) - curve_PF_.delay(end-1);
delays_vec = [curves_delay_init : delays_time_res : curves_delay_end];
for save_file_index = 1:length(index_range)
	for bl_index = 1:num_bl_s(save_file_index)
		[curve_PF{save_file_index,bl_index},curve_QNC{save_file_index,bl_index}] = interp_uniquely(delays_vec,curve_PF{save_file_index,bl_index},curve_QNC{save_file_index,bl_index});
	end
end
num_samples = length(index_range);
for bl_index = 1 : num_bl
	for t_ind = 1:length(delays_vec)
		for sample_index = 1:num_samples
			delays_(sample_index) = curve_PF{sample_index,bl_index}.delay(t_ind);
			decoding_snr_(sample_index) = curve_PF{sample_index,bl_index}.decoding_snr(t_ind);
			total_tx_energy_(sample_index) = curve_PF{sample_index,bl_index}.total_tx_energy(t_ind);
			number_of_txs_(sample_index) = curve_PF{sample_index,bl_index}.number_of_txs(t_ind);
			number_of_packet_drops_(sample_index) = curve_PF{sample_index,bl_index}.number_of_packet_drops(t_ind);
			number_of_backoffs_(sample_index) = curve_PF{sample_index,bl_index}.number_of_backoffs(t_ind);
			number_of_served_nodes_(sample_index) = curve_PF{sample_index,bl_index}.number_of_served_nodes(t_ind);
		end
		avg_curve_PF{bl_index}.delay(1,t_ind) = mean(delays_);
		avg_curve_PF{bl_index}.decoding_snr(1,t_ind) = mean(decoding_snr_);
		avg_curve_PF{bl_index}.total_tx_energy(1,t_ind) = mean(total_tx_energy_);
		avg_curve_PF{bl_index}.number_of_served_nodes(1,t_ind) = mean(number_of_served_nodes_);
		avg_curve_PF{bl_index}.number_of_txs(1,t_ind) = mean(number_of_txs_);
		avg_curve_PF{bl_index}.number_of_packet_drops(1,t_ind) = mean(number_of_packet_drops_);
		avg_curve_PF{bl_index}.number_of_backoffs(1,t_ind) = mean(number_of_backoffs_);
		
		for sample_index = 1:num_samples
			delays_(sample_index) = curve_QNC{sample_index,bl_index}.delay(t_ind);
			decoding_snr_(sample_index) = curve_QNC{sample_index,bl_index}.decoding_snr(t_ind);
			total_tx_energy_(sample_index) = curve_QNC{sample_index,bl_index}.total_tx_energy(t_ind);
			number_of_txs_(sample_index) = curve_QNC{sample_index,bl_index}.number_of_txs(t_ind);
			number_of_packet_drops_(sample_index) = curve_QNC{sample_index,bl_index}.number_of_packet_drops(t_ind);
		end
		avg_curve_QNC{bl_index}.delay(1,t_ind) = mean(delays_);
		avg_curve_QNC{bl_index}.decoding_snr(1,t_ind) = mean(decoding_snr_);
		avg_curve_QNC{bl_index}.total_tx_energy(1,t_ind) = mean(total_tx_energy_);
		avg_curve_QNC{bl_index}.number_of_txs(1,t_ind) = mean(number_of_txs_);
		avg_curve_QNC{bl_index}.number_of_packet_drops(1,t_ind) = mean(number_of_packet_drops_);
	end
end
disp('Averaging Finished.');
all_data_PF.delay = [];
all_data_PF.decoding_snr = [];
all_data_QNC.delay = [];
all_data_QNC.decoding_snr = [];
for bl_index = 1:num_bl
	legends_{bl_index} = ['packet len=' num2str(bl_index)];
	switch bl_index
		case 1
			p_str = 'r-';
		case 2
			p_str = 'b-';
		case 3 
			p_str = 'g-';
		case 4 
			p_str = 'c-';
		case 5
			p_str = 'k-';
	end
	curve_PF = avg_curve_PF{bl_index};
	curve_QNC = avg_curve_QNC{bl_index};
	all_data_PF.delay = [all_data_PF.delay , curve_PF.delay];
	all_data_PF.decoding_snr = [all_data_PF.decoding_snr , curve_PF.decoding_snr];
	all_data_QNC.delay = [all_data_QNC.delay , curve_QNC.delay];
	all_data_QNC.decoding_snr = [all_data_QNC.decoding_snr , curve_QNC.decoding_snr];

	figure(1),
	subplot(3,2,1),plot(curve_PF.delay,curve_PF.decoding_snr,p_str); xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on; hold on;
	subplot(3,2,2),plot(curve_PF.delay,curve_PF.number_of_served_nodes,p_str); xlabel('Delay [msec]'); ylabel('Number of Served Nodes'); grid on; hold on;
	subplot(3,2,3),plot(curve_PF.delay,curve_PF.total_tx_energy,p_str); xlabel('Delay [msec]'); ylabel('Total TX Energy '); grid on; hold on;
	subplot(3,2,4),plot(curve_PF.delay,curve_PF.number_of_txs,p_str); xlabel('Delay [msec]'); ylabel('Total Number of Inter-Node TXs'); grid on; hold on;
	subplot(3,2,5),plot(curve_PF.delay,curve_PF.number_of_packet_drops,p_str); xlabel('Delay [msec]'); ylabel('Total Number of Packet Drops'); grid on; hold on;
	subplot(3,2,6),plot(curve_PF.delay,curve_PF.number_of_backoffs,p_str); xlabel('Delay [msec]'); ylabel('Total Number of Backoffs'); grid on; hold on;

	figure(2),
	subplot(2,2,1),plot(curve_QNC.delay,curve_QNC.decoding_snr,p_str); xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on; hold on;
	subplot(2,2,2),plot(curve_QNC.delay,curve_QNC.total_tx_energy,p_str); xlabel('Delay [msec]'); ylabel('Total TX Energy '); grid on; hold on;
	subplot(2,2,3),plot(curve_QNC.delay,curve_QNC.number_of_txs,p_str); xlabel('Delay [msec]'); ylabel('Total Number of Inter-Node TXs'); grid on; hold on;
	subplot(2,2,4),plot(curve_QNC.delay,curve_QNC.number_of_packet_drops,p_str); xlabel('Delay [msec]'); ylabel('Total Number of Packet Drops'); grid on; hold on;

end
	figure(1),subplot(3,2,1), legend(legends_);
	ha =  axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
	text(0.5, 1,'\bf Packet Forwarding over 15.4','HorizontalAlignment','center','VerticalAlignment', 'top');
	figure(2),subplot(2,2,1), legend(legends_);
	ha =  axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
	text(0.5, 1,'\bf Quantized Network Coding over 15.4','HorizontalAlignment','center','VerticalAlignment', 'top');


	[new_x_PF,new_y_PF] = topFinder(all_data_PF.delay,all_data_PF.decoding_snr);
	[new_x_QNC,new_y_QNC] = topFinder(all_data_QNC.delay,all_data_QNC.decoding_snr);

	figure,plot(new_x_PF,new_y_PF,'r-'); hold on; 
       plot(new_x_QNC,new_y_QNC,'b-'); xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on; legend('Packet Forwarding','QNC');
	%title(['Comparison of Decoding SNR for PF and QNC over 15.4, nodes=' num2str(m_sensor_deployment.get_params.m_number_of_nodes) ', edges=' num2str(m_sensor_deployment.get_params.m_number_of_edges) ', noise level=' num2str(m_sensor_deployment.get_params.m_channel_params.m_noise_level) 'dBm, sparsity factor=' num2str(m_message.sparsity_factor)]);
end

function [new_curve_PF,new_curve_QNC] = interp_uniquely(delays_vec,curve_PF,curve_QNC)
	curve_PF.decoding_snr = interp1(curve_PF.delay , curve_PF.decoding_snr , delays_vec);
	curve_PF.total_tx_energy = interp1(curve_PF.delay , curve_PF.total_tx_energy , delays_vec);
	curve_PF.number_of_txs = interp1(curve_PF.delay , curve_PF.number_of_txs , delays_vec);
	curve_PF.number_of_packet_drops = interp1(curve_PF.delay , curve_PF.number_of_packet_drops , delays_vec);
	curve_PF.number_of_served_nodes = interp1(curve_PF.delay , curve_PF.number_of_served_nodes , delays_vec);
	curve_PF.number_of_backoffs = interp1(curve_PF.delay , curve_PF.number_of_backoffs , delays_vec);
	curve_PF.delay = delays_vec;
	new_curve_PF = curve_PF;
	curve_QNC.decoding_snr = interp1(curve_QNC.delay , curve_QNC.decoding_snr , delays_vec);
	curve_QNC.total_tx_energy = interp1(curve_QNC.delay , curve_QNC.total_tx_energy , delays_vec);
	curve_QNC.number_of_txs = interp1(curve_QNC.delay , curve_QNC.number_of_txs , delays_vec);
	curve_QNC.number_of_packet_drops = interp1(curve_QNC.delay , curve_QNC.number_of_packet_drops , delays_vec);
	curve_QNC.delay = delays_vec;
	new_curve_QNC = curve_QNC;
end

function [new_curve_PF,new_curve_QNC] = pad_extra_2(curve_PF,curve_QNC)
%	if((curve_PF.delay(end)) < (curve_QNC.delay(end)))
		end_delay = curve_QNC.delay(end);
		delay_res = curve_QNC.delay(end) - curve_QNC.delay(end-1);
		extra_delay_vec = [curve_PF.delay(end) :delay_res : end_delay ];
		extra_delay_vec = extra_delay_vec(2:end);
		curve_PF.delay = [curve_PF.delay , extra_delay_vec];
		curve_PF.decoding_snr = [curve_PF.decoding_snr , curve_PF.decoding_snr(end) + extra_delay_vec*0];
		curve_PF.total_tx_energy = [curve_PF.total_tx_energy , curve_PF.total_tx_energy(end) + extra_delay_vec*0];
		curve_PF.number_of_txs = [curve_PF.number_of_txs , curve_PF.number_of_txs(end) + extra_delay_vec*0];
		curve_PF.number_of_packet_drops = [curve_PF.number_of_packet_drops , curve_PF.number_of_packet_drops(end) + extra_delay_vec*0];
		curve_PF.number_of_served_nodes = [curve_PF.number_of_served_nodes , curve_PF.number_of_served_nodes(end) + extra_delay_vec*0];
		curve_PF.number_of_backoffs = [curve_PF.number_of_backoffs , curve_PF.number_of_backoffs(end) + extra_delay_vec*0];
%	end
	new_curve_PF = curve_PF;
	new_curve_QNC = curve_QNC;
end
