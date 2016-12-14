%Quantized Network Coding: Main Module for RIP Analysis
format long;
close all;
clear all;
clc;

%Network Parameters
nodes=80;              %No of Nodes
edges=800;             %No of Esges
iterations=25;         %No of Iterations

%Quantization
q=10;
Delta=0.1;

%Sparsity Factor of Messages
sp=0.2;

%RIP Analysis Params
vRlzs=1000;
PsiRlzs=30;

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
for PsiRlz=1:PsiRlzs
    [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,sp); 
    [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],n,A,F,B); 
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
end

figure(1),plot(s1,'r'); hold on;
figure(1),plot(s2,'b'); hold on;
figure(1),plot(s1compMean,'r-.'); hold on;
figure(1),plot(s2compMean,'b-.'); hold on; xlabel('Realization of Psi and phi'); ylabel('Percentage'); legend('\delta_{2k}=1','\delta_{2k}=1 compensated','\delta_{2k}=sqrt(2)-1','\delta_{2k}=sqrt(2)-1 compensated');
grid on;