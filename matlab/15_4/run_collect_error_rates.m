close all;
clear all;
clc;

file_name_s{1} = 'scenario_075_dBm';
file_name_s{2} = 'scenario_080_dBm';
file_name_s{3} = 'scenario_083_dBm';
file_name_s{4} = 'scenario_085_dBm';
file_name_s{5} = 'scenario_090_dBm';

for f_ind=1:length(file_name_s)
file_name = file_name_s{f_ind};
disp(file_name);
load(file_name);

res = m_QNC_results{1}.results;
num_txs(f_ind) = res.number_of_txs(end);
num_drops(f_ind) = res.number_of_packet_drops(end);
ratio(f_ind) = num_drops(f_ind) / num_txs(f_ind);
noise_power(f_ind) = m_sensor_deployment.get_params.m_channel_params.m_noise_level;
end
figure,plot(noise_power,ratio*100,'r-o');
xlabel('Noise Power [dBm]'); ylabel('Packet Drop Rate %'); grid on;

figure,semilogy(noise_power,ratio,'r-o');
xlabel('Noise Power [dBm]'); ylabel('Packet Drop Probability'); grid on;

