function [A,F]=GencoefOneStep(nodes,edges,iterations,htList,densityRow);

for t=1:iterations+1
    A{t}=zeros(edges,nodes);
    F{t}=zeros(edges,edges);
end
for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
    
    for outEdgeIdx=1:length(outEdges)
        outEdge=outEdges(outEdgeIdx);
        %A(2)'s are +1 
        A{2}(outEdge,node)=1;
        
        for inEdgeIdx=1:length(inEdges)
            inEdge=inEdges(inEdgeIdx);
            %F(3)'s are +1 or -1 if not zero (depending on densityRow)
            %usual density-based
            F{3}(outEdge,inEdge)=(rand<densityRow)*sign(randn);
        end
        
        for t=4:iterations+1
            randInEdge=randperm(length(inEdges));
            randInEdge=inEdges(randInEdge(1));
            F{t}(outEdge,randInEdge)=sign(randn);
        end
        
        %Normalization  %%CHANGE IT
%         for t=3:iterations+1
%             sumAbs=sum(abs(F{t}(outEdge,:)));
%             F{t}(outEdge,:)=F{t}(outEdge,:)/sumAbs;
%         end
    end

end


%Do we need normalization to avoid overflow (clipping noise)?
%%%This has to be taken care of...
%%%If they are supposed to have the same density, this should not matter.



