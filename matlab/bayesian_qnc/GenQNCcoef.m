%Capsule function to run a random realization of Routing
function [A,F]=GenQNCcoef(nodes,edges,iterations,htList);

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
            basisVecs=RandOrthMat(length(inEdges))';
        for t=3:iterations+1
            
            %Check the Condition
            if(length(inEdges)>=length(outEdges))
                %We are Good!
            else
                %Remove extra OutEdges
                outEdges(length(inEdges)+1:end)=[];
            end
            for eOutIndx=1:length(outEdges)
                eOut=outEdges(eOutIndx);
                for eInIndx=1:length(inEdges)
                    eIn=inEdges(eInIndx);
                    F{t}(eOut,eIn)=basisVecs(eOutIndx,eInIndx);
                end
            end
        end
        %Normalization of F{t}'s to avoid overflow
        for eOutIndx=1:length(outEdges)
            eOut=outEdges(eOutIndx);
            sumOverIns=0;
            for eInIndx=1:length(inEdges)
                eIn=inEdges(eInIndx);
                sumOverIns=sumOverIns+abs(F{t}(eOut,eIn));
            end
            sumOverIns;
            if(sumOverIns>0)
            for eInIndx=1:length(inEdges)
                eIn=inEdges(eInIndx);
                F{t}(eOut,eIn)=F{t}(eOut,eIn)/sumOverIns;
            end
            end
        end
end

%Normalization of A(2)'s
%maxVal=max(max(A{2}));
%A{2}=A{2}/maxVal;



