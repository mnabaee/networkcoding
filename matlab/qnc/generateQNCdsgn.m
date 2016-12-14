%Generate Quantized Network Coding

function [htList,GWnode,x,phi,A,F,B]=generateQNCdsgn(nodes, edges, iterations,Delta,q,sp);

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

% for i=1:edges/2
%     while(1)
%         htList(i,:)=[floor(rand*nodes)+1 floor(rand*nodes)+1];  %Head Tail
%         if(htList(i,1)~=htList(i,2))
%             if(i~=1)
%                 if(isempty(find(htList(i,:)==htList(1:i-1,:)))==1)
%                     break; 
%                 end
%             else
%                 break;
%             end
%         end
%     end
%     htList(i+edges/2,1)=htList(i,2);
%     htList(i+edges/2,2)=htList(i,1);
% end

%Generate Messages
Ssupport=rand(nodes,1)<sp;
S=randn(nodes,1).*Ssupport;
phi=orth(rand(nodes,nodes));
x=phi*S;
x=(x-min(x))*(2*q)/(max(x)-min(x))-q;
%x=round(x/Delta)*Delta;

%Generate Network Coding Coefficients based on the Developed Method

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
        A{2}(outEdges,node)=1;%/sqrt(length(outEdges));
    %Generate F Matrices
        %For t=3
            for eIn=inEdges
                for eOut=outEdges
                    F{3}(eIn,eOut)=randn/sigmaApp;
                end
            end
        %For other t's
            basisVecs=RandOrthMat(length(inEdges))';
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
        %Normalization to avoid overflow
        for eOut=outEdges
            sumOverIns=abs(x(node));
            for eIn=inEdges
                sumOverIns=sumOverIns+abs(F{t}(eIn,eOut));
            end
            if(sumOverIns>0)
            for eIn=inEdges
                F{t}(eIn,eOut)=F{t}(eIn,eOut)/sumOverIns;
            end
            end
        end
end



