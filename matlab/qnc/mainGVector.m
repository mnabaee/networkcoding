%Quantized Network Coding: Main Module for Generating Good Vectors
format long;
close all;
clear all;
addpath(genpath('C:/cvx'))
cvx_setup;
clc;

%Network Parameters
nodes=8;              %No of Nodes
edges=30;             %No of Esges
iterations=25;         %No of Iterations

%Quantization
q=10;
Delta=0.1;

%Sparsity Factor of Messages
sp=0.1;

%RIP Analysis Params
vRlzs=1000;
PsiRlzs=50;

%Generate Random vectors (2sp-sparse)
for vRlz=1:vRlzs
    v{vRlz}=zeros(nodes,1);
    support=randi(nodes,round(2*sp*nodes),1);
    v{vRlz}(support)=(rand(round(2*sp*nodes),1)-.5)*2*q;
end
for t=1:iterations+1
    n{t}=zeros(edges,1);
end

%Generate Different Realizations for Psi and phi
for PsiRlz=1:1%PsiRlzs
    [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,sp); 
    [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],n,A,F,B); 
    
%     %Fake Insertion of Psi*phi
%     phi=eye(nodes,nodes);
%     PsiTot{t}=randn(size(PsiTot{t},1),nodes);
%     
    %Calculate Norm Ratios
    for vRlz=1:vRlzs
        ratio(vRlz)=norm(PsiTot{t}*phi*v{vRlz},2)/norm(v{vRlz},2);
    end
    %Obtain Percentages for 2sp-sparse vectors for one Psi*phi
    s1(PsiRlz)=sum((ratio>1-1)&(ratio<1+1))/vRlzs;
    s2(PsiRlz)=sum((ratio>1-(sqrt(2)-1))&(ratio<1+(sqrt(2)-1)))/vRlzs;
    
    %Compensation by Mean in direction of v's
    ratio=ratio*1/mean(ratio);
    s1compMean(PsiRlz)=sum((ratio>1-1)&(ratio<1+1))/vRlzs;
    s2compMean(PsiRlz)=sum((ratio>1-(sqrt(2)-1))&(ratio<1+(sqrt(2)-1)))/vRlzs;
    disp(num2str(PsiRlz));
    
    %Find the best Vector (not compensated)
    [ratioSorted,inds]=sort(abs(ratio-1));
    bestVector=v{inds(1)};
    XbestVector=phi*bestVector;
    
end

%Perform CS on a Good Vector
zTot=PsiTot{t}*XbestVector;
    %CS Recovery
    [xRec]=L1minDec(PsiTot{t},zTot,phi);
recErrNorm=norm(XbestVector-xRec,2)


