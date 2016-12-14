%Capsule function to run a random realization of Routing
function [recErrNormL1min,recErrNormBP]=OneStepQNCCapsule2(iterations,nodes,edges,Delta,htList,x,GWnode,phi,sigmaBig,numWdIters,sparsityFactor,sigmaQ);

%Shortest Path Routing
sG=sparse(htList(:,2),htList(:,1),ones(length(htList),1));
for node=1:nodes
    [dist(node), path{node}]=graphshortestpath(sG,node,GWnode);
end

%Linear Combinations at each Node
for node=1:nodes
    lineTFunc{node}=zeros(1,nodes);
    eIns=find(htList(:,1)==node);
    numElements=length(eIns)+1;
    P(node)=0;
    for eInIndx=1:length(eIns)
        eIn=eIns(eInIndx);
        vIn=htList(eIn,2);
        lineTFunc{node}(1,vIn)=sign(randn)/numElements;
        P(node)=P(node)+lineTFunc{node}(1,vIn)*x(vIn);
    end
    lineTFunc{node}(1,node)=sign(randn)/numElements;
    P(node)=P(node)+lineTFunc{node}(1,node)*x(node);
end

%Forward Pv's to the decoder node
Prec=zeros();
for node=1:nodes
    pos(node)=node;
    delivered(node)=0;
end
delivered(GWnode)=1;
Prec(GWnode)=round(P(GWnode)/Delta)*Delta;
t=2;
numMeas(t)=1;
i=1;
PsiTot{2}=lineTFunc{GWnode};
zTot{2}=Prec(GWnode);
noiseL2normSquaredBound{2}=[0];
nodeI(1)=GWnode;
while(1)
    t=t+1;
    PsiTot{t}=PsiTot{t-1};
    zTot{t}=zTot{t-1};
    noiseL2normSquaredBound{t}=noiseL2normSquaredBound{t-1};
    occupiedEdges=zeros(edges,1);
    for node=1:nodes
            %Forward them
            if(isempty(path{node})==0)
                i=find(pos(node)==path{node});
                if(i==length(path{node}))
                    %Already Delivered!
                else
                    nextNode=path{node}(i+1);
                    nextEdge=find((htList(:,1)==nextNode)&(htList(:,2)==pos(node)));
                    if(occupiedEdges(nextEdge)==0)
                        %Pass it
                        occupiedEdges(nextEdge)=1;
                        pos(node)=nextNode;
                    else
                        %Queue it!
                    end
                end
            end
    end
    for node=1:nodes
        if(pos(node)==GWnode)
            %Delivered
            i=i+1;
            delivered(node)=1;
            nodeI(i)=node;
            Prec(node)=round(P(node)/Delta)*Delta;
            PsiTot{t}=[PsiTot{t};lineTFunc{node}];
            zTot{t}=[zTot{t};Prec(node)];
            noiseL2normSquaredBound{t}=[noiseL2normSquaredBound{t};Delta/2*sum(lineTFunc{node}~=0)];
        end
    end
    numMeas(t)=sum(delivered);
    zTotInd=zTot{t};
    PsiTotInd=PsiTot{t};
    %Run L1MIN Decoding
        totL2NormUpperBound=sum(noiseL2normSquaredBound{t});    
            cvx_begin quiet
            variable sss(size(phi,1));
            minimize(norm(sss,1));
            subject to
                norm(zTotInd-PsiTotInd*phi*sss,2)<totL2NormUpperBound;
            cvx_end
         xRecL1min{t}=phi*sss;
         recErrNormL1min(t)=norm(x-xRecL1min{t},2);
    %Run BP Decoding
        xmean0=0;
        xvar0=sigmaBig;
        inputEst0 = AwgnEstimIn(xmean0, xvar0);
        inputEst = SparseScaEstim( inputEst0, sparsityFactor );
        
%         %Normalize to have the same wvar's
%         sigma2MeasNoise;
%         for i=1:size(PsiTotInd,1)
%             PsiTotInd(i,:)=PsiTotInd(i,:)/sqrt(sigma2MeasNoise(i));
%             zTotInd(i)=zTotInd(i)/sqrt(sigma2MeasNoise(i));
%         end
        
        wvar=sigmaQ;
        
        outputEst = AwgnEstimOut(zTotInd, wvar);

        opt = GampOpt();
        opt.nit=numWdIters;
        [shat] = gampEst(inputEst, outputEst, PsiTotInd*phi, opt);
        xRecBP{t}=phi*shat;
        recErrNormBP(t)=norm(x-xRecBP{t},2);
    
    if(sum(delivered)==nodes)
       %break;   %All Delivered.
    end
    if(t==iterations+1)
       break; 
    end
end


