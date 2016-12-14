%Tail Probability Evaluation

close all;
clear all;
clc;
format long;

nodes=100;
edges=3000;
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
        %outEdges(length(inEdges)+1:end)=[];
    %F3,Fothers
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F(eOut,eIn)=basisVecs(eInIndx,eOutIndx);
            F3(eOut,eIn)=1/sqrt(nodes-1);
        end
    end
%     %Normalization to avoid overflow
%     for eOutIndx=1:length(outEdges)
%         eOut=outEdges(eOutIndx);
%         sumOverIns=0;
%         for eInIndx=1:length(inEdges)
%             eIn=inEdges(eInIndx);
%             sumOverIns=sumOverIns+abs(F(eOut,eIn));
%         end
%         if(sumOverIns>0)
%         for eInIndx=1:length(inEdges)
%             eIn=inEdges(eInIndx);
%             F(eOut,eIn)=F(eOut,eIn)/sumOverIns;
%         end
%         end
%     end
end




%Calculate Sigmas of PsiTot
Asigma2=double(A~=0);
Fmult=eye(edges,edges);
PsiTotSigma2=[];
vRlzs=300;
randVecs=rand(vRlzs,nodes-1)-0.5;
for vInd=1:size(randVecs,1)
    randVecs(vInd,:)=randVecs(vInd,:)/(norm(randVecs(vInd,:),2));
end
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);
for t=3:40
    if(t==3)
        Fmult=F3;
    else
        Fmult=F*Fmult;
    end
    PsiSigma2{t}=B1s*(Fmult.^2)*Asigma2;
    PsiSigma2{t}(:,GWnode)=[];
    PsiTotSigma2=[PsiTotSigma2;PsiSigma2{t}];
    m=size(PsiTotSigma2,1);
    
    %Normalization of E(normZ)
    comp1PsiTotSigma2=PsiTotSigma2;
    for v=1:size(PsiTotSigma2,2)
        sumV(v)=sum(PsiTotSigma2(:,v));
        comp1PsiTotSigma2(:,v)=PsiTotSigma2(:,v)/sumV(v);
    end
    
    %Normalization 2
    comp2PsiTotSigma2=PsiTotSigma2;
    for vInd=1:size(randVecs,1)
        SumVec(vInd)=sum((PsiTotSigma2*(randVecs(vInd,:)'.^2))');
    end
    coefComp=mean(SumVec);
    comp2PsiTotSigma2=PsiTotSigma2/(coefComp);
    
        if(1)
        for vInd=1:size(randVecs,1)
            %calculates sigmaIx for different x's
            yComp1Sigma2=(comp1PsiTotSigma2*(randVecs(vInd,:)'.^2))';
            yComp2Sigma2=(comp2PsiTotSigma2*(randVecs(vInd,:)'.^2))';
            %ySigma2=(PsiTotSigma2*(randVecs(vInd,:)'.^2))';
                %Calculate Tail Prob
                OmegaVal1=(exp(-j*omegaVec*(1+eps))-exp(-j*omegaVec*(1-eps)))./(-j*omegaVec);
                OmegaVal2=(exp(-j*omegaVec*(1+eps))-exp(-j*omegaVec*(1-eps)))./(-j*omegaVec);
                for i=1:m
                    OmegaVal1=OmegaVal1./(sqrt(1-2*j*omegaVec*yComp1Sigma2(i)));
                    OmegaVal2=OmegaVal2./(sqrt(1-2*j*omegaVec*yComp2Sigma2(i)));
                end
                tailProb1(t,vInd)=1-1/(2*pi)*sum(OmegaVal1)*omegaDel;
                tailProb2(t,vInd)=1-1/(2*pi)*sum(OmegaVal2)*omegaDel;
        end
                OmegaValgaussian=(exp(-j*omegaVec*(1+eps))-exp(-j*omegaVec*(1-eps)))./(-j*omegaVec);
                for i=1:m
                    OmegaValgaussian=OmegaValgaussian./(sqrt(1-2*j*omegaVec*(1/m)));
                end

        mVec(t)=m;
        tailProb1Max(t)=max(real(tailProb1(t,:)));
        tailProb2Max(t)=max(real(tailProb2(t,:)));
        tailProbMaxG(t)=real(1-1/(2*pi)*sum(OmegaValgaussian)*omegaDel);
        end
        disp(t);
end

save res5 mVec tailProb1Max tailProb2Max tailProbMaxG;

figure,
subplot(2,1,1),
plot(mVec,tailProb1Max,'r-^'); hold on; grid on;
plot(mVec,tailProb2Max,'b-o');
plot(mVec,tailProbMaxG,'k-s'); legend('Our Codes-compensated1','Our Codes-compensated2','Gaussian');
xlabel('m'); ylabel('Tail Probability for eps=(sqrt(2)-1)/sqrt(2)'); title('Tail Prob vs No of Measurements for 100 nodes');
subplot(2,1,2),
plot(mVec,tailProb1Max,'r-^'); hold on; grid on;
plot(mVec,tailProb2Max,'b-o');
plot(mVec,tailProbMaxG,'k-s'); 
xlabel('m'); ylabel('Tail Probability for eps=(sqrt(2)-1)/sqrt(2)'); title('Zoomed Version');
