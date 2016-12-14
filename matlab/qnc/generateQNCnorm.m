%Generate Quantized Network Coding: Norm Analysis

function [htList,GWnode,A,F,B,phi]=generateQNCnorm(nodes, edges, iterations);

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

GWnode=floor(rand*nodes)+1;

%Generate Network Coding Coefficients based on the Developed Method

%Calculate B matrix
inEdges=find(htList(:,1)==GWnode);
cnt=1;
for e=1:length(inEdges)
	B(cnt,edges)=0;
	B(cnt,inEdges(e))=1;
	cnt=cnt+1;
end

%Random Sparsity Matrix (phi)
phi=randorthmat(nodes);

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
                for eInIndx=1:length(inEdges)
                    prevNode=htList(inEdges(eInIndx),2);
                    A{2}(inEdges(eInIndx),prevNode)=1;
                end
                %A{2}(outEdges,node)=1/sqrt(length(outEdges));
        %Generate F Matrices
            %For t=3
                for eIn=inEdges
                    for eOut=outEdges
                        F{3}(eOut,eIn)=1/(length(inEdges));%/sigmaApp;%randn/sigmaApp;
                    end
                end
            %For other t's
                basisVecs=randorthmat(length(inEdges))';
            for t=4:iterations+1

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
                        F{t}(eOut,eIn)=basisVecs(eInIndx,eOutIndx);
                    end
                end
            end
    end



