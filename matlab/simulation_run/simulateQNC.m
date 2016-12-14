%Simulate Quantized Network Coding

function [zTot]=simulateQNC(iterations,Delta,x,A,F,B);
edges=size(F{2},1);
%Perform Quantized NC
y{1}=zeros(edges,1); y2{1}=y{1};
for t=1:iterations
    y2{t+1}=A{t+1}*x+F{t+1}*y{t};
    y{t+1}=round(y2{t+1}/Delta)*Delta;
    n{t+1}=y{t+1}-y2{t+1};
    %y{t+1}=y2{t+1};
    %Edges of GW Node
    z{t+1}=B*y{t+1};
end
n{1}=n{2}*0;
y{1}=y{2}*0;
zT=z{1};
for t=2:iterations+1
    zT=[zT;z{t}];
    zTot{t}=zT;
end

