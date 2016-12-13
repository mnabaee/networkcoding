%run_collect_results.m
function run_collect_results(in)
close all;
%clear all;
clc;

file_name = in;
%file_name = 'scenario_013';
disp(file_name);
load(file_name);

disp(m_sensor_deployment.get_params);
disp(m_sensor_deployment.get_params.m_channel_params);
disp(m_message);

num_bl = min(length(m_PF_results),length(m_QNC_results));
all_data_PF.delay = [];
all_data_PF.decoding_snr = [];
all_data_QNC.delay = [];
all_data_QNC.decoding_snr = [];
for bl_index = 1:num_bl
	res = m_PF_results{bl_index}.results;
	curve_PF = [];
	curve_QNC = [];
%	blen = m_PF_results{bl_index}.results{2}.packet_len;
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
	curve_PF = res;
	res = m_QNC_results{bl_index}.results;
	curve_QNC = res;
	[curve_PF,curve_QNC] = pad_extra(curve_PF,curve_QNC);
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
	title(['Comparison of Decoding SNR for PF and QNC over 15.4, nodes=' num2str(m_sensor_deployment.get_params.m_number_of_nodes) ', edges=' num2str(m_sensor_deployment.get_params.m_number_of_edges) ', noise level=' num2str(m_sensor_deployment.get_params.m_channel_params.m_noise_level) 'dBm, sparsity factor=' num2str(m_message.sparsity_factor)]);
end

function [new_curve_PF,new_curve_QNC] = pad_extra(curve_PF,curve_QNC)
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
