close all;
clear all;
clc;

t_res = 1.3474e-8;
m_carrier = carrier_signal(2405e6,0);
m_mod = modulator_2500meg(m_carrier,1/(2e6),t_res);

for i = 0:15
	p = packet_general;
	binary = de2bi(i,4);
	p.addToEnd(binary);
	mod_sig{i+1} = m_mod.modulate_phy_packet(p,rand*100);
	%figure,mod_sig{i+1}.plot_this('r');
end

for i=1:16
	for j=1:16
		summ(i,j) = sum(mod_sig{i}.get_sample_data .* mod_sig{j}.get_sample_data) / sqrt(sum(mod_sig{i}.get_sample_data .^2) * sum(mod_sig{j}.get_sample_data .^2));
	end
end

summ

freqs = [2405:5:2470];

for r = 1:length(freqs)
freq = freqs(r)
m_carrier = carrier_signal(freq*1e6,0);
m_mod = modulator_2500meg(m_carrier,1/(2e6),t_res);
bit_binary = rand(1,100*8) > .5;
p = packet_general;
p.addToEnd(bit_binary);
mod_sig = m_mod.modulate_phy_packet(p,rand*100);
figure,mod_sig.plot_this('g'); title(freq);
p2 = m_mod.demodulate_signal_to_phy_packet(mod_sig);

%p.print_this;
%p2.print_this;

p.calculate_Hamming_dist(p2)
end

%[mod_sig_2] = m_mod.convert_symbIndex_to_mod_signal(symbol_index,0);
%figure(3), mod_sig_2.plot_this('b-^');

%f_cut = 2*5e6*t_res;
%filter_obj = fir1(20,f_cut,'low',kaiser(21,3));



%[res_binary,res_index] = m_mod.find_best_symbol_ver3(mod_sig_2)


