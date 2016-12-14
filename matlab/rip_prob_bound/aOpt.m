% a value Optimization

close all;
clear all;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

delta=sqrt(2)-1;
eps=delta/sqrt(2);
syms r;

aVec=[10^-6:10^-2:1];

for i=1:length(aVec)
    a=aVec(i);
    f11=r^(1/2/a-1)*exp(-r/2);
    %f1=int(f11,1/a-eps/a,1/a+eps/a);
    f1=quad( f11,1/a-eps/a,1/a+eps/a);
    %f2=int(f11,10^-5,10^5);
    f2=quad(f11,10^-5,10^5);
    f=f1/f2/(2^(1/2/a));
    val(i)=f;
    disp(i);
end

plot(aVec,val);


