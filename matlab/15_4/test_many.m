%test_many.m

close all;
clear all;
clc;

message_binary_vector_lengths_in_Byte = [1,2,3,4,5];
message_sparsity_factors = [0.01];
message_near_sparsity_parameters = [0];
m_save_file_name = 'results_PF/test_PF';
m_time_res = 1e-7;
m_end_time = 2e-3;

m_simulation_scenario = simulation_scenario(message_binary_vector_lengths_in_Byte,message_sparsity_factors,message_near_sparsity_parameters,m_save_file_name);
m_simulation_scenario.initialize_channel_model;
m_simulation_scenario.set_time_params(m_time_res,m_end_time);
m_simulation_scenario.run_for_many_scenarios_PF(30);

