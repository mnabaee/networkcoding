

close all;
clear all;
clc;

t_res = 1e-7;
f_res = 1/t_res;

t= [0:t_res:.001];
base_sig = sin(2*pi*10000*t);
mod_sig = base_sig .* cos(2*pi*2450e6*t);

figure,plot(t,mod_sig,'r-'); hold on;
xlabel('t'); ylabel('y');
plot(t,base_sig,'b-s');

cut_off_freq_analog = 10e6;
cut_off_freq_digital = cut_off_freq_analog *2 / f_res;

filter_obj = fir1(200,cut_off_freq_digital,'low',kaiser(201,3));
fvtool(filter_obj,1,'Fs',f_res);

dem_sig = mod_sig .* cos(2*pi*2450e6*t);

filtered_sig = filter(filter_obj,1,dem_sig);

figure,plot(t,filtered_sig,'k-s'); hold on;
plot(t,base_sig,'r-o'); legend('filtered','base');

