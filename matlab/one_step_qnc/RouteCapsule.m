%Capsule function to run a random realization of Routing
function [recErrNorm]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);


%Shortest Path Routing
sG=sparse(htList(:,2),htList(:,1),ones(length(htList),1));
for node=1:nodes
    [dist(node), path{node}]=graphshortestpath(sG,node,GWnode);
end

%PacketForwarding 
xRec=zeros(nodes,1);
for node=1:nodes
    pos(node)=node;
    delivered(node)=0;
end
delivered(GWnode)=1;
xRec(GWnode)=round(x(GWnode)/Delta)*Delta;
t=1;
numMeas(t)=1;
recErrNorm(t)=norm(x-xRec,2);
while(1)
    t=t+1;
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
            delivered(node)=1;
            xRec(node)=round(x(node)/Delta)*Delta;
        end
    end
    numMeas(t)=sum(delivered);
    recErrNorm(t)=norm(x-xRec,2);
    if(sum(delivered)==nodes)
       %break;   %All Delivered.
    end
    if(t==iterations+1)
       break; 
    end
end


