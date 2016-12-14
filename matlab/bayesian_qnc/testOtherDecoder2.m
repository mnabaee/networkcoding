%Test BP Decoder of GMA

close all
clear all
clc
warning off

addpath('../trunk/code/main');
addpath(genpath('../cvx'));

load mats;

k=round(.1*length(x));

rrrVec=[5:2:40];
%rrrVec=70;

for r=1:length(rrrVec)
    rrr=rrrVec(r);
for run=1:100
xS=randperm(length(x));
xS=xS(1:k);
x=zeros(length(x),1);
x(xS)=1;
x=x.*randn(length(x),1);
%stem(x);
A=PsiTot{20}(end-rrr:end,:);
%A=PsiTot{20}(1:end,:);
m=size(A,1);
%A=randn(size(A)).*(rand(size(A))<1.1);

%A=A.*(rand(m,n)<0.2);

A2=zeros(0,size(A,2));
for i=1:size(A,1)
    norm(A(i,:),2);
    A(i,:)=A(i,:)/norm(A(i,:),2);
    if(sum(A(i,:)==0)>0)
        %disp(i);
    else
        A2=[A2; A(i,:)];
    end
end
A=A2;
phi=RandOrthMat(length(x));

x=phi*x;

wVar=.001;
y=A*x;
size(A);
thisZ=y;
thisPsi=A*phi;

    xmean0=0;
    xvar0=1;
    inputEst0 = AwgnEstimIn(xmean0, xvar0);
    inputEst = SparseScaEstim( inputEst0, .1 );

    outputEst = AwgnEstimOut(thisZ, 0);
    
    opt = GampOpt();
    opt.nit=40;
    opt.tol=10^-5;
    [shat,it] = gampEst(inputEst, outputEst, thisPsi, opt);
    
    xhat=phi*shat;
    it;
    round(20*log10(norm(x,2)/norm(x-xhat,2)))
    snr1(run)=round(20*log10(norm(x,2)/norm(x-xhat,2)));
    
%     cvx_begin quiet
%     variable s(size(phi,1));
%     minimize(norm(s,1));
%     subject to
%         norm(thisZ-thisPsi*s,2)<10^-5;
%     cvx_end
%     
%     xhat=phi*s;
%     snr2(run)=round(20*log10(norm(x,2)/norm(x-xhat,2)));
    

    Aresh=reshape(A,size(A,1)*size(A,2),1);
    %figure,hist(Aresh,30);
    %disp(run);
end

s1(r)=mean(snr1);
%s2(r)=mean(snr2);
disp(r);
end


plot(rrrVec,s1,'r'); hold on; 
%plot(rrrVec,s2,'b');