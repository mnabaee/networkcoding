% Sparsity and KLT

close all;
clear all;
clc;

N=10;
T=randn(N,N);
winD=(rand(N,1)<0.2);
for i=1:100
    w(:,i)=randn(N,1).*winD;
    x(:,i)=T*w(:,i);
end
wMean=mean(w');
for i=1:100
    Rx(i,:,:)=x*x';
end
for i=1:N
    for j=1:N
        RxMean(i,j)=mean(Rx(:,i,j));
    end
end
[e1,e2]=eig(RxMean);
round(diag(e2))