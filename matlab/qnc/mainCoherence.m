%Quantized Network Coding: Main Module for Coherence Analysis
format long;
close all;
clear all;
clc;

%Network Parameters
nodes=80;              %No of Nodes
edges=400;             %No of Esges
iterations=25;         %No of Iterations

%Quantization
q=10;
Delta=0.1;

%Sparsity Factor of Messages
sp=0.2;

%RIP Analysis Params
vRlzs=1000;
PsiRlzs=20;

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
    [htList,GWnode,x,phi,A,F,B]=generateQNCdsgn(nodes, edges, iterations,Delta,q,sp); 
    [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],n,A,F,B); 
    
    [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,sp);
    [Psi2,nEff,PsiTot2,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],n,A,F,B); 
    
    %Calculate Coherence for each realization
    for t=2:iterations+1
        cohMarginal(PsiRlz,t)=cohMat(Psi{t});
        cohTot(PsiRlz,t)=cohMat(PsiTot{t});
        cohMarginal2(PsiRlz,t)=cohMat(Psi2{t});
        cohTot2(PsiRlz,t)=cohMat(PsiTot2{t});
            %Possible Sparsity without Noise
            possSpar(PsiRlz,t)=.5*(1+1/cohTot(PsiRlz,t));
            possSpar2(PsiRlz,t)=.5*(1+1/cohTot2(PsiRlz,t));
        %Lower Bound
        if(size(PsiTot{t},1)>=nodes)
            lowerCohTot(PsiRlz,t)=0; 
            LowerpossSpar(PsiRlz,t)=nodes;
        else
            lowerCohTot(PsiRlz,t)=sqrt((nodes-size(PsiTot{t},1))/(size(PsiTot{t},1)*(nodes-1))); 
            LowerpossSpar(PsiRlz,t)=.5*(1+1/lowerCohTot(PsiRlz,t));
        end
        %Gaussian IID
        giidCohTot(PsiRlz,t)=cohMat(randn(size(PsiTot{t})));
        GiidpossSpar(PsiRlz,t)=.5*(1+1/giidCohTot(PsiRlz,t));
        
    end
    disp(num2str(PsiRlz));
end
meanCohMarg=mean(cohMarginal);
meanCohMarg2=mean(cohMarginal2);
meanCohTot=mean(cohTot);
meanCohTot2=mean(cohTot2);
meanLowerCoh=mean(lowerCohTot);
meanGiidCohTot=mean(giidCohTot);

meanpossSpar=mean(possSpar);
meanLowerpossSpar=mean(LowerpossSpar);
meanGiidpossSpar=mean(GiidpossSpar);


figure(1),plot(meanCohMarg,'r.-'); hold on;
plot(meanCohMarg2,'r<-'); 
plot(meanCohTot,'b^-'); 
plot(meanCohTot2,'b<-'); 
plot(meanLowerCoh,'go-'); 
plot(meanGiidCohTot,'k*-'); 
grid on; legend('Marginal','Marginal2','Total','Total2','Lower Bound','Gaussian IID');
xlabel('Time Slot'); ylabel('Coherence');

figure(2), hold on;
plot(meanpossSpar,'b^-'); 
plot(meanLowerpossSpar,'go-'); 
plot(meanGiidpossSpar,'k*-'); 
grid on; legend('Possible Sparsity (Total)','Upper Bound','Gaussian IID');
xlabel('Time Slot'); ylabel('Possible Sparsity');
