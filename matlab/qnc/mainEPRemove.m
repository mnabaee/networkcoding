%Quantized Network Coding: Module for Testing Removal of Early Packets
format long;
close all;
clear all;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

%Network Parameters
nodes=80;              %No of Nodes
edges=500;             %No of Esges
iterations=20;         %No of Iterations

%Quantization
q=10;
Delta=0.1;

%Sparsity Factor of Messages
sp=0.2;

[htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,[sp]); save genNet; disp('QNC Generated.');
[z,n,y,y2,zTot]=simulateQNC(nodes, edges, iterations ,htList,Delta,x,A,F,B); disp('QNC Simulated.');
[Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],[n],A,F,B); disp('QNC Calculated.');
 
%Calculate Maximum Hop Distance (Gateway & Nodes)
hopDist=zeros(nodes,1);
for t=1:iterations
    for i=1:nodes
        if((Psi{t}(1,i)~=0)&(hopDist(i)==0))
            hopDist(i)=t-1;
        end
    end
end
maxHopDis=max(hopDist)

%Original Decoding with All received packets
for t=2:iterations+1
    [xRec{t}]=L1minDec(PsiTot{t}(1:end,:),zTot{t}(1:end),phi);
    recErrNorm(t)=norm(x-xRec{t},2);
    SNR(t)=10*log10(norm(x,2)/norm(x-xRec{t},2));
    numMeas(t)=length(zTot{t});
end
figure(3),plot(10*log10(recErrNorm),'b^-'); grid on; ylabel('Error Norm [dB]'); xlabel('Time Index of Decoding'); hold on;

%Ignore the received packets before MaxHopDist
initInd=(maxHopDis)*size(Psi{2},1)+1;
for t=2:iterations+1
    [xRec{t}]=L1minDec(PsiTot{t}(initInd:end,:),zTot{t}(initInd:end),phi);
    recErrNorm(t)=norm(x-xRec{t},2);
    SNR(t)=10*log10(norm(x,2)/norm(x-xRec{t},2));
    numMeas(t)=length(zTot{t});
end
figure(3),plot(10*log10(recErrNorm),'ro-'); legend('All packets','Refined packets'); grid on; ylabel('Error Norm [dB]'); xlabel('Time Index of Decoding');


