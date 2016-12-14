%Generate Messages
function [x,phi,xNorm]=GenMess(nodes,sp,q);
Ssupport=rand(nodes,1)<sp;
S=randn(nodes,1).*Ssupport;
phi=orth(rand(nodes,nodes));
x=phi*S;
x=(x-min(x))*(2*q)/(max(x)-min(x))-q;
xNorm=norm(x,2);
