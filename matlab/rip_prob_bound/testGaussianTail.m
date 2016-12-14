%Test Tail Probability and RIP for Gaussian

close all;
clear all;
clc;
format long;

n=10^3;
mVec=round(linspace(n/10,n,10));
kVec=round(linspace(1,n/50,10));
kVec=[1 2];

omegaVec=linspace(-10000,10000,10^6);
omegaDel=omegaVec(2)-omegaVec(1);

delta=sqrt(2)-1;
eps=delta/sqrt(2);

for mInd=1:length(mVec)
for kInd=1:length(kVec)
    m=mVec(mInd);
    k=kVec(kInd);
    %Tail Probability
        
        xS1=linspace(m/100,m*(1-eps),10000);
        del1=xS1(2)-xS1(1);
        xS2=linspace(m*(1+eps),10*m,10000);
        del2=xS2(2)-xS2(1);
        pdf1=chi2pdf([xS1],[m]);
        pdf2=chi2pdf([xS2],[m]);
        tailProbMaxG(mInd,kInd)=sum(pdf1)*del1+sum(pdf2)*del2;
        RIPprob(mInd,kInd)=1-(sum(pdf1)*del1+sum(pdf2)*del2)*(42/delta)^k*nchoosek(n,k);
end
end

tailProbMaxG;
((RIPprob>0)&(RIPprob<=1)).*RIPprob