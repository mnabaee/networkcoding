%Tail Probability Evaluation
%with compensation
%uniform number of outgoing edges at all nodes

close all;
clear all;
clc;
format long;

nodes=100;
edges=1100;
delta=sqrt(2)-1;
eps=delta/sqrt(2)-10^-5;
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
    %F3,Fothers: the same in here
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
            F3(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
            %F3(eOut,eIn)=1/length(inEdges);
            %F(eOut,eIn)=1/length(inEdges);
        end
    end
end

GWports=length(B1s);
%Calculate BF(t) and Tail Probabilities
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);
vRlzs=100;
randVecs=rand(vRlzs,nodes)-0.5;
for vInd=1:size(randVecs,1)
    randVecs(vInd,:)=randVecs(vInd,:)/(norm(randVecs(vInd,:),2));
end
for t=3:35
    %Calculating BF(t)'s
    if(t==3)
        Fprod=F3;
        BFconc=[B1s;B1s*Fprod];
    else
        Fprod=F*Fprod;
        BFconc=[BFconc;B1s*Fprod];
    end
    m=size(BFconc,1);
    mVec(t)=m;
    
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
        disp(['eig Value - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
    end
    %Normalization for Compensation E()=1
    for vInd=1:size(randVecs,1)
        lambdasCompensated{vInd}=lambdas{vInd}/sum(lambdas{vInd});
        
        omegaVal=exp(-j*omegaVec).*sin(eps*omegaVec)./omegaVec;
        for l=1:length(lambdasCompensated{vInd})
            omegaVal=omegaVal./sqrt(1-2*j*omegaVec*lambdasCompensated{vInd}(l));
        end
        tailProbV(t,vInd)=real(1-1/pi*omegaDel*sum(omegaVal));
        disp(['Tail Prob - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
    end
    [max1,max2]=max(tailProbV(t,:));
    tailProbWorst(t)=max1;
    tailProbWorstVec(t)=max2;
    %Gaussian Case
    OmegaValgaussian=exp(-j*omegaVec).*sin(eps*omegaVec)./omegaVec./(sqrt(1-2*j*omegaVec*(1/m)).^m);
    tailProbGaussian(t)=real(1-1/pi*omegaDel*sum(OmegaValgaussian));
    disp(['t= ' num2str(t) ' is done.']);
end

save resMain5run4 mVec randVecs tailProbWorst tailProbWorstVec tailProbGaussian tailProbV edges nodes eps;

figure(1),hold on; grid on; xlabel('log_{10}(m)'); ylabel('Log_{10} of Tail Probability');
plot(log10(mVec(3:end)),log10(tailProbGaussian(3:end)),'r-^');
plot(log10(mVec(3:end)),log10(tailProbWorst(3:end)),'b-o');
legend('Gaussian','QNC-OrthogonalCompensated');box on;



