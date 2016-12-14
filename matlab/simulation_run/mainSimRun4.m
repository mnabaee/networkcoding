%Main Module for Simulation Run (mainSimRun4.m)

close all;
clear all;
format long;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

nodes=100;
iterations=40;
C0=1;
q=10; xRange=q;

RlzS=500;
   
edges=1400;
bLen=25;
Delta=2*q/(2^(bLen*C0)-1);

spVec=[0.1,0.2,0.3];

for rlzInd=1:RlzS
    [htList,GWnode,B]=GenNetCapsule(nodes,edges); disp(' - Network Generated.');
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList,xRange); disp(' - Network Coding Coefficients Generated.');
    [Psi,PsiTot]=calculateQNC(iterations,A,F,B); disp(' - Network Coding Functions Calculated.');
    
    for spInd=1:length(spVec)
        sp=spVec(spInd);
        [x,phi,xNorm(2*spInd-1:2*spInd,1:iterations+1,rlzInd)]=GenMess(nodes,sp,q);
        [zTot]=simulateQNC(iterations,Delta,x,A,F,B);
        [recErrNorm(2*spInd-1,:,rlzInd),numMeas(2*spInd-1,:,rlzInd)]=L1minDec(PsiTot,zTot,phi,x);
        [recErrNorm(2*spInd,:,rlzInd)]=pInvDec(PsiTot,zTot,x); numMeas(2*spInd,:,rlzInd)=numMeas(2*spInd-1,:,rlzInd);
    end
    disp(' - Quantized Network Coding Simulated.');
    
    [recErrNorm(2*length(spVec)+1,:,rlzInd)]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);
    xNorm(2*length(spVec)+1,1:iterations+1,rlzInd)=norm(x,2);
    numMeas(2*length(spVec)+1,:,rlzInd)=numMeas(2*length(spVec),:,rlzInd);
    disp(' - Routing Simulated.');

    disp(['-- Run ' num2str(rlzInd) ' out of ' num2str(RlzS) ' Finished. ---------------------- ']);
end

for i=1:2*length(spVec)+1
for j=2:iterations+1
    avgRecErrNorm(i,j)=mean(recErrNorm(i,j,:));
    avgxNorm(i,j)=mean(xNorm(i,j,:));
    avgSNR(i,j)=20*log10(avgxNorm(i,j)/avgRecErrNorm(i,j));
    avgNoMeas(i,j)=mean(numMeas(i,j,:));
end
end
save resRun3;
figure(1),plot(avgNoMeas(1,2:end)/nodes,avgSNR(1,2:end),'r-s'); hold on;
figure(1),plot(avgNoMeas(3,2:end)/nodes,avgSNR(3,2:end),'b-^');
figure(1),plot(avgNoMeas(5,2:end)/nodes,avgSNR(5,2:end),'g-o');
figure(1),plot(avgNoMeas(7,2:end)/nodes,avgSNR(7,2:end),'c-+');
xlabel('Compression Ratio (m/n)'); ylabel('SNR [dB]');
legend(['QNC-sp=' num2str(spVec(1))],['QNC-sp=' num2str(spVec(2))],['QNC-sp=' num2str(spVec(3))],'Packet Forwarding'); grid on;


