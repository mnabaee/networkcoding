%Main Module for Simulation Run (mainSimRun5.m)

close all;
clear all;
format long;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

FontSize=11;

nodes=100;
iterations=40;
C0=1;
q=10; xRange=q;

RlzS=150;
   
edges=1100;
saveFileName='resTest';

spVec=[0.1 0.2 0.3];
bLenVec=[1:40];

for rlzInd=1:RlzS
    [htList,GWnode,B]=GenNetCapsule(nodes,edges); 
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList,xRange); 
    [Psi,PsiTot]=calculateQNC(iterations,A,F,B); 
    numPorts(rlzInd)=size(B,1);
   
    for spInd=1:length(spVec)
        sp=spVec(spInd);
        [x,phi,xNormsQNC(spInd,rlzInd)]=GenMess(nodes,sp,q);
        
        for blInd=1:length(bLenVec)
        bLen=bLenVec(blInd);
        Delta=2*q/(2^(bLen*C0)-1);
        
        [zTot]=simulateQNC(iterations,Delta,x,A,F,B);
        [recErrNormL1{spInd,blInd,rlzInd}]=L1minDec(PsiTot,zTot,phi,x);
        [recErrNormPi{spInd,blInd,rlzInd}]=pInvDec(PsiTot,zTot,x); 
        end
    end
    
    for blInd=1:length(bLenVec)
        bLen=bLenVec(blInd);
        Delta=2*q/(2^(bLen*C0)-1);
        [recErrNormPF{blInd,rlzInd}]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);
        xNormsPF(spInd,rlzInd)=norm(x,2);
    end
    disp(['-- Run ' num2str(rlzInd) ' out of ' num2str(RlzS) ' Finished. ---------------------- ']);
end

save(saveFileName);



