%Quantized Network Coding: Main Module for RIP Analysis, and compare with
%Gaussian IID entries, in terms of concentration of L2-norms
format long;
close all;
clear all;
clc;

%Network Parameters
nodes=300;              %No of Nodes
ports=6;                %No of Gateway ports
edges=2200;             %No of Edges
iterations=25;         %No of Iterations

%Range of Sparsity Factor for Messages
spVec=linspace(0.05,0.75,10);


%RIP Analysis Params
vRlzs=1000;
PsiRlzs=50;

%Delta Values
delta1=1;
delta2=sqrt(2)-1;
delta3=0.01;

%Generate Random vectors (sp-sparse)
for spIdx=1:length(spVec)
    sp=spVec(spIdx);
    for vRlz=1:vRlzs
        v{vRlz,spIdx}=zeros(nodes,1);
        support=randperm(nodes);
        support=support(1:round(sp*nodes));
        v{vRlz,spIdx}(support)=(rand(round(sp*nodes),1)-.5);
        v{vRlz,spIdx}=v{vRlz,spIdx}/norm(v{vRlz,spIdx},2);
        %v{vRlz,spIdx}=rand(nodes,1)-.5;
        
        VvecSp(vRlz)=mean(v{vRlz,spIdx}~=0);
    end
    rlSpVec(spIdx)=mean(VvecSp);
end


%Generate Different Realizations for Psi and phi
for PsiRlz=1:PsiRlzs
    PsiTot{1}=[];
    for t=2:iterations+1
        PsiTot{t}=[PsiTot{t-1}*sqrt(size(PsiTot{t-1},1));randn(ports,nodes)]/sqrt((t-1)*ports);
    end
    
    %Calculate Norm Ratios
    for t=2:iterations+1
        for spIdx=1:length(spVec)
            for vRlz=1:vRlzs
                ratio(vRlz)=norm(PsiTot{t}*v{vRlz,spIdx},2)^2/norm(v{vRlz,spIdx},2)^2;
            end
            %Obtain Percentages for sp-sparse vectors for one Psi*phi
            s1(t,spIdx,PsiRlz)=sum((ratio>(1-delta1))&(ratio<(1+delta1)))/vRlzs;
            s2(t,spIdx,PsiRlz)=sum((ratio>(1-delta2))&(ratio<(1+delta2)))/vRlzs;
            s3(t,spIdx,PsiRlz)=sum((ratio>(1-delta3))&(ratio<(1+delta3)))/vRlzs;
            %Compensation by Mean in direction of v's
            ratioComp=ratio*1/mean(ratio);
            s1compMean(t,spIdx,PsiRlz)=sum((ratioComp>(1-delta1))&(ratioComp<(1+delta1)))/vRlzs;
            s2compMean(t,spIdx,PsiRlz)=sum((ratioComp>(1-delta2))&(ratioComp<(1+delta2)))/vRlzs;
            s3compMean(t,spIdx,PsiRlz)=sum((ratioComp>(1-delta3))&(ratioComp<(1+delta3)))/vRlzs;
            myRatio{t,spIdx,PsiRlz}=ratio;
            myRatioComp{t,spIdx,PsiRlz}=ratioComp;
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
        s3MeanPsi(t,spIdx)=mean(s3(t,spIdx,:));
        s1CompMeanPsi(t,spIdx)=mean(s1compMean(t,spIdx,:));
        s2CompMeanPsi(t,spIdx)=mean(s2compMean(t,spIdx,:));
        s3CompMeanPsi(t,spIdx)=mean(s3compMean(t,spIdx,:));
        s1Gaussian(t,spIdx)=size(PsiTot{t},1)/(c*nodes*spVec(spIdx)*log(nodes/(nodes*spVec(spIdx)))/delta1);
        s2Gaussian(t,spIdx)=size(PsiTot{t},1)/(c*nodes*spVec(spIdx)*log(nodes/(nodes*spVec(spIdx)))/(delta2^2));
        s3Gaussian(t,spIdx)=size(PsiTot{t},1)/(c*nodes*spVec(spIdx)*log(nodes/(nodes*spVec(spIdx)))/(delta3^2));
        s1Gaussian(t,spIdx)=double(s1Gaussian(t,spIdx)>1);
        s2Gaussian(t,spIdx)=double(s2Gaussian(t,spIdx)>1);
        s3Gaussian(t,spIdx)=double(s3Gaussian(t,spIdx)>1);
    end
    numMeasVec(t)=size(PsiTot{t},1);
end

xMatrix=repmat([2:1:iterations+1]',1,length(spVec));
xMatrix2=repmat(numMeasVec(2:end)',1,length(spVec));
yMatrix=repmat(rlSpVec,length([2:1:iterations+1]),1);
yMatrix=repmat(round(rlSpVec*nodes),length([2:1:iterations+1]),1);


figure(2),subplot(3,3,1),surf(xMatrix2,yMatrix,s1MeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1');
figure(2),subplot(3,3,2),surf(xMatrix2,yMatrix,s2MeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1');
figure(2),subplot(3,3,3),surf(xMatrix2,yMatrix,s3MeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=0.01');

figure(2),subplot(3,3,4),surf(xMatrix2,yMatrix,s1CompMeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1, compensated');
figure(2),subplot(3,3,5),surf(xMatrix2,yMatrix,s2CompMeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1, compensated');
figure(2),subplot(3,3,6),surf(xMatrix2,yMatrix,s3CompMeanPsi(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=0.01, compensated');

figure(2),subplot(3,3,7),surf(xMatrix2,yMatrix,s1Gaussian(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=1, Gaussian Bound');
figure(2),subplot(3,3,8),surf(xMatrix2,yMatrix,s2Gaussian(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=\surd{2}-1, Gaussian Bound');
figure(2),subplot(3,3,9),surf(xMatrix2,yMatrix,s3Gaussian(2:end,:)); grid on; xlabel('Number of Measurements'); ylabel('Sparsity'); zlabel('Percentage'); title('\delta_{sparsity}=0.01, Gaussian Bound');
