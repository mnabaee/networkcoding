classdef channel < handle
	properties (Hidden)
		m_noise_level;	%in dB

		m_path_loss_at_1meter;
		m_path_loss_factor;
		m_path_loss_variance;
	end
	methods
		function th_ch = channel
			th_ch.initialize_defaults;
		end
		function initialize_defaults(th_ch)
			L0 = 35.4;			%Attenuation at 1 meter [dB]
			n = 3.12;		%Power Exponent [unit-less]
			sigma = 1.83; 		%Path-loss variance
			nLev = -85; 		%Noise Level [dBm]  %default:-115
		 	th_ch.initialize(L0,n,sigma,nLev);	
		end
		function res = get_params(th)
			res.m_noise_level = th.m_noise_level;
			res.m_path_loss_at_1meter = th.m_path_loss_at_1meter;
			res.m_path_loss_factor = th.m_path_loss_factor;
			res.m_path_loss_variance = th.m_path_loss_variance;
		end
		function initialize(th_ch,L0,n,sigma,nLev)
			th_ch.m_noise_level = nLev;
			th_ch.m_path_loss_at_1meter = L0;
			th_ch.m_path_loss_factor = n;
			th_ch.m_path_loss_variance = sigma;
		end
		function rx_sig_power = calculate_sig_power_at_rx(th_ch,tx_sig_power,m_distance) %all in dBm
			attenuation_dB = th_ch.m_path_loss_at_1meter + 10 * th_ch.m_path_loss_factor * log10(m_distance);
			rx_sig_power = tx_sig_power - attenuation_dB;
		end
		function rx_SNR = calculate_SNR_at_rx(th_ch,tx_sig_power,m_distance)
			rx_sig_power = th_ch.calculate_sig_power_at_rx(tx_sig_power,m_distance);
			rx_SNR = rx_sig_power - m_noise_level;
		end
		function attenuations_vec_dB = simulate_attenuation_in_dB(th_ch,m_distance,len)
			%attenuations_vec_dB = th_ch.m_path_loss_at_1meter + 10 * th_ch.m_path_loss_factor * log10(m_distance) + lognrnd(0,th_ch.m_path_loss_variance,1,len);
			variable_part = th_ch.m_path_loss_variance * randn(1,len);
			variable_part = (abs(variable_part) > th_ch.m_path_loss_variance) .* sign(variable_part) * th_ch.m_path_loss_variance + (abs(variable_part) <= th_ch.m_path_loss_variance) .* variable_part;
			attenuations_vec_dB = th_ch.m_path_loss_at_1meter + 10 * th_ch.m_path_loss_factor * log10(m_distance) + variable_part;
		end
		function rx_sig = simulate_rx_signal_without_noise(th_ch,tx_sig,m_distance)
			attenuations_vec_dB = th_ch.m_path_loss_at_1meter + 10 * th_ch.m_path_loss_factor * log10(m_distance) + lognrnd(0,th_ch.m_path_loss_variance,1,tx_sig.get_num_samples);
		        rx_sig_values = tx_sig.get_sample_data .* 10.^(-attenuations_vec_dB/10);
			rx_sig = signal_continous_time(tx_sig.get_init_time,tx_sig.get_end_time,rx_sig_values);
			clear rx_sig_values;
		end
		function res_sig = add_by_noise(th_ch,sig)
			res_sig = sig.clone;
			num_samples = sig.get_num_samples;
			new_sample_data = sig.get_sample_data + sqrt((1e-3) * (10^(th_ch.m_noise_level/10))) * randn(1,num_samples);
			res_sig.set_all_data(new_sample_data);	
		end
	end
end
