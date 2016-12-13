%test_simulation.m

close all;
clear all;
clc;

message_binary_vector_lengths_in_Byte = [2];%,2,3,4,5];
message_sparsity_factors = [0.1];%, 0.05, 0.10];
message_near_sparsity_parameters = [0];% 0 0 ];
m_save_file_name = 'test_bl_1_bytes_noisy__NEW';

m_time_res = 1.3474e-8 ;
m_end_time = 2e-3;

m_simulation_scenario = simulation_scenario(message_binary_vector_lengths_in_Byte,message_sparsity_factors,message_near_sparsity_parameters,m_save_file_name);
m_simulation_scenario.set_time_params(m_time_res,m_end_time);
m_simulation_scenario.initialize_channel_model;
m_simulation_scenario.create_sensor_deployment_uniform_centered_gateway;
%m_simulation_scenario.create_sensor_deployment_uniform_cornered_gateway;
%m_simulation_scenario.m_sensor_deployment.plot_this;
m_simulation_scenario.run_all_PF;





