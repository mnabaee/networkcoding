%Main Module for analyzing RIP
close all;
clear all;
clc;


N=8;                    %Number of Sensor Nodes;
conMat=(rand(N,N)>.4).*(~eye(N,N));    %Small Connectivity Matrix;
GWnode=1;
its=10;                 %Number of Iterations;

vrlzs=100;               %Number of v Realizations;
Prlzs=500;               %Number of P Realizations;

%Generate random v's with unit norm
for genV=1:vrlzs
    v{genV}=(rand(N,1)-.5);
    v{genV}=v{genV}/norm(v{genV});
end

%Generate realizations of P
for gen=1:Prlzs;
    [P(gen,:),cncP(gen,:),cncPnlzd(gen,:)]=genNCmat(conMat,GWnode,its,0.4);
end

save RIPdata1;

load RIPdata1;

%Analyze for a single time instance of P (not concatinated)
tAnalyze=3;             %Time instance which for RIP is investigated.
for genV=1:vrlzs
    for gen=1:Prlzs
        PvNorm(gen)=norm(P{gen,tAnalyze}*v{genV})^2;
    end
    PvNormMeanOverP(genV)=mean(PvNorm);
    PvNormVarOverP(genV)=var(PvNorm);
    
    [h1{genV},h2{genV}]=hist(PvNormMeanOverP,20);
end

figure,stem(log(PvNormMeanOverP)); hold on; stem(PvNormMeanOverP*0+0,'r'); title('E[PvNorm] over P realizations');
figure,stem(PvNormVarOverP./PvNormMeanOverP); title('Normalized Var[PvNorm] over P realizations');

%Analyze one PvNorm
genV=40;                %Index of Vector, which for RIP concentration is investigated.
figure,stem(h2{genV},h1{genV}); title('Hist[PvNorm] over P realizations for a Single vector (v)');