%Capsule function to generate network deployment based on Radio Propagation
%Decay Model
function [htList,GWnode,B,xLoc,yLoc]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);

%Generate a distancewise network model

xLoc=rand(nodes,1);
yLoc=rand(nodes,1);
cnt=1;
for node1=1:nodes
    for node2=1:nodes
        if(node1~=node2)
            dist=sqrt((xLoc(node1)-xLoc(node2))^2+(yLoc(node1)-yLoc(node2))^2);
            if(dist<=radioDecay)
                if(rand<=connPerc)
                    htList(cnt,1)=node1;
                    htList(cnt,2)=node2;
                    cnt=cnt+1;
                end
            end
        end
    end
end
edges=cnt-1;


%Calculate B matrix
while(1)
GWnode=randperm(nodes);
GWnode=GWnode(1);
inEdges=find(htList(:,1)==GWnode);
cnt=1;
for e=1:length(inEdges)
	B(cnt,edges)=0;
	B(cnt,inEdges(e))=1;
	cnt=cnt+1;
end
if(cnt>1)
   break; 
end
end
