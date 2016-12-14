%Test Concentration Inequalities...

close all;
clear all;
clc;


K=20;
N=1000;
% Build up measurement matrix
ArlzNum=100;
for rlz=1:ArlzNum
    II=10;
    A = 1/K^.5*randn(K,N);
    for i=1:II
       A=A*randn(N,N)/N^.5;
    end
    Pmat{rlz}=A;
end
	

%Test Condition 1

%Pick x vector
XrlzNum=100;
for xrlz=1:XrlzNum
    x=rand(N,1);
    %x=x/norm(x,2);
    for rlz=1:ArlzNum
        norm2left(rlz)=norm(Pmat{rlz}*x,2)^2/norm(x,2)^2;
    end
    Enorm2left(xrlz)=mean(norm2left);
end
figure,hist(Enorm2left,20);
EEnorm2left=mean(Enorm2left)

matProj=Pmat;
save netCodMats matProj;