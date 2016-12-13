function multi_node_run_scenario(run_index)

disp(run_index);

SCENARIO_SAVE_FILE = 'scenario_temp'
load(SCENARIO_SAVE_FILE);

m_simulation_scenario.run_by_index(run_index);
exit;


