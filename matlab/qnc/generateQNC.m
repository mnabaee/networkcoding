%Generate Quantized Network Coding

function [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,sp);

%Generate the Network Model
for i=1:edges
    while(1)
        htList(i,:)=[floor(rand*nodes)+1 floor(rand*nodes)+1];  %Head Tail
        if(htList(i,1)~=htList(i,2))
           break; 
        end
    end
end
GWnode=floor(rand*nodes)+1;

%Generate Messages
Ssupport=rand(nodes,1)<sp;
S=randn(nodes,1).*Ssupport;
phi=orth(rand(nodes,nodes));
x=phi*S;
x=(x-min(x))*(2*q)/(max(x)-min(x))-q;
%x=round(x/Delta)*Delta;


A0=zeros(edges,nodes);
F0=zeros(edges,edges);
B=zeros(0,edges);
cnt=1;
for e=1:edges
    node=htList(e,2);
    inEdges=find(htList(:,1)==node);
    inSize=length(inEdges);
    A0(e,node)=1/(inSize+1);
    if(isempty(inEdges)==0)
        for i=1:length(inEdges)
           e2=inEdges(i);
           F0(e,e2)=1/(inSize+1);
        end
    end
    if(htList(e,2)==GWnode)
        B(cnt,edges)=0;
        B(cnt,e)=1; 
        cnt=cnt+1;
    end
end

%Generate NC Matrices
for t=1:iterations+1
    if(t==2)
        A{t}=(A0>0)*2*((rand>0.5)-.5);
        F{t}=F0*0;
    else
        A{t}=A0*2*((rand>0.5)-.5);
        F{t}=F0*2*((rand>0.5)-.5);
    end
end









