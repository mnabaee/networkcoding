%Tail Probability Evaluation

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

%Generate Q set of vectors
vecs=[];



while(1)
    newVec=rand(nodes,1);
    for i=1:length(vecs)
        dist(i)=norm(vecs,2);
    end
    if(min(dist)>eps)
        vecs{length(vecs)+1}=newVec;
    end
    
end

%Calculate Sigmas of PsiTot
Asigma2=double(A~=0);
Fmult=eye(edges,edges);
PsiTotSigma2=[];
vRlzs=1000;
randVecs=rand(vRlzs,nodes)-0.5;
for t=3:iterations+1
    Fmult=F*Fmult;
    PsiSigma2{t}=B1s*(Fmult.^2)*Asigma2;
    PsiTotSigma2=[PsiTotSigma2;PsiSigma2{t}];
        for vInd=1:size(randVecs,1)
            ySigma2(vInd,1:size(PsiTotSigma2,1))=(PsiTotSigma2*(randVecs(vInd,:)'.^2))';
        end
end






