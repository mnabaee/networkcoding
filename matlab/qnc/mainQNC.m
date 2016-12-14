%Quantized Network Coding: Main Module
format long;
close all;
clear all;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

%Network Parameters
nodes=8;              %No of Nodes
edges=30;             %No of Esges
iterations=10;         %No of Iterations

%Quantization
q=10;
Delta=0.1;

%Sparsity Factor of Messages
sp=0.2;

[htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,[sp]); save genNet; disp('QNC Generated.');
[z,n,y,y2,zTot]=simulateQNC(nodes, edges, iterations ,htList,Delta,x,A,F,B); disp('QNC Simulated.');
[Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],[n],A,F,B); disp('QNC Calculated.');
 
% [ratio,nlzRatio,meanRatio,ratioX]=ripQNC(nodes, iterations ,x,q,sp,Psi,PsiTot,phi);
% 
% figure,hist(ratio{10},70);
% figure,stem(ratioX);

%Noise Power Analysis
delta2sp=0.35;
C2=4*sqrt(1+delta2sp)/(1-(1+sqrt(2))*delta2sp);
figure(3),plot(10*log10(nEffTotNorm*C2),'go-'); hold on;
figure(3),plot(10*log10(epsilon*C2),'r.-'); hold on;
for t=2:iterations+1
    [xRec{t}]=L1minDec(PsiTot{t},zTot{t},phi);
    recErrNorm(t)=norm(x-xRec{t},2);
    SNR(t)=10*log10(norm(x,2)/norm(x-xRec{t},2));
    numMeas(t)=length(zTot{t});
end
figure(3),plot(10*log10(recErrNorm),'b^-'); legend('Real Noise * C2','Upper Bound * C2','Recovery Error'); grid on; ylabel('Error Norm [dB]'); xlabel('Time Index of Decoding');
%figure(5),plot(numMeas,SNR); grid on;
