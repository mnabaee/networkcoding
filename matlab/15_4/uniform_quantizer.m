classdef uniform_quantizer < handle
	properties (Hidden)
		m_number_of_bits;
		m_range;	
		m_q_step;
	end
	methods
		function th = uniform_quantizer(range,bits)
			th.m_number_of_bits = bits;
			th.m_range = range;
			th.m_q_step = 2*range * 2^(-bits);
		end
		function binaries = quantize_and_convert_to_binary(th,in_vals)
			symbIndices = round(in_vals/th.m_q_step -.5)+(2^th.m_number_of_bits)/2;
			symbIndices = (symbIndices >= 0) .* symbIndices;
			symbIndices = ( symbIndices < 2^(th.m_number_of_bits) ) .* symbIndices + (symbIndices >= 2^(th.m_number_of_bits) ) .* (2^th.m_number_of_bits-1);
			binaries = de2bi(symbIndices,th.m_number_of_bits);
		end
		function q_vals = quantize(th,in_vals);
			binaries = th.quantize_and_convert_to_binary(in_vals);
			q_vals = th.convert_binary_to_q_val(binaries);
		end
		function q_vals = convert_binary_to_q_val(th,binaries)
			symbIndices = bi2de(binaries);
			q_vals = - th.m_range + th.m_q_step / 2 + symbIndices * th.m_q_step;
		end
		function res = get_params(th)
			res.m_number_of_bits = th.m_number_of_bits;
			res.m_range = th.m_range;
			res.m_q_step = th.m_q_step;
		end
		function print_params(th)
			disp(th.get_params);
		end
	end
end
