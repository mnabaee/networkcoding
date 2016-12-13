%test_simulation.m

close all;
clear all;
clc;

message_binary_vector_lengths_in_Byte = [1,2,3,4,5];
message_sparsity_factors = [0.01];
message_near_sparsity_parameters = [0];
m_save_file_name = 'test_run_packet_forwarding';

m_time_res = 1e-7;
m_end_time = 2e-3;

SAVE_FILE_NAME = 'scenario_temp';

m_simulation_scenario = simulation_scenario(message_binary_vector_lengths_in_Byte,message_sparsity_factors,message_near_sparsity_parameters,m_save_file_name);
m_simulation_scenario.initialize_channel_model;
m_simulation_scenario.create_sensor_deployment_uniform_centered_gateway;
%m_simulation_scenario.create_sensor_deployment_uniform_cornered_gateway;
%m_simulation_scenario.m_sensor_deployment.plot_this;
m_simulation_scenario.set_time_params(m_time_res,m_end_time);
save(SAVE_FILE_NAME,'m_simulation_scenario');
m_simulation_scenario.put_all_jobs_on_hosts;


