%Main Module for Simulation Run (mainSimRun1.m)
% of Sparse QNC

warning off;
close all;
clear all;
format long;
clc;

saveFileName='resMain1run1';

RlzS=100;

nodes=100;
iterations=20;
C0=1;                 %Capacity of Links
perNodeEdges=4;       %must be less than number of nodes

sigmaBig=5;
xRange=sigmaBig*4;
phiSparsityOrder=-1; %2
spVec=[.1 .2 .3];
bLenVec=[10:5:70];

densityRow=1;

  
for rlzInd=1:RlzS
    %%%Generates the random network deployment
    [htList,GWnode,B]=GenNetCapsule(nodes,perNodeEdges);   
    
    edges=size(htList,1);
    %%%Generating NC coefficients (sparsely)
    %[A,F]=GencoefOneStep(nodes,edges,iterations,htList,densityRow); %for One Step
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
    [Psi,PsiTot]=calculateQNC(iterations,A,F,B); 
    for spInd=1:length(spVec)
        sparsityFactor=spVec(spInd);
        k=round(nodes*sparsityFactor);
        %Generate Messages
        [x,phi,xNorm1,Sdomain]=GenMess(nodes,htList,phiSparsityOrder,k,xRange,sigmaBig);

        %Perform QNC for different block lengths
        for blInd=1:length(bLenVec)
            bLen=bLenVec(blInd);
            DeltaQ=2*xRange/(2^(bLen*C0)-1);
            sigmaQ=DeltaQ^2*0.2;    %Using the experimental results
            [zTot,numMeas(:,rlzInd,blInd,spInd),nEffTot]=simulateQNC(iterations,DeltaQ,x,A,F,B,PsiTot);
            xNorm(rlzInd,blInd,spInd)=norm(x,2);
            %BP based Decoding :|
            %disp('Start Decoding');
            tic;
            [recX(:,rlzInd,blInd,spInd),recErrNormBP(:,rlzInd,blInd,spInd)]=BPdecoder(x,Sdomain,zTot,PsiTot,F,A,B,phi,k,sigmaBig,sigmaQ);
            %[recX(:,rlzInd),recErrNormBP(:,rlzInd)]=BPdecoderNBP(x,zTot,PsiTot,F,A,B,phi,k,sigmaBig,sigmaQ);
            decTimeBP(rlzInd,blInd,spInd)=toc;
            
            tic;
            [recXl1min(:,rlzInd,blInd,spInd),recErrNorml1min(:,rlzInd,blInd,spInd)]=L1MINdecoder(zTot,PsiTot,phi,x,DeltaQ,A,F,B);
            decTimeL1(rlzInd,blInd,spInd)=toc;
            tic;
            [recXPinv(:,rlzInd,blInd,spInd),recErrNormPinv(:,rlzInd,blInd,spInd)]=PINVdecoder(zTot,PsiTot,phi,x);
            decTimePI(rlzInd,blInd,spInd)=toc;
            fprintf([num2str(bLen) '-']);
        end
        fprintf('\n');
    end
    disp(['- Realization ' num2str(rlzInd) '/' num2str(RlzS) ' is done.']);
end

save(saveFileName);

