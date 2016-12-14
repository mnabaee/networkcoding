%Test BP Decoder of GMA

close all
clear all
clc
warning off

addpath('../trunk/code/main');

load mats;

k=round(.1*length(x));

rrrVec=[5:2:40];

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
    [shat] = gampEst(inputEst, outputEst, thisPsi, opt);
    
    xhat=phi*shat;
    
    snr1(run)=round(20*log10(norm(x,2)/norm(x-xhat,2)));
    

    %disp(run);
end

s1(r)=mean(snr1);
s2(r)=mean(snr2);
disp(r);
end


plot(rrrVec,s1,'r'); hold on; 
