%Quantized Network Coding: Main Module for Norm Analysis
format long;
close all;
clear all;
clc;

%Network Parameters
nodes=6 ;              %No of Nodes
edges=10;             %No of Esges
iterations=25;         %No of Iterations

Delta=0.00001;
%Generate Random vectors (2sp-sparse)
x=randn(nodes,1);
for t=1:iterations+1
    n{t}=zeros(edges,1);
end

%Generate Different Realizations for Psi and phi
[htList,GWnode,A,F,B,phi]=generateQNCnorm(nodes, edges, iterations);
[Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],n,A,F,B); 
