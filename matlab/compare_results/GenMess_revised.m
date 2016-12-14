%Generate Messages
function [x,phi,xNorm]=GenMess_revised(nodes,sp,q,epsK);
SsupportInd=randperm(nodes);
SsupportInd=SsupportInd(1:round(sp*nodes));
Ssupport=zeros(nodes,1);
Ssupport(SsupportInd)=1;

Sk=2*(rand(nodes,1)-.5).*Ssupport;
randVec=randn(nodes,1);
randVec=randVec/norm(randVec,1)*epsK*norm(Sk,1);
S=Sk+randVec;

phi=orth(rand(nodes,nodes));
x=phi*S;

x=((x-min(x))*2/(max(x)-min(x))-1)*q;

xNorm=norm(x,2);
