%Main Module for Simulation Run (mainSimRun2.m)
% for One-Step QNC

warning off;
addpath(genpath('../cvx'));
addpath('../trunk/code/main');
close all;
clear all;
format long;
clc;

saveFileName='resMain2run2';

RlzS=20;

nodes=100;
iterations=40;
iterationsRouting=50;
C0=1;                 %Capacity of Links
perNodeEdges=8;       %must be less than number of nodes

sigmaBig=5;
xRange=sigmaBig*4;
phiSparsityOrder=-1; %orthonormal random phi
spVec=[.05 .10 .15];
%bLenVec=[5:1:40];
bLenVec=[5:3:40];
bLenVecRouting=[5:1:20];


for rlzInd=1:RlzS
    %%%Generates the random network deployment
    [htList,GWnode,B]=GenNetCapsule(nodes,perNodeEdges);   
    edges=size(htList,1);
    
    for blInd=1:length(bLenVec)
        bLen=bLenVec(blInd);
        DeltaQ=2*xRange/(2^(bLen*C0)-1);
        sigmaQ=DeltaQ^2*0.3;    %Using the experimental results
        
        for spInd=1:length(spVec)
            sparsityFactor=spVec(spInd);
            k=round(nodes*sparsityFactor);
            numWdIters=20;
            [x,phi,xNorm1,Sdomain]=GenMess(nodes,htList,phiSparsityOrder,k,xRange,sigmaBig);
            [recErrNormL1min(:,rlzInd,blInd,spInd),recErrNormBP(:,rlzInd,blInd,spInd)]=OneStepQNCCapsule2(iterations,nodes,edges,DeltaQ,htList,x,GWnode,phi,sigmaBig,numWdIters,sparsityFactor,sigmaQ);
            xNormOneStepQNC(rlzInd,blInd,spInd)=norm(x,2);
        end
        [recErrNormRouting(:,rlzInd,blInd)]=RouteCapsule(nodes,edges,iterationsRouting,DeltaQ,htList,x,GWnode);
        xNormPF(rlzInd,blInd)=norm(x,2);
        fprintf([num2str(bLen) '-']);
    end
    fprintf(['- Realization ' num2str(rlzInd) '/' num2str(RlzS) ' is done.']);
    fprintf('\n');
    doneRlz=rlzInd;
    save(saveFileName,'doneRlz','RlzS','nodes','iterations','iterationsRouting','perNodeEdges','sigmaBig','phiSparsityOrder','spVec','bLenVec','bLenVecRouting','edges','xNormOneStepQNC','xNormPF','recErrNormL1min','recErrNormBP','recErrNormRouting');
end



