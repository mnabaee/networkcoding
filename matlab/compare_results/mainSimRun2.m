%Main Module for Simulation Run (mainSimRun2.m)
%This one uses a specific model for choosing decoder

close all;
clear all;
format long;
addpath(genpath('../cvx'));
cvx_setup;
clc;

nodes=100;
iterations=40;
C0=1;
q=10; xRange=q;
RlzS=50;

radioDecay=.15;
connPerc=.9;

innerR=sqrt(2)/2*.85;
outerR=sqrt(2)/2*.95;
   
saveFileName='resMain2Run102-15-9-85-95';


spVec=[0.01,0.05,0.1];
bLenVec=[1:1:30];
bLenVecPF=[1:1:40];
epsKvec=[0,2*10^(-3),2*10^(-2),2*10^(-1)];
rlzInd=1;
while(1) 
    [htList,GWnode,B,xLoc,yLoc]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);
	[GWnode,B]=pickDecoder(xLoc,yLoc,htList,innerR,outerR);
    edges=size(htList,1);
    fprintf(['run=' num2str(rlzInd) ' -Network Generated with ' num2str(edges) ' edges->']);
    
    fprintf(['QandNC: ']);
    [Awindow,Fwindow]=calculateAFwindows(nodes,edges,htList);
    [x,phi]=GenMess_revised(nodes,spVec(end),q,epsKvec(end));
    for blInd=1:13
        [recErrNormQandNC{blInd,rlzInd},recXQandNC{blInd,rlzInd},delay{blInd,rlzInd}]=QandNC_revised(nodes,edges,htList,x,GWnode,blInd,C0,q,B,Awindow,Fwindow);
        xNormsQandNC(rlzInd)=norm(x,2);
        fprintf([num2str(blInd) '-']);
    end
    
    fprintf([' QNC:']);  
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
    [PsiTot,epsSquaredCoefs]=calculateQNC(iterations,A,F,B); 
    numPorts(rlzInd)=size(B,1);
    
    for spInd=1:length(spVec)
        sp=spVec(spInd);
        fprintf(['sp=' num2str(sp) ':']);
        for epsKind=1:length(epsKvec)
            epsK=epsKvec(epsKind);
            fprintf(['epsK=' num2str(epsK) ':']);
            [x,phi]=GenMess_revised(nodes,sp,q,epsK);
            for blInd=1:length(bLenVec)
                bLen=bLenVec(blInd);
                Delta=2*q/(2^(bLen*C0)-1);
                [zTot]=simulateQNC(iterations,Delta,x,A,F,B);
                [recErrNormL1{spInd,epsKind,blInd,rlzInd}]=L1MINdecoder(zTot,PsiTot,phi,x,Delta,epsSquaredCoefs,edges);
                xNormL1(spInd,epsKind,blInd,rlzInd)=norm(x,2);
                fprintf([num2str(bLen) '-']);
            end
        end
    end

    for blInd=1:length(bLenVecPF)
        bLen=bLenVecPF(blInd);
        Delta=2*q/(2^(bLen*C0)-1);
        [x]=GenMess_revised(nodes,spVec(end),q,epsKvec(end));
        [recErrNormPF{blInd,rlzInd}]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);
        xNormsPF(spInd,rlzInd)=norm(x,2);
    end
    fprintf('Routing Done. \n');
    
    doneRun=rlzInd;
    clear A; clear F; clear B; clear htList; clear Psi; clear PsiTot; clear zTot; 
    save(saveFileName);
    if(doneRun==RlzS)
       break; 
    else
        rlzInd=rlzInd+1;
    end
end


