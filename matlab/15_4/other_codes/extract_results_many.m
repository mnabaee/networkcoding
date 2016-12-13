%extract_results_many.m

close all;
clear all;
clc;

directory_ = 'results_PF/';
save_file_name_base = 'test_PF';
curve_raw.x_values = [];
curve_raw.y_values = [];
for rl_index = 1:8
	m_save_file_name = [ directory_ save_file_name_base '_many_times_' num2str(rl_index) 'th_time' '_results'];
	load(m_save_file_name);
	num_runs = length(m_PF_results);
	for run_index = 1:length(m_PF_results)
		for t_index = 1:length(m_PF_results{run_index}.results)
			m_final_results{rl_index,run_index,t_index} = m_PF_results{run_index}.results{t_index};
			curve_raw.x_values = [curve_raw.x_values , m_PF_results{run_index}.results{t_index}.delay];
			curve_raw.y_values = [curve_raw.y_values , m_PF_results{run_index}.results{t_index}.decoding_snr];
		end
	end	
end	

for run_index = 1:num_runs
	
end

figure,plot(curve.x_values,curve.y_values,'r.'); grid on; xlabel('Delay [ms]'); ylabel('Decoding SNR [dB]');

