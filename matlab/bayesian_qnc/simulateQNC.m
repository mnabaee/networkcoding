%Simulate Quantized Network Coding
function [zTot,numMeas,nEffTot,z]=simulateQNC(iterations,DeltaQ,x,A,F,B,PsiTot);
edges=size(F{2},1);
%Perform Quantized NC
y{1}=zeros(edges,1); y2{1}=y{1};
for t=1:iterations
    y2{t+1}=A{t+1}*x+F{t+1}*y{t};
    y{t+1}=round(y2{t+1}/DeltaQ)*DeltaQ;      %Uniform Quantization
    %y{t+1}=y2{t+1};
    n{t+1}=y{t+1}-y2{t+1};
    %Edges of GW Node
    z{t+1}=B*y{t+1};
    if(t==1)
        zTot{2}=z{2};
    else
        zTot{t+1}=[zTot{t};z{t+1}];
    end
    
    nEffTot{t+1}=zTot{t+1}-PsiTot{t+1}*x;
    numMeas(t)=size(zTot{t},1);
end
