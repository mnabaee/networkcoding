%Tail Probability Evaluation

close all;
clear all;
clc;
format long;

nodes=100;
edges=1500;

%lowDeltaVec=linspace(0.05,(4*sqrt(2)-1)/(4*sqrt(2)-3)-0.05,8);
lowDeltaVec=linspace(0.05,(4*sqrt(2)-4)/(4*sqrt(2)-3)-0.02,8);
upDeltaVec=(4*sqrt(2)-4)-(4*sqrt(2)-3)*lowDeltaVec;

%lowDeltaVec=[0.6:0.1:0.999];
%upDeltaVec=[0.6:0.5:8];

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
            F(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
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
for t=3:35
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
                OmegaVal1=exp(-j*omegaVec)./(-j*omegaVec);
                OmegaVal2=exp(-j*omegaVec)./(-j*omegaVec);
                for i=1:m
                    OmegaVal1=OmegaVal1./(sqrt(1-2*j*omegaVec*yComp1Sigma2(i)));
                    OmegaVal2=OmegaVal2./(sqrt(1-2*j*omegaVec*yComp2Sigma2(i)));
                end
                
                for ctIndlow=1:length(lowDeltaVec)
                    eps=lowDeltaVec(ctIndlow)/sqrt(2);
                    tailProb1low(t,ctIndlow,vInd)=1/(2*pi)*sum(OmegaVal1.*(exp(j*eps*omegaVec)))*omegaDel+0.5;
                    tailProb2low(t,ctIndlow,vInd)=1/(2*pi)*sum(OmegaVal2.*(exp(j*eps*omegaVec)))*omegaDel+0.5;
                end
                for ctIndup=1:length(upDeltaVec)
                    eps=upDeltaVec(ctIndup)/sqrt(2);
                    tailProb1up(t,ctIndup,vInd)=1-1/(2*pi)*sum(OmegaVal1.*(exp(-j*eps*omegaVec)))*omegaDel-0.5;                    
                    tailProb2up(t,ctIndup,vInd)=1-1/(2*pi)*sum(OmegaVal2.*(exp(-j*eps*omegaVec)))*omegaDel-0.5;
                end

        end
                %Gaussian Case
                OmegaValgaussian=exp(-j*omegaVec)./(-j*omegaVec)./(sqrt(1-2*j*omegaVec*(1/m)).^m);
                
                for ctIndlow=1:length(lowDeltaVec)
                    eps=lowDeltaVec(ctIndlow)/sqrt(2);
                    tPglow(t,ctIndlow)=real(1/(2*pi)*sum(OmegaValgaussian.*(exp(j*eps*omegaVec)))*omegaDel)+0.5;
                    tP1low(t,ctIndlow)=max(real(tailProb1low(t,ctIndlow,:)));
                    tP2low(t,ctIndlow)=max(real(tailProb2low(t,ctIndlow,:)));
                end
                for ctIndup=1:length(upDeltaVec)
                    eps=upDeltaVec(ctIndup)/sqrt(2);
                    tPgup(t,ctIndup)=real(1-1/(2*pi)*sum(OmegaValgaussian.*(exp(-j*eps*omegaVec)))*omegaDel)-0.5;
                    tP1up(t,ctIndup)=max(real(tailProb1up(t,ctIndup,:)));
                    tP2up(t,ctIndup)=max(real(tailProb2up(t,ctIndup,:)));
                end
            mVec(t)=m;
        end
        disp(t);
end

save resLowUp001500% mVec tP1low tP1up tP2low tP2up tPglow tPgup nodes edges upDeltaVec lowDeltaVec;

figure(1), hold on; grid on
for i=1:size(tP1low,2)
    plot(mVec,tP1low(:,i),'r-^');
    plot(mVec,tP2low(:,i),'b-o');
    plot(mVec,tPglow(:,i),'g-s');
    xlabel('m'); ylabel('Probability of Left Tail');
end

figure(2), hold on; grid on
for i=1:size(tP1up,2)
    plot(mVec,tP1up(:,i),'r-^');
    plot(mVec,tP2up(:,i),'b-o');
    plot(mVec,tPgup(:,i),'g-s');
    xlabel('m'); ylabel('Probability of Right Tail');
end


