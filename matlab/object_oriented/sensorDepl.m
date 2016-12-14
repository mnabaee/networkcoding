classdef sensorDepl
    properties
        nodes
        edges
        xLocs
        yLocs
        edgeListHead
        edgeListTail
        GWnode
    end
    methods
        %Function: Creates a Random Network where power decay is used for
        %connectivity
        function D=createDeplGeo(D,nodes,sizeX,sizeY,radius,connPerc)
            D.nodes=nodes;
            for i=1:nodes
                D.xLocs(i)=rand*sizeX;
                D.yLocs(i)=rand*sizeY;
            end
            cnt=1;
            for i=1:nodes
            for j=1:nodes
                if((D.xLocs(i)-D.xLocs(j))^2+(D.yLocs(i)-D.yLocs(j))^2<=radius^2)
                    if(rand<connPerc)
                    D.edgeListHead(cnt)=i;
                    D.edgeListTail(cnt)=j;
                    cnt=cnt+1;
                    end
                end
            end
            end
            D.edges=cnt-1;
            D.GWnode=randperm(nodes);
            D.GWnode=D.GWnode(1);
        end
        
        %Function: Draws the Geographical Map of Sensors and Links
        function drawDepl(D,figH)
            figure(figH),plot(D.xLocs,D.yLocs,'ro'); hold on;
            grid on; xlabel('X'); ylabel('Y');
            for cnt=1:D.edges
                line([D.xLocs(D.edgeListHead(cnt)) D.xLocs(D.edgeListTail(cnt))],[D.yLocs(D.edgeListHead(cnt)) D.yLocs(D.edgeListTail(cnt))]);
            end
            plot(D.xLocs(D.GWnode),D.yLocs(D.GWnode),'bs');
        end
    end
    
end