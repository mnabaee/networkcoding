%Tail Probability Evaluation
%with compensation
%uniform number of outgoing edges at all nodes
%Does smoothing in direction of network deployments

close all;
clear all;
clc;
format long;

edges=1700;
saveFileName='resMain7run1';
saveFileName=[saveFileName '_' num2str(edges) 'edges'];

nodes=100;

deltaVec=linspace(0.2,sqrt(2)-1,5);
depRlzs=20;

vRlzs=100;
randVecs=rand(vRlzs,nodes)-0.5;
for vInd=1:size(randVecs,1)
    randVecs(vInd,:)=randVecs(vInd,:)/(norm(randVecs(vInd,:),2));
end

%matlabpool
%spmd


for deplInd=1:depRlzs

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
    %F3,Fothers: the same in here
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
            F3(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
        end
    end
end

GWports=length(B1s);
%Calculate BF(t) and Tail Probabilities
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);

for t=3:30
    %Calculating BF(t)'s
    if(t==3)
        Fprod=F3;
        BFconc=[B1s;B1s*Fprod];
    else
        Fprod=F*Fprod;
        BFconc=[BFconc;B1s*Fprod];
    end
    m=size(BFconc,1);
    mVec(deplInd,t)=m;
    
    for vInd=1:size(randVecs,1)
        %Calculating c(e1,e2,v1,v2)
        %Calculating c2(l1,l2)
        [eNonZero,vNonZero]=find(A~=0);
        for l1=1:length(eNonZero)
            e1=eNonZero(l1);
            v1=vNonZero(l1);
            for l2=1:length(eNonZero)
                e2=eNonZero(l2);
                v2=vNonZero(l2);
                c2(l1,l2)=sum(BFconc(:,e1).*BFconc(:,e2))*randVecs(vInd,v1)*randVecs(vInd,v2);
            end
        end

        lambdas{vInd}=real(eig(c2));
        disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- eig Value - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
    end
    %Normalization for Compensation E()=1
    for vInd=1:size(randVecs,1)
        lambdasCompensated{vInd}=lambdas{vInd}/sum(lambdas{vInd});
        
        omegaVal=exp(-j*omegaVec)./omegaVec;
        for l=1:length(lambdasCompensated{vInd})
            omegaVal=omegaVal./sqrt(1-2*j*omegaVec*lambdasCompensated{vInd}(l));
        end
        for deltaInd=1:length(deltaVec)
            eps=deltaVec(deltaInd)/sqrt(2);
            tailProbV(deplInd,t,deltaInd,vInd)=real(1-1/pi*omegaDel*sum(omegaVal.*sin(eps*omegaVec)));
        end
        disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- Tail Prob - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
    end
    
    for deltaInd=1:length(deltaVec)
        [max1,max2]=max(tailProbV(deplInd,t,deltaInd,:));
        tailProbWorst(deplInd,t,deltaInd)=max1;
        tailProbWorstVec(deplInd,t,deltaInd)=max2;
        tailProbWorst(deplInd,t,deltaInd);
    end    
    disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- t= ' num2str(t) ' is done.']);
    save(saveFileName,'mVec','randVecs','tailProbWorst','tailProbWorstVec','tailProbV','edges','nodes','deltaVec');
end
end

for t=1:size(tailProbWorst,2)
for deltaInd=1:size(tailProbWorst,3)
    smoothedTailProbWorst(t,deltaInd)=mean(tailProbWorst(:,t,deltaInd));
    smoothedmVec(t)=mean(mVec(:,t));
end
end
save(saveFileName,'mVec','randVecs','tailProbWorst','tailProbWorstVec','tailProbV','edges','nodes','deltaVec','smoothedTailProbWorst','smoothedmVec');

%end
%matlabpool close;


