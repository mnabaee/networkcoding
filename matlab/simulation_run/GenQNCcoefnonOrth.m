%Capsule function to run a random realization of Routing
function [A,F]=GenQNCcoefnonOrth(nodes,edges,iterations,htList,xRange);

%Generate A and F matrices over time
sigmaApp=sqrt(nodes);
for t=1:iterations+1
    A{t}=zeros(edges,nodes);
    F{t}=zeros(edges,edges);
end
for node=1:nodes
    inEdges=find(htList(:,1)==node);
    outEdges=find(htList(:,2)==node);
    %Generate A Matrices
        A{2}(outEdges,node)=randn;
    %Generate F Matrices
        %For other t's
        for t=3:iterations+1
            for eOutIndx=1:length(outEdges)
                eOut=outEdges(eOutIndx);
                for eInIndx=1:length(inEdges)
                    eIn=inEdges(eInIndx);
                    F{t}(eOut,eIn)=1/length(inEdges);
                end
            end
        end
end

%Normalization of A(2)'s
maxA2=max(max(A{2}));
A{2}=A{2}/maxA2;
