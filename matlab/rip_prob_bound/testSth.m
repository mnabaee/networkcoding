%Test Sth

close all
clear all
clc;
format long;

delta=sqrt(2)-1;
eps=delta/sqrt(2)-10^-5;

mVec=[10:10:1000];
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);
for mInd=1:length(mVec)
    m=mVec(mInd);
    OmegaValgaussian=-(exp(-j*omegaVec).*sin(eps*omegaVec))./omegaVec./(sqrt(1-2*j*omegaVec*(1/m)).^m);
    tailProbGaussian(mInd)=(1+1/pi*omegaDel*sum(OmegaValgaussian));
end
plot(mVec,real(tailProbGaussian)); grid on;

tailProbGaussian
