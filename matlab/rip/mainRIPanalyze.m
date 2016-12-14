%Analyzing the Projection Matrices

close all;
clear all;
clc;

load netCodMats;
XrlzNum=1000;
c=.1;

    for xrlz=1:XrlzNum
        x{xrlz}=(rand(size(matProj{1},2),1)-.5)*40;
    end

  
for t=1:length(matProj)
    A=5*matProj{t}*10^9;
    if(t==1)
        B=A;
    else
        B=[B*((1-c^2)^.5);A*c];
    end
    for xrlz=1:XrlzNum
        xx=x{xrlz};
        Ax=A*xx;
        Bx=B*xx;
        norm2left(xrlz)=(norm(Ax,2)/norm(xx,2))^2;
        norm2left2(xrlz)=(norm(Bx,2)/norm(xx,2))^2;
    end
    Enorm2left(t)=mean(norm2left);
    Enorm2left2(t)=mean(norm2left2);
end

    
    %figure,hist(norm2left,100);
    figure,stem(Enorm2left); hold on;
    stem(Enorm2left2,'r');

