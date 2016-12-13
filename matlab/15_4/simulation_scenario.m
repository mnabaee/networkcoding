classdef simulation_scenario < handle
	properties
		m_sensor_deployment;
		m_messages_array;
		m_channel;
	end
	properties (Hidden)

		m_message_sparsity_factor_vector;
		m_message_near_sparsity_parameter_vector;
		m_message_binary_length_vector;
		m_PF_module;
		m_PF_results;
		m_QNC_module;
		m_QNC_results;
		m_save_file_name;
		m_time_res;
		m_end_time;

		m_host_names;
		
	end
	methods
		function th = simulation_scenario(in_vec,in_vec_sp,in_vec_epsK,save_file_name)   %in_vec is in Bytes
			if(length(in_vec_sp) ~= length(in_vec_epsK))
				error('Length of input vectors should be appropriate.');
			end
			th.m_message_binary_length_vector = ceil(in_vec) * 8;
			th.m_message_sparsity_factor_vector = in_vec_sp;
			th.m_message_near_sparsity_parameter_vector = in_vec_epsK;
			th.m_sensor_deployment = [];
			th.m_messages_array = [];
			th.m_PF_module = [];
			th.m_QNC_module = [];
			th.m_save_file_name = save_file_name;
		end
		function initialize_channel_model(th)
			th.m_channel = channel;
		end
		function put_all_jobs_on_hosts(th)
			num_runs = length(th.m_message_binary_length_vector);
			for run_index = 1:num_runs
				host_name = ['tr5130gu-' num2str(run_index + 5) '.ece.mcgill.ca'];
				th.put_job_on_host(run_index,host_name);
			end
		end
		function put_job_on_host(th,run_index,server_name)
			%cmd3 = [' sh ~/15_4_matlab/matlab_batcher.sh multi_node_run_scenario ' num2str(run_index) ' 15_4_matlab '];
			%cmd1 = ['ssh ' server_name ' " '  cmd3 ' " '];
			cmd3 = ['nohup sh ~/15_4_matlab/matlab_batcher.sh multi_node_run_scenario ' num2str(run_index) ' 15_4_matlab  '];
			cmd1 = ['ssh ' server_name ' " '  cmd3 ' " '];
			system(cmd1);
		end
		function run_by_index(th,run_index)
			if(isempty(th.m_sensor_deployment))
				error('Sensor Deployment has to be initiated!');
			end
			message_param_index = 1;
			packet_len_index = 1;
			m_sparsity_factor = th.m_message_sparsity_factor_vector(message_param_index);
			m_near_sparsity_param = th.m_message_near_sparsity_parameter_vector(message_param_index);
			m_packet_len = th.m_message_binary_length_vector(packet_len_index);
			
			m_message = th.create_messages_sparse_uniform(m_sparsity_factor,m_near_sparsity_param,10);
			m_messages_array{run_index} = m_message;
			
			th.m_PF_module = packet_forwarding_module(th.m_sensor_deployment);
			th.m_PF_module.initialize_default_freqs(m_message.range,m_packet_len);
			th.m_PF_module.simulation_initialize(m_message.x_vector);
			disp([' RUN_INDEX=' num2str(run_index) ' packet_len=' num2str(m_packet_len) ' message_param_index=' num2str(message_param_index)]);
			tic;
			th.m_PF_module.deliver_messages;
			th.m_PF_results{run_index}.results = res;
			th.m_PF_results{run_index}.message = m_message;
			th.m_PF_results{run_index}.packet_len = th.m_message_binary_length_vector(packet_len_index);
			th.m_PF_results{run_index}.simulation_time = toc;
			th.m_PF_module = [];
			th.save_results(run_index);
			disp([' FINISHED RUN_INDEX=' num2str(run_index) ' packet_len=' num2str(m_packet_len) ' message_param_index=' num2str(message_param_index)]);
		end
		function [results,e_vals,delay_snr_curve] = get_PF_results(th,plot_str)
			[results,e_vals] = th.m_PF_module.get_results;
			for t = 1:length(results)
				delay_snr_curve.x_values(t) = results{t}.delay;
				delay_snr_curve.y_values(t) = results{t}.decoding_snr;
				time_backoff_curve.x_values(t) = results{t}.delay;
				time_backoff_curve.y_values(t) = results{t}.e_number_of_backoffs;
				time_txs_curve.x_values(t) = results{t}.delay;
				time_txs_curve.y_values(t) = results{t}.e_number_of_inter_node_tx;
				time_delivered_curve.x_values(t) = results{t}.delay;
				time_delivered_curve.y_values(t) = length(results{t}.served_nodes);
			end
			if (nargin == 2)
				subplot(3,1,1),plot(delay_snr_curve.x_values,delay_snr_curve.y_values,plot_str);
				grid on;
				xlabel('Delay [ms]');
				ylabel('Decoding SNR [dB]');
				title('Decoding SNR vs Delay [dB]');
				subplot(3,1,2),plot(time_delivered_curve.x_values,time_delivered_curve.y_values,plot_str);
				grid on;
				xlabel('Delay [ms]');
				ylabel('Number of Served Nodes');
				title('Number of Served Nodes vs Delay');
				subplot(3,1,3),[hh1,hh2,hh3] = plotyy(time_backoff_curve.x_values,time_backoff_curve.y_values,time_txs_curve.x_values,time_txs_curve.y_values); 
				grid on;
				xlabel('Delay [ms]');
				ylabel(hh1(1),'Number of backoffs');
				ylabel(hh1(2),'Number of TXs');
				title('Number of Backoffs and TXs vs Delay');
			end
		end
		function run_for_many_scenarios_PF(th,many_times)
			save_file_name_base = th.m_save_file_name;
			for rl_index = 1:many_times
				close all;
				th.create_sensor_deployment_uniform_centered_gateway;
				th.m_save_file_name = [save_file_name_base '_many_times_' num2str(rl_index) 'th_time'];
				th.run_all_PF;
			end
			th.m_save_file_name = save_file_name_base;
		end
		function run_PF_QNC_all_block_lengthes(th)
			if(isempty(th.m_sensor_deployment))
				error('Sensor Deployment has to be initiated!');
			end
			m_message = th.create_messages_sparse_uniform(th.m_message_sparsity_factor_vector(1),th.m_message_near_sparsity_parameter_vector(1),10);
			m_save_file_name = [th.m_save_file_name];
			[ret, m_host_name] = system('hostname');
			m_QNC_results = [];
			m_PF_results = [];
			m_sensor_deployment = th.m_sensor_deployment;
			save(m_save_file_name,'m_PF_results','m_QNC_results','m_sensor_deployment','m_message','m_host_name','-v7.3');
			disp(m_sensor_deployment.get_params);
			disp(m_sensor_deployment.get_params.m_channel_params);
			disp(m_message);
			disp(m_host_name);
			for bl_index = 1:length(th.m_message_binary_length_vector)
				m_block_length = th.m_message_binary_length_vector(bl_index);
				subj = [m_save_file_name];
				file_name = [m_save_file_name '_temp_email.jpg'];
				th.m_QNC_module = QNC_module(th.m_sensor_deployment,m_block_length,m_message.range,m_save_file_name);	
				th.m_QNC_module.initialize_simulation(m_message);
				th.m_QNC_module.enable_write_log;
				tic;
				th.m_QNC_module.perform_QNC_times(7);
				th.m_QNC_results{bl_index}.results = th.m_QNC_module.get_results;
				m_QNC_results{bl_index}.simulation_time = toc/60;
				text = ['simulation of QNC for blIndex=' num2str(bl_index) '/' num2str(length(th.m_message_binary_length_vector)) ' is done in ' num2str(m_QNC_results{bl_index}.simulation_time) ' mins over: ' m_host_name];
				m_QNC_results{bl_index}.results = th.plot_results_QNC(th.m_QNC_results{end}.results,file_name);
				%th.sendToMyGmail(subj,text,file_name);
				th.m_QNC_module = [];
				th.m_QNC_results{end} = [];
				save(m_save_file_name,'m_PF_results','m_QNC_results','m_sensor_deployment','m_message','m_host_name','-v7.3');
				disp(['simulation of QNC for blIndex=' num2str(bl_index) '/' num2str(length(th.m_message_binary_length_vector)) ' is done in ' num2str(m_QNC_results{bl_index}.simulation_time) ' mins.']);
				
				th.m_PF_module = packet_forwarding_module(th.m_sensor_deployment);
				th.m_PF_module.initialize_default_freqs(m_message.range,m_block_length);
				th.m_PF_module.simulation_initialize(m_message.x_vector);
				th.m_PF_module.enable_write_log;
				tic;
				th.m_PF_module.deliver_messages;
				th.m_PF_results{bl_index}.results = th.m_PF_module.get_results;
				m_PF_results{bl_index}.simulation_time = toc/60;
				text = ['simulation of PF for blIndex=' num2str(bl_index) '/' num2str(length(th.m_message_binary_length_vector)) ' is done in ' num2str(m_PF_results{bl_index}.simulation_time) ' mins over: ' m_host_name];
				m_PF_results{bl_index}.results = th.plot_results_PF(th.m_PF_results{end}.results,file_name);
				%th.sendToMyGmail(subj,text,file_name);
				th.m_PF_module = [];
				th.m_PF_results{end}  = [];
				save(m_save_file_name,'m_PF_results','m_QNC_results','m_sensor_deployment','m_message','m_host_name','-v7.3');
				disp(['simulation of PF for blIndex=' num2str(bl_index) '/' num2str(length(th.m_message_binary_length_vector)) ' is done in ' num2str(m_PF_results{bl_index}.simulation_time) ' mins.']);
			end	
		end
		function curve_PF = plot_results_PF(th,res,file_name)
			for t = 1:length(res)
				curve_PF.delay(t) = res{t}.delay;
				curve_PF.decoding_snr(t) = res{t}.decoding_snr;
				curve_PF.total_tx_energy(t) = res{t}.total_tx_energy;
				curve_PF.number_of_served_nodes(t) = res{t}.served_nodes;
				curve_PF.number_of_txs(t) = res{t}.e_number_of_inter_node_tx;
				curve_PF.number_of_packet_drops(t) = res{t}.e_number_of_packet_drops;
				curve_PF.number_of_backoffs(t) = res{t}.e_number_of_backoffs;
				curve_PF.number_of_CSMA_failures(t) = res{t}.e_number_of_CSMA_failures;
			end
			curve_PF.packet_len = res{end}.packet_len;
			f = figure('visible','off');
			subplot(3,2,1),plot(curve_PF.delay,curve_PF.decoding_snr,'r-'); xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on;
			subplot(3,2,2),plot(curve_PF.delay,curve_PF.number_of_served_nodes,'r-'); xlabel('Delay [msec]'); ylabel('Number of Served Nodes'); grid on;
			subplot(3,2,3),plot(curve_PF.delay,curve_PF.total_tx_energy,'b-'); xlabel('Delay [msec]'); ylabel('Total TX Energy '); grid on;
			subplot(3,2,4),plot(curve_PF.delay,curve_PF.number_of_txs,'b-'); xlabel('Delay [msec]'); ylabel('Total Number of Inter-Node TXs'); grid on;
			subplot(3,2,5),plot(curve_PF.delay,curve_PF.number_of_packet_drops,'b-'); xlabel('Delay [msec]'); ylabel('Total Number of Packet Drops'); grid on;
			subplot(3,2,6),plot(curve_PF.delay,curve_PF.number_of_backoffs,'b-'); xlabel('Delay [msec]'); ylabel('Total Number of Backoffs'); grid on; 
			ha =  axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
			text(0.5, 1,'\bf Packet Forwarding over 15.4','HorizontalAlignment','center','VerticalAlignment', 'top');
			saveas(f,file_name);
		end
		function curve_QNC = plot_results_QNC(th,res,file_name)
			for t = 2:length(res);
				curve_QNC.delay(t) = res{t}.delay;
				curve_QNC.decoding_snr(t) = res{t}.decoding_snr;
				curve_QNC.total_tx_energy(t) = res{t}.total_tx_energy;
				curve_QNC.number_of_txs(t) = res{t}.number_of_txs;
				curve_QNC.number_of_packet_drops(t) = res{t}.number_of_packet_drops;
			end
			curve_QNC.packet_len = res{end}.packet_len;
			f = figure('visible','off');
			subplot(2,2,1),plot(curve_QNC.delay,curve_QNC.decoding_snr,'r-'); xlabel('Delay [msec]'); ylabel('Decoding SNR [dB]'); grid on;
			subplot(2,2,2),plot(curve_QNC.delay,curve_QNC.total_tx_energy,'b-'); xlabel('Delay [msec]'); ylabel('Total TX Energy '); grid on;
			subplot(2,2,3),plot(curve_QNC.delay,curve_QNC.number_of_txs,'b-'); xlabel('Delay [msec]'); ylabel('Total Number of Inter-Node TXs'); grid on;
			subplot(2,2,4),plot(curve_QNC.delay,curve_QNC.number_of_packet_drops,'b-'); xlabel('Delay [msec]'); ylabel('Total Number of Packet Drops'); grid on;
			ha =  axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
			text(0.5, 1,'\bf Quantized Network Coding over 15.4','HorizontalAlignment','center','VerticalAlignment', 'top');
			saveas(f,file_name);
		end
		function sendToMyGmail(th,subj,text,file_address)
			myaddress = 'mahdy.nabaee@gmail.com';
			mypassword = 'wiriankh21vila';

			setpref('Internet','E_mail',myaddress);
			setpref('Internet','SMTP_Server','smtp.gmail.com');
			setpref('Internet','SMTP_Username',myaddress);
			setpref('Internet','SMTP_Password',mypassword);

			props = java.lang.System.getProperties;
			props.setProperty('mail.smtp.auth','true');
			props.setProperty('mail.smtp.socketFactory.class', ...
			                  'javax.net.ssl.SSLSocketFactory');
			props.setProperty('mail.smtp.socketFactory.port','465');

			%sendmail(myaddress, 'Gmail Test', 'This is a test message.');
			sendmail(myaddress, subj, text,{file_address});
		end
		function run_one_QNC(th,message_param_index,packet_len_index,save_file_name_base,run_counter_val)
			if(isempty(th.m_sensor_deployment))
				error('Sensor Deployment has to be initiated!');
			end
			if(nargin ==4)
				run_counter_val = length(th.m_QNC_results) + 1;
			end
			m_message = th.create_messages_sparse_uniform(th.m_message_sparsity_factor_vector(message_param_index),th.m_message_near_sparsity_parameter_vector(message_param_index),10);	
			message_range = m_message.range;
			m_log_file_name = [save_file_name_base '_packet_len_index_' num2str(packet_len_index) '_message_params_index_' num2str(message_param_index)];
			th.m_QNC_module = QNC_module(th.m_sensor_deployment,th.m_message_binary_length_vector(packet_len_index),m_message.range,m_log_file_name);
			th.m_QNC_module.initialize_simulation(m_message);
			tic;
			th.m_QNC_module.perform_QNC_times(10);
			th.m_QNC_results{run_counter_val}.results = th.m_QNC_module.get_results('r-o');
			th.m_QNC_results{run_counter_val}.simulation_time = toc / 60;
			m_QNC_results = th.m_QNC_results;
			save([save_file_name_base '_QNC'],'m_QNC_results');	
		end
		function run_all_QNC(th,save_file_name_base)
			if(nargin == 1)
				save_file_name_base = th.m_save_file_name;
			end
			for i = 1:length(th.m_message_sparsity_factor_vector)
				for packet_len_index = 1:length(th.m_message_binary_length_vector)
					th.run_one_QNC(i,packet_len_index,save_file_name_base);
				end
			end
		end
		function run_all_PF(th)
			if(isempty(th.m_sensor_deployment))
				error('Sensor Deployment has to be initiated!');
			end
			run_counter = 0;
			for i = 1:length(th.m_message_sparsity_factor_vector)
				m_message = th.create_messages_sparse_uniform(th.m_message_sparsity_factor_vector(i),th.m_message_near_sparsity_parameter_vector(i),10);	
				m_messages_array{i} = m_message;
				for packet_len_index = 1:length(th.m_message_binary_length_vector)
					th.m_PF_module = packet_forwarding_module(th.m_sensor_deployment);
					m_save_file_name = [th.m_save_file_name '_packet_len_index_' num2str(packet_len_index)];
					th.m_PF_module.initialize_default_freqs(m_message.range,th.m_message_binary_length_vector(packet_len_index));
					th.m_PF_module.set_save_file_name(m_save_file_name);
					
					th.m_PF_module.simulation_initialize(m_message.x_vector);
					tic;
					th.m_PF_module.deliver_messages;
					[res] = th.m_PF_module.get_results;
					run_counter = run_counter + 1;
					th.m_PF_results{run_counter}.results = res;
					th.m_PF_results{run_counter}.message = m_message;
					th.m_PF_results{run_counter}.packet_len = th.m_message_binary_length_vector(packet_len_index);
					th.m_PF_results{run_counter}.simulation_time = toc;
					th.save_results;
					th.get_PF_results('r');
					fprintf(['run ' num2str(run_counter) ' is done in ' num2str(th.m_PF_results{run_counter}.simulation_time / 60) ' minutes. ']);
					fprintf('\n');
				end
			end
		end
		function m_messages = create_messages_sparse_uniform(th,sparsity_factor,near_sparsity_parameter,range)
			nodes = th.m_sensor_deployment.get_params.m_number_of_nodes;
			SsupportInd=randperm(nodes);
			SsupportInd=SsupportInd(1:ceil(sparsity_factor*nodes));
			Ssupport=zeros(nodes,1);
			Ssupport(SsupportInd)=1;
			Sk=2*(rand(nodes,1)-.5).*Ssupport;
			randVec=randn(nodes,1);
			randVec=randVec/norm(randVec,1)*near_sparsity_parameter*norm(Sk,1);
			S=Sk+randVec;
			phi=orth(rand(nodes,nodes));
			x=phi*S;
			if(max(x) - min(x) > 0)
				x=((x-min(x))*2/(max(x)-min(x))-1)*range;
			end
			xNorm=norm(x,2);
			m_messages.s_vector = S;
			m_messages.x_vector = x;
			m_messages.phi = phi;
			m_messages.range = range;
			m_messages.sparsity_factor = sparsity_factor;
			m_messages.near_sparsity_parameter = near_sparsity_parameter;
			th.m_messages_array = [th.m_messages_array , m_messages];
		end
		function create_sensor_deployment_uniform_centered_gateway(th)
			th.m_sensor_deployment = sensor_deployment(th.m_channel);
			th.m_sensor_deployment.set_time_params(th.m_time_res,th.m_end_time);
			while(true)
				th.m_sensor_deployment.pick_random_gateway_node(0,0.25);
				if(th.check_deployment_connectivity == true)
					break;
				end
			end
			for node = 1:th.m_sensor_deployment.get_params.m_number_of_nodes
				num_in_nodes(node) = length(th.m_sensor_deployment.get_incoming_nodes(node));
			end
			fprintf([' sensor deployment is generated with ' num2str(th.m_sensor_deployment.get_params.m_number_of_nodes) ' and ' num2str(th.m_sensor_deployment.get_params.m_number_of_edges) ' edges, max_in_edges=' num2str(max(num_in_nodes)) ', min_in_edges=' num2str(min(num_in_nodes)) ', avg_in_edges=' num2str(mean(num_in_nodes)) '. \n']);
		end
		function create_sensor_deployment_uniform_cornered_gateway(th)
			th.m_sensor_deployment = sensor_deployment(th.m_channel);
			th.m_sensor_deployment.set_time_params(th.m_time_res,th.m_end_time);
			while(true)
				th.m_sensor_deployment.pick_random_gateway_node(0.85,0.99);
				if(th.check_deployment_connectivity == true)
					break;
				end
			end
			for node = 1:th.m_sensor_deployment.get_params.m_number_of_nodes
				num_in_nodes(node) = length(th.m_sensor_deployment.get_incoming_nodes(node));
			end
			fprintf([' sensor deployment is generated with ' num2str(th.m_sensor_deployment.get_params.m_number_of_nodes) ' and ' num2str(th.m_sensor_deployment.get_params.m_number_of_edges) ' edges, max_in_edges=' num2str(max(num_in_nodes)) ', min_in_edges=' num2str(min(num_in_nodes)) ', avg_in_edges=' num2str(mean(num_in_nodes)) '. \n']);
		end
		function set_time_params(th,time_res,end_time)
			th.m_time_res = time_res;
			th.m_end_time = end_time;
%			th.m_sensor_deployment.set_time_params(time_res,end_time);
		end
		function save_results(th,run_index)
			if(nargin == 1)
				m_PF_results = th.m_PF_results;
				save([th.m_save_file_name, '_results'],'m_PF_results');
			elseif(nargin == 2)
				m_PF_results = th.m_PF_results{run_index};
				save([th.m_save_file_name , '_results_run_index' num2str(run_index)],'m_PF_results');
			end
		end
	end
	methods (Hidden)
		function res = check_deployment_connectivity(th)
			num_nodes = th.m_sensor_deployment.get_params.m_number_of_nodes;
			res = true;
			for node = 1:num_nodes
				if(length(th.m_sensor_deployment.get_path_to_gateway(node)) == 0)
					res = false;
					return;
				end
			end
			sec_nodes = [];
			for node = 1:num_nodes
				if(node ~= th.m_sensor_deployment.get_params.m_gateway_node)
					this_sec_node = th.m_sensor_deployment.get_path_to_gateway(node);
					this_sec_node = this_sec_node(2);
					if(isempty(find(sec_nodes == this_sec_node )))
						sec_nodes = [sec_nodes , this_sec_node];
					end
				end
			end
%			if(length(sec_nodes) > 16)
%				res = false;
%				return;
%			end
		end
	end
end
