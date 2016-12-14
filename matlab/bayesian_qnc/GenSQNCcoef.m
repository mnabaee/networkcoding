function [A,F]=GenSQNCcoef(nodes,edges,iterations,htList,densityRow);

for t=1:iterations+1
    A{t}=zeros(edges,nodes);
    F{t}=zeros(edges,edges);
end
for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
    
    for outEdgeIdx=1:length(outEdges)
        outEdge=outEdges(outEdgeIdx);
        %A(2)'s are either +1 or -1 one with the same probability
        A{2}(outEdge,node)=sign(randn);
        
        randInEdge=randperm(length(inEdges));
        randInEdge=inEdges(randInEdge(1));
        
        for inEdgeIdx=1:length(inEdges)
            inEdge=inEdges(inEdgeIdx);
            %F(t)'s are +1 or -1 if not zero (depending on densityRow(t))
            for t=3:iterations+1
                if(densityRow(t)==-1)          %-1: all zeros
                    F{t}(outEdge,inEdge)=0;
                elseif(densityRow(t)==0)       %0: just one nonzero
                    if(inEdge==randInEdge)
                        F{t}(outEdge,inEdge)=sign(randn);
                    end
                else                           %usual density-based
                    F{t}(outEdge,inEdge)=(rand<densityRow(t))*sign(randn);
                end
            end
        end
        %Normalization
        for t=3:iterations+1
            sumAbs=sum(abs(F{t}(outEdge,:)));
            F{t}(outEdge,:)=F{t}(outEdge,:)/sumAbs;
        end
    end

end


%Do we need normalization to avoid overflow (clipping noise)?
%%%This has to be taken care of...
%%%If they are supposed to have the same density, this should not matter.



