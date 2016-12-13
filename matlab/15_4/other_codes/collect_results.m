% collect_results.m

close all;
clear all;
clc;

all_res_curve_delay_decodingSNR.x_values = [];
all_res_curve_delay_decodingSNR.y_values = [];
figure(1),hold on; grid on; xlabel('Delay [ms]'); ylabel('Decoding SNR [dB]');

for run_index = 1:4
	load(['test_bl_' num2str(run_index) '_bytes_noisy_results.mat']);
	all_res{run_index} = m_PF_results;
	this_run_res = all_res{run_index};
	this_run_res = this_run_res{1};		
	for t_index = 1:length(this_run_res.results)
		curve_delay_decodingSNR{run_index}.x_values(t_index) = this_run_res.results{t_index}.delay;
		curve_delay_decodingSNR{run_index}.y_values(t_index) = this_run_res.results{t_index}.decoding_snr;
	end
	all_res_curve_delay_decodingSNR.x_values = [all_res_curve_delay_decodingSNR.x_values , curve_delay_decodingSNR{run_index}.x_values];
	all_res_curve_delay_decodingSNR.y_values = [all_res_curve_delay_decodingSNR.y_values , curve_delay_decodingSNR{run_index}.y_values];
	switch run_index
		case 1 
			p_str = 'r-o';
		case 2 
			p_str = 'k-s';
		case 3 
			p_str = 'c-^';
		case 4 
			p_str = 'g-v';
	end
		case 5 
			p_str = 'b-d';
	plot(curve_delay_decodingSNR{run_index}.x_values,curve_delay_decodingSNR{run_index}.y_values,p_str);
	legend('8','16','24','32');
end

