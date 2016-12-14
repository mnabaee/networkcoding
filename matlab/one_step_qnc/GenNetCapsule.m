%Capsule function to generate network deployment with (approximately) UNIFORM edge distribition

% clear all;
% clc;
% 
% nodes=10;
% perNodeEdges=3;

function [htList,GWnode,B]=GenNetCapsule(nodes,perNodeEdges);
NumOutEdges=zeros(nodes,1);
cnt=0;
cntB=0;
GWnode=randperm(nodes);
GWnode=GWnode(1);
for node=1:nodes
    NumInNodes=0;
    otherNodesVecThisEdge=[1:node-1 node+1:nodes];
    while(NumInNodes<perNodeEdges)
        %Pick a random other node
            othernode=randperm(length(otherNodesVecThisEdge));
            othernode=otherNodesVecThisEdge(othernode(1));
            if(NumOutEdges(othernode)<perNodeEdges)
                NumInNodes=NumInNodes+1;
                NumOutEdges(othernode)=NumOutEdges(othernode)+1;
                cnt=cnt+1;
                htList(cnt,1)=node;
                htList(cnt,2)=othernode;
                if(node==GWnode)
                    cntB=cntB+1;
                    B(cntB,cnt)=1;
                end
            else
                otherNodesVecThisEdge(find(otherNodesVecThisEdge==othernode))=[];
                if(isempty(otherNodesVecThisEdge))
                   break; 
                end
            end
    end
end
if(size(B,2)<size(htList,1))
    B(size(B,1),size(htList,1))=0;
end




