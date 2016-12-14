%Generate Messages
function [x,phi,xNorm]=GenMess(nodes,sp,q,epsK);
Ssupport=rand(nodes,1)<sp;
Sk=randn(nodes,1).*Ssupport;
randVec=(rand(nodes,1)-.5)*2;
randVec=randVec/norm(randVec,1);
S=Sk+randVec*epsK*norm(Sk,1);
phi=orth(rand(nodes,nodes));
x=phi*S;
x=(x-min(x))*(2*q)/(max(x)-min(x))-q;
xNorm=norm(x,2);
