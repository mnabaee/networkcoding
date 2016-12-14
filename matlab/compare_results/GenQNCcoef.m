function [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
for t=1:iterations+1
    A{t}=zeros(edges,nodes);
    F{t}=zeros(edges,edges);
end
for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
    
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        A{2}(eOut,node)=sign(randn)*(1);
    end
    for t=3:iterations+1
    basisVecs=RandOrthMat(length(inEdges))';
    %Check the Condition
    if(length(inEdges)>=length(outEdges))
        %We are Good!
    else
        %Remove extra OutEdges
        outEdges(length(inEdges)+1:end)=[];
    end
    for eOutIndx=1:length(outEdges)
        eOut=outEdges(eOutIndx);
        for eInIndx=1:length(inEdges)
            eIn=inEdges(eInIndx);
            F{t}(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
        end
        F{t}(eOut,:)=F{t}(eOut,:)/norm(F{t}(eOut,:),1);
    end
    end
end





