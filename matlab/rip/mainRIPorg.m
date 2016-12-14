%Main Module for analyzing RIP
format long;
close all;
clear all;
clc;


N=8;                    %Number of Sensor Nodes;
conMat=(rand(N,N)>.4).*(~eye(N,N));    %Small Connectivity Matrix;
GWnode=1;
its=16;                 %Number of Iterations;

vrlzs=100;               %Number of v Realizations;
Prlzs=100;               %Number of P Realizations;

spFactor=0.2;

%Generate random v's with unit norm
for genV=1:vrlzs
    v{genV}=(rand(N,1)-.5);
    %Sparcify them
    v{genV}=v{genV}.*(rand(N,1)<spFactor);
    v{genV}=v{genV}/norm(v{genV});
end

%Generate realizations of P
for genP=1:Prlzs;
    [P(genP,:),cncP(genP,:),cncPnlzd(genP,:)]=genNCmat(conMat,GWnode,its,0.4);
end

save RIPdata2;
load RIPdata2;

%Analyze for a single time instance of P (not concatinated)
tAnalyze=15;                   %Time instance which for RIP is investigated.
for genV=1:vrlzs
    for genP=1:Prlzs
        PvNorm(genP,genV)=norm(P{genP,tAnalyze}*v{genV},2);
		cncPnlzdvNorm(genP,genV)=norm(cncPnlzd{genP,tAnalyze}*v{genV},2);
    end
end

PvNormData=reshape(PvNorm,1,size(PvNorm,1)*size(PvNorm,2));
cncPnlzdvNormData=reshape(cncPnlzdvNorm,1,size(cncPnlzdvNorm,1)*size(cncPnlzdvNorm,2));

%figure(1),hist(PvNormData,100);
figure(2),hist(cncPnlzdvNormData,100);

PvNormData2=PvNormData*(1/mean(PvNormData));
%cncPnlzdvNormData2=cncPnlzdvNormData/mean(cncPnlzdvNormData);
cncPnlzdvNormData2=cncPnlzdvNormData/sum(cncPnlzdvNormData)*length(cncPnlzdvNormData);
%figure(3),hist(PvNormData2,100);
figure(4),hist(cncPnlzdvNormData2,100);
