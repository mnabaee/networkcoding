%Main Module for Simulation Run (mainSimRun3.m)

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

radioDecay=.35;
connPerc=.9;
   
saveFileName='resMain1Run102-35-9';

%spVec=[0.05,0.15,0.25];
spVec=[0.01,0.05,0.1];
%spVec=[0.1];
bLenVec=[1:1:40];
epsKvec=[0,2*10^(-3),2*10^(-2),2*10^(-1)];
%epsKvec=[0];
rlzInd=1;
while(1) 
    try;
    [htList,GWnode,B]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);
    edges=size(htList,1);
    fprintf(['run=' num2str(rlzInd) ' -Network Generated with ' num2str(edges) ' edges->']);
    fprintf(['QandNC: ']);
    [Awindow,Fwindow]=calculateAFwindows(nodes,edges,htList);
    for blInd=1:10
        [x,phi]=GenMess(nodes,spVec(1),q,epsKvec(1));
        x=randn(nodes,1);
        x=(x-min(x))*(2*q)/(max(x)-min(x))-q;
        
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
            [x,phi]=GenMess(nodes,sp,q,epsK);
            for blInd=1:length(bLenVec)
                bLen=bLenVec(blInd);
                Delta=2*q/(2^(bLen*C0)-1);
                [zTot]=simulateQNC(iterations,Delta,x,A,F,B);
                [recErrNormL1{spInd,epsKind,blInd,rlzInd},noiseNorm{spInd,epsKind,blInd,rlzInd}]=L1MINdecoder(zTot,PsiTot,phi,x,Delta,epsSquaredCoefs,edges);
                xNormL1(spInd,epsKind,blInd,rlzInd)=norm(x,2);
                fprintf([num2str(bLen) '-']);
            end
        end
    end

    for blInd=1:length(bLenVec)
        bLen=bLenVec(blInd);
        Delta=2*q/(2^(bLen*C0)-1);
        [x]=GenMess(nodes,spVec(end),q,epsKvec(end));
        [recErrNormPF{blInd,rlzInd}]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);
        xNormsPF(spInd,rlzInd)=norm(x,2);
    end
    fprintf('Routing Done. \n');
    
    doneRun=rlzInd;
    save(saveFileName);
    if(doneRun==RlzS)
       break; 
    else
        rlzInd=rlzInd+1;
    end
    catch
        fprintf('!!!Error Occured!!! \n');
%        clear A; clear F; clear B; clear htList; clear Psi; clear PsiTot; clear zTot; 
    end
end


