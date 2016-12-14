%Main Module for Simulation Run (mainSimRun3.m)
% of Sparse QNC

warning off;
close all;
clear all;
format long;
clc;

saveFileName='resMain3run6';

RlzS=100;

nodes=100;
iterations=30;
iterationsRouting=50;
C0=1;                 %Capacity of Links
perNodeEdges=12;       %must be less than number of nodes

sigmaBig=5;
xRange=sigmaBig*4;
phiSparsityOrder=-1; %2
%spVec=[.1 .2 .3];
spVec=[.05 .10 .15];
bLenVec=[5:1:40];
bLenVecRouting=[5:1:20];

densityRow=1;

  
for rlzInd=1:RlzS
    %%%Generates the random network deployment
    [htList,GWnode,B]=GenNetCapsule(nodes,perNodeEdges);   
    edges=size(htList,1);
    
    %%%Generating NC coefficients (dense)
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
    [Psi,PsiTot]=calculateQNC(iterations,A,F,B); 
    for spInd=1:length(spVec)
        sparsityFactor=spVec(spInd);
        k=round(nodes*sparsityFactor);
        %Generate Messages
        [x,phi,xNorm1,Sdomain]=GenMess(nodes,htList,phiSparsityOrder,k,xRange,sigmaBig);
        fprintf(['sparsity factor ' num2str(sparsityFactor) ': ']);
        %Perform QNC for different block lengths
        for blInd=1:length(bLenVec)
            bLen=bLenVec(blInd);
            DeltaQ=2*xRange/(2^(bLen*C0)-1);
            sigmaQ=DeltaQ^2*0.2;    %Using the experimental results
            [zTot,numMeas(:,rlzInd,blInd,spInd),nEffTot]=simulateQNC(iterations,DeltaQ,x,A,F,B,PsiTot);
            xNorm(rlzInd,blInd,spInd)=norm(x,2);
            %BP based Decoding :|
            %disp('Start Decoding');
            numWdIters=20;
            tic;
            [recX(:,rlzInd,blInd,spInd),recErrNormBP(:,rlzInd,blInd,spInd),recErrNormWindow{rlzInd,blInd,spInd}]=BPdecoder2(x,Sdomain,zTot,PsiTot,F,A,B,phi,k,sigmaBig,sigmaQ,numWdIters);
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
    
    
    fprintf('Routing: ');
    %Routing based Packet Forwarding
    [x,phi,xNorm1,Sdomain]=GenMess(nodes,htList,phiSparsityOrder,k,xRange,sigmaBig);
    xNormRouting(rlzInd)=norm(x,2);
    for blInd=1:length(bLenVecRouting)
         bLen=bLenVecRouting(blInd);
         DeltaQ=2*xRange/(2^(bLen*C0)-1);
         [recErrNormRouting(:,rlzInd,blInd)]=RouteCapsule(nodes,edges,iterationsRouting,DeltaQ,htList,x,GWnode);
         fprintf([num2str(bLen) '-'])
    end
    fprintf('\n');
    doneRlz=rlzInd;
    save(saveFileName,'doneRlz','RlzS','nodes','iterations','iterationsRouting','perNodeEdges','sigmaBig','phiSparsityOrder','spVec','bLenVec','bLenVecRouting','densityRow','edges','xNorm','recErrNormBP','recErrNorml1min','recErrNormPinv','decTimeBP','decTimeL1','decTimePI','xNormRouting','recErrNormRouting');
    disp(['- Realization ' num2str(rlzInd) '/' num2str(RlzS) ' is done in ' num2str(sum(sum(decTimeBP(rlzInd,:,:)))+sum(sum(decTimeL1(rlzInd,:,:)))+sum(sum(decTimePI(rlzInd,:,:)))) ' seconds.']);
end



