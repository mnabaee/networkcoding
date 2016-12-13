classdef carrier_signal < handle
	properties (Hidden)
		center_freq;
		phase_shift;
	end
	methods
		function c_sig = carrier_signal(freq,p_shift)
			c_sig.center_freq = freq;
			c_sig.phase_shift = p_shift;
		end
		function res = get_center_freq(carrier)
			res = carrier.center_freq;
		end
		function value = get_carrier_cos(c_sig,t)
			value = cos(c_sig.center_freq * t *2*pi + c_sig.phase_shift);
		end
		function value = get_carrier_sin(c_sig,t)
			value = sin(c_sig.center_freq * t *2*pi + c_sig.phase_shift);
		end
		function res_signal = mult_by_carrier_cos(th,in_sig)
			values = th.get_carrier_cos(in_sig.get_sample_times) .* in_sig.get_sample_data;
			res_signal = signal_continous_time(in_sig.get_init_time,in_sig.get_end_time,values);
		end
		function res_signal = mult_by_carrier_sin(th,in_sig)
			values = th.get_carrier_sin(in_sig.get_sample_times) .* in_sig.get_sample_data;
			res_signal = signal_continous_time(in_sig.get_init_time,in_sig.get_end_time,values);
		end
	end
end
