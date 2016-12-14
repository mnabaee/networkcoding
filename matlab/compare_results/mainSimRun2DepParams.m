%Main Module for Simulation Run (mainSimRun2DepParams.m)
%This one uses a specific model for choosing decoder

close all;
clear all;
format long;
clc;

nodes=100;
RlzS=50;

radioDecay=.15;
connPerc=.9;

innerR=sqrt(2)/2*.0;
outerR=sqrt(2)/2*.25;
   
rlzInd=1;
cnt=0;
sum=0;
for rlzInd=1:RlzS 
    [htList,GWnode,B,xLoc,yLoc]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);
	[GWnode,B]=pickDecoder(xLoc,yLoc,htList,innerR,outerR);
    edges(rlzInd)=size(htList,1);
    
    %Shortest Path Routing
    sG=sparse(htList(:,2),htList(:,1),ones(length(htList),1));
    for node=1:nodes
        [dist(node), path{node}]=graphshortestpath(sG,node,GWnode);
    end
    
    avgDist(rlzInd)=mean(dist);
    
    if(avgDist(rlzInd)~=Inf)
       sum=sum+avgDist(rlzInd);
       cnt=cnt+1;
    end
    disp(rlzInd);
end

avgavgDist=mean(avgDist)
avgavgDist=sum/(cnt-1)
avgEdges=round(mean(edges))



% FontSize=13;
% scrsz = get(0,'ScreenSize');
% figure('Position',[50 50 600 500]); 
% xlabel('X axis','fontsize',FontSize);
% ylabel('Y axis','fontsize',FontSize);
% hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
% 
% for edge=1:size(htList)
%     x1=xLoc(htList(edge,2));
%     x2=xLoc(htList(edge,1));
%     y1=yLoc(htList(edge,2));
%     y2=yLoc(htList(edge,1));
%     h1=arrow([x1 y1],[x2 y2],'TipAngle',10,'Length',15);
%     %annotation('arrow',[x1 x2],[y1 y2]);
%     %annotation('arrow',[.39 .39],[.11 .39])
% end
% h2=plot(xLoc,yLoc,'bo','linewidth',1.5);
% h3=plot(xLoc(GWnode),yLoc(GWnode),'rs','linewidth',2);
% legend([h1 h2 h3],'Edges','Nodes','Gateway Node');
% 
% 
% figure('Position',[50 50 600 500]); 
% xlabel('X axis','fontsize',FontSize);
% ylabel('Y axis','fontsize',FontSize);
% hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
% h2=plot(xLoc,yLoc,'bo','linewidth',1.5);


