function [GWnode,B]=pickDecoder(xLoc,yLoc,htList,innerR,outerR);

%Pick a Decoder Node which is between the two radiuses from the center
edges=size(htList,1);
LList=[];
for node=1:length(xLoc)
	radius(node)=sqrt((xLoc(node)-.5)^2+(yLoc(node)-.5)^2);
	if((radius(node)>=innerR)&&(radius(node)<=outerR))
		LList=[LList node];
	end
end
if(isempty(LList))
	%If Emprty Region?
	
else
	while(1)
		GWnode=randperm(length(LList));
		GWnode=LList(GWnode(1));
		inEdges=find(htList(:,1)==GWnode);
		cnt=1;
		B=[];
		for e=1:length(inEdges)
			B(cnt,edges)=0;
			B(cnt,inEdges(e))=1;
			cnt=cnt+1;
		end
		if(cnt>1)
		   break; 
		end
	end
end


