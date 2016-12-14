%Test Approximations

close all;
clear all;
clc;

close all;
clear all;
clc;

nodes=100;
edges=1100;
iterations=40;
delta=sqrt(2)-1;
eps=delta/sqrt(2);
k=10;

%Generate Network Deployment
[htList,GWnode,B1s]=GenNetCapsule(nodes,edges); 


%Generate Network Coding Coefficients
for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
    basisVecs=RandOrthMat(length(inEdges))';
    %NonZero A matrix
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            while(1)
            A(eOut,node)=randn;
            if(abs(A(eOut,node))<=1)
               break; 
            end
            end
        end
    end
        %Remove extra OutEdges
        outEdges(length(inEdges)+1:end)=[];
    %F3,Fothers
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F(eOut,eIn)=basisVecs(eInIndx,eOutIndx);
        end
    end
    %Normalization to avoid overflow
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        sumOverIns=0;
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            sumOverIns=sumOverIns+abs(F(eOut,eIn));
        end
        if(sumOverIns>0)
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F(eOut,eIn)=F(eOut,eIn)/sumOverIns;
        end
        end
    end
end

%Calculate Sigmas of PsiTot
Asigma2=double(A~=0);
Fmult=eye(edges,edges);
PsiTotSigma2=[];
vRlzs=1000;
randVecs=rand(vRlzs,nodes)-0.5;
c=0.2;
for t=3:iterations+1
    Fmult=F*Fmult;
    PsiSigma2{t}=B1s*(Fmult.^2)*Asigma2;
    PsiTotSigma2=[PsiTotSigma2;PsiSigma2{t}];
    %PsiTotSigma2=[PsiTotSigma2*c;PsiSigma2{t}*sqrt(1-c^2)];
        for vInd=1:size(randVecs,1)
            ySigma2=(PsiTotSigma2*(randVecs(vInd,:)'.^2))';
            %Find top 5% biggest coef's
            [sorted]=sort(ySigma2,'descend');
            lL=round(length(sorted)*0.05);
            %lL=5;
            coefsBig=sorted(1:lL);
            coefsSmall=sorted(lL:end);
            energyComp(vInd)=sum(coefsBig)/sum(sorted);
            varSmallCoefs(vInd)=std(coefsSmall)/mean(coefsSmall);
        end
        eC1(t)=mean(energyComp);
        eC2(t)=min(energyComp);
        vS1(t)=mean(varSmallCoefs);
        vS2(t)=min(varSmallCoefs);
end

figure,plot(eC1,'r'); hold on; plot(eC2,'b'); grid on; xlabel('t'); legend('Mean Energy Compaction','Minimum Energy Compaction'); ylabel('Energy Compacted in 10% Biggest Weights');
figure,plot(vS1,'r'); hold on; plot(vS2,'b'); grid on; xlabel('t'); 


