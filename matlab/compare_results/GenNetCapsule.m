%Capsule function to generate network deployment
function [htList,GWnode,B]=GenNetCapsule(nodes,edges);

%Generate the Network Model
%We make all links symmetric
%and avoide repeated pairs of tail-head.
cnt=1;
for i=1:nodes
    for j=i+1:nodes
        allHTlist(cnt,1)=i;
        allHTlist(cnt,2)=j;
        cnt=cnt+1;
    end
end

for i=1:edges/2
    rndindx=floor(rand*size(allHTlist,1))+1;
    htList(i,:)=allHTlist(rndindx,:);
    allHTlist(rndindx,:)=[];
    htList(i+edges/2,1)=htList(i,2);
    htList(i+edges/2,2)=htList(i,1);
end

%Calculate B matrix
while(1)
GWnode=floor(rand*nodes)+1;
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
