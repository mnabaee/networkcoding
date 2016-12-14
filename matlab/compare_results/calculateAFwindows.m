function [Awindow,Fwindow]=calculateAFwindows(nodes,edges,htList);

Fwindow=zeros(edges,edges);
Awindow=zeros(edges,nodes);

for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
        for eOutIndx=1:length(outEdges)
            for eInIndx=1:length(inEdges)
                Fwindow(outEdges(eOutIndx),inEdges(eInIndx))=1;
            end
            Awindow(outEdges(eOutIndx),node)=1;
        end
end
% Awindow=gf(Awindow,digits);
% Fwindow=gf(Fwindow,digits);