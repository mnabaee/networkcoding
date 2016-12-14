%Quantized Network Coding: Main Module for RIP Analysis, designed NC
format long;
close all;
clear all;
clc;

%Network Parameters
nodes=150;              %No of Nodes
edges=2000;             %No of Edges
iterations=25;         %No of Iterations

%Range of Sparsity Factor for Messages
spVec=linspace(0.05,0.8,7);

%RIP Analysis Params
vRlzs=1000;
PsiRlzs=50;

%Generate Random vectors (sp-sparse)
for spIdx=1:length(spVec)
    sp=spVec(spIdx);
    for vRlz=1:vRlzs
        v{vRlz,spIdx}=zeros(nodes,1);
        support=randi(nodes,round(sp*nodes),1);
        v{vRlz,spIdx}(support)=(rand(round(sp*nodes),1)-.5);
        v{vRlz,spIdx}=v{vRlz,spIdx}/norm(v{vRlz,spIdx},2);
        VvecSp(vRlz)=mean(v{vRlz,spIdx}~=0);
    end
    rlSpVec(spIdx)=mean(VvecSp);
end

%Generate an empty vector for noise
for t=1:iterations+1
    n{t}=zeros(edges,1);
end

%Generate Different Realizations for Psi and phi
for PsiRlz=1:PsiRlzs
    [htList,GWnode,x,phi,A,F,B]=generateQNCdsgn(nodes, edges, iterations,0.001,10,0.1); 
    [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[0.001],[x],n,A,F,B); 
    %Calculate Norm Ratios
    for t=2:iterations+1
        for spIdx=1:length(spVec)
            for vRlz=1:vRlzs
                ratio(vRlz)=norm(PsiTot{t}*phi*v{vRlz,spIdx},2)/norm(v{vRlz,spIdx},2);
            end
            %Obtain Percentages for sp-sparse vectors for one Psi*phi
            s1(t,spIdx,PsiRlz)=sum((ratio>(1-1))&(ratio<(1+1)))/vRlzs;
            s2(t,spIdx,PsiRlz)=sum((ratio>(1-(sqrt(2)-1)))&(ratio<(1+(sqrt(2)-1))))/vRlzs;
            %Compensation by Mean in direction of v's
            ratioComp=ratio*1/mean(ratio);
            s1compMean(t,spIdx,PsiRlz)=sum((ratioComp>(1-1))&(ratioComp<(1+1)))/vRlzs;
            s2compMean(t,spIdx,PsiRlz)=sum((ratioComp>(1-(sqrt(2)-1)))&(ratioComp<(1+(sqrt(2)-1))))/vRlzs;
            
        end
    end
    disp(num2str(PsiRlz));
end

%Calculate Average over Psi Realizations
c=0.28;
for t=2:iterations+1
    for spIdx=1:length(spVec)
        s1MeanPsi(t,spIdx)=mean(s1(t,spIdx,:));
        s2MeanPsi(t,spIdx)=mean(s2(t,spIdx,:));
        s1CompMeanPsi(t,spIdx)=mean(s1compMean(t,spIdx,:));
        s2CompMeanPsi(t,spIdx)=mean(s2compMean(t,spIdx,:));
        s1Gaussian(t,spIdx)=size(PsiTot{t},1)/(c*nodes*spVec(spIdx)*log(nodes/(nodes*spVec(spIdx)))/1);
        s2Gaussian(t,spIdx)=size(PsiTot{t},1)/(c*nodes*spVec(spIdx)*log(nodes/(nodes*spVec(spIdx)))/((sqrt(2)-1)^2));
    end
    numMeasVec(t)=size(PsiTot{t},1);
end

xMatrix=repmat([2:1:iterations+1]',1,length(spVec));
xMatrix2=repmat(numMeasVec(2:end)',1,length(spVec));
yMatrix=repmat(rlSpVec,length([2:1:iterations+1]),1);

% figure(1),subplot(2,2,1),surf(xMatrix,yMatrix,s1MeanPsi(2:end,:)); grid on; xlabel('t'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1');
% figure(1),subplot(2,2,2),surf(xMatrix,yMatrix,s2MeanPsi(2:end,:)); grid on; xlabel('t'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1');
% figure(1),subplot(2,2,3),surf(xMatrix,yMatrix,s1CompMeanPsi(2:end,:)); grid on; xlabel('t'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1, compensated');
% figure(1),subplot(2,2,4),surf(xMatrix,yMatrix,s2CompMeanPsi(2:end,:)); grid on; xlabel('t'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1, compensated');

figure(2),subplot(3,2,1),surf(xMatrix2,yMatrix,s1MeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1');
figure(2),subplot(3,2,2),surf(xMatrix2,yMatrix,s2MeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1');
figure(2),subplot(3,2,3),surf(xMatrix2,yMatrix,s1CompMeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1, compensated');
figure(2),subplot(3,2,4),surf(xMatrix2,yMatrix,s2CompMeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1, compensated');
figure(2),subplot(3,2,5),surf(xMatrix2,yMatrix,s1Gaussian(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1, Gaussian Bound');
figure(2),subplot(3,2,6),surf(xMatrix2,yMatrix,s2Gaussian(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1, Gaussian Bound');

