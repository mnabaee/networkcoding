%Test RIP for Sensor Netowrk Coding Matrices
close all;
clear all;
clc;

load netCodMats;
XrlzNum=100;
Aconcat=[];
for t=1:length(matProj)
    Amat=matProj{t};
    Aconcat=[Aconcat;Amat];
    for xrlz=1:XrlzNum
        x=randn(size(Amat,2),1)*20;
        norm2left(t,xrlz)=norm(Aconcat*x,2)^2/norm(x,2)^2;
    end
    Enorm2left(t)=mean(norm2left(t,:));
end

figure,stem(Enorm2left);

% 
% figure,hist(Enorm2left,20);
% EEnorm2left=mean(Enorm2left)