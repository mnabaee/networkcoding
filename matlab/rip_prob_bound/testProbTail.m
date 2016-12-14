%Test Tail Probs
close all;
clear all;
clc;
format long;

lowDeltaVec=[sqrt(2)-1:0.1:0.999];
upDeltaVec=[0.6:0.5:8];
omegaVec=linspace(-200,200,10^6);
omegaDel=omegaVec(2)-omegaVec(1);
m=400;

    for i=1:length(lowDeltaVec)
        eps=lowDeltaVec(i)/sqrt(2);
        OmegaValgaussian=exp(-j*omegaVec*(1-eps))./(-j*omegaVec)./(sqrt(1-2*j*omegaVec/m).^m);
        resL(i)=real(1/(2*pi)*sum(OmegaValgaussian)*omegaDel)+0.5;
    end

    for i=1:length(upDeltaVec)
        eps=upDeltaVec(i)/sqrt(2);
        OmegaValgaussian=exp(-j*omegaVec*(1+eps))./(-j*omegaVec)./(sqrt(1-2*j*omegaVec/m).^m);
        resU(i)=1-real(1/(2*pi)*sum(OmegaValgaussian)*omegaDel)-0.5;
    end

    
resL
resU