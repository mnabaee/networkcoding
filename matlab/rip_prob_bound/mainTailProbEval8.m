%Tail Probability Evaluation
%with compensation
%uniform number of outgoing edges at all nodes
%Does smoothing in direction of network deployments
%with MATLAB pool

%matlabpool close;
close all;
clear all;
clc;
format long;

edges=1100;
saveFileName='resMain8run1';
saveFileName=[saveFileName '_' num2str(edges) 'edges'];

nodes=100;

deltaVec=linspace(0.2,sqrt(2)-1,5);
depRlzs=20;

vRlzs=100;
randVecs=rand(vRlzs,nodes)-0.5;
for vInd=1:size(randVecs,1)
    randVecs(vInd,:)=randVecs(vInd,:)/(norm(randVecs(vInd,:),2));
end
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);

c2=[];
lambdas=[];
lambdasCompensated=[];
tailProbV=[];

matlabpool 3;


parfor deplInd=1:depRlzs

    %Generate Network Deployment
    [htList,GWnode,B1s]=GenNetCapsule(nodes,edges); 
    
    
    F{deplInd}=[];
    F3{deplInd}=[];
    A{deplInd}=[];
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
                %while(1)
                A{deplInd}(eOut,node)=randn;
                %if(abs(A{deplInd}(eOut,node))<=1)
                %   break; 
                %end
                %end
            end
        end
        %F3,Fothers: the same in here
        for eOutIndx=1:length(outEdges)
            eOut=outEdges(eOutIndx);
            for eInIndx=1:length(inEdges)
                eIn=inEdges(eInIndx);
                F{deplInd}(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
                F3{deplInd}(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
            end
        end
    end

    GWports=length(B1s);
    %Calculate BF(t) and Tail Probabilities
    BFconc{deplInd}=[];
    Fprod{deplInd}=[];
    for t=3:30
        %Calculating BF(t)'s
        if(t==3)
            Fprod{deplInd}=F3{deplInd};
            BFconc{deplInd}=[B1s;B1s*Fprod{deplInd}];
        else
            Fprod{deplInd}=F{deplInd}*Fprod{deplInd};
            BFconc{deplInd}=[BFconc{deplInd};B1s*Fprod{deplInd}];
        end
        m=size(BFconc{deplInd},1);
        mVec{deplInd}(t)=m;

        for vInd=1:size(randVecs,1)
            %Calculating c(e1,e2,v1,v2)
            %Calculating c2(l1,l2)
            [eNonZero,vNonZero]=find(A{deplInd}~=0);
            for l1=1:length(eNonZero)
                e1=eNonZero(l1);
                v1=vNonZero(l1);
                for l2=1:length(eNonZero)
                    e2=eNonZero(l2);
                    v2=vNonZero(l2);
                    c2{deplInd}(l1,l2)=sum(BFconc{deplInd}(:,e1).*BFconc{deplInd}(:,e2))*randVecs(vInd,v1)*randVecs(vInd,v2);
                end
            end

            lambdas{deplInd}(:,vInd)=real(eig(c2{deplInd}));
            disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- eig Value - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
        end
        %Normalization for Compensation E()=1
        for vInd=1:size(randVecs,1)
            lambdasCompensated{deplInd}(:,vInd)=lambdas{deplInd}(:,vInd)/sum(lambdas{deplInd}(:,vInd));

            omegaVal=exp(-j*omegaVec)./omegaVec;
            for l=1:size(lambdasCompensated{deplInd},1)
                omegaVal=omegaVal./sqrt(1-2*j*omegaVec*lambdasCompensated{deplInd}(l,vInd));
            end
            for deltaInd=1:length(deltaVec)
                eps=deltaVec(deltaInd)/sqrt(2);
                tailProbV{deplInd}(t,deltaInd,vInd)=real(1-1/pi*omegaDel*sum(omegaVal.*sin(eps*omegaVec)));
            end
            disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- Tail Prob - calc- t=' num2str(t) ', vInd=' num2str(vInd)]);
        end

        disp(['deployment ' num2str(deplInd) '/' num2str(depRlzs) '- t= ' num2str(t) ' is done.']);
        save(saveFileName,'mVec','randVecs','tailProbV','edges','nodes','deltaVec');
        
    end
    
end

matlabpool close;



