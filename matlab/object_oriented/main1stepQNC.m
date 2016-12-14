%Main Module

close all;
clear all;
clc;
format long;

%Creating Sensor Deployment
s=sensorDepl;
s=createDeplGeo(s,100,10,10,2.5,.7);
%drawDepl(s,1);

%Generating Messages
rho=.1;
sigma2x=10;
sigma20=0.000001;

sM=sensorMessages;
sM=generateMess2Gauss(sM,s.nodes,sigma2x,sigma20,rho);
%plotMessages(sM,2);

%Generate QNC Codes
code=QNCcodeBook;
code=generateCodeFull(code,s,10);
code=calculatePsiTot(code);

%Generate Uniform Quantizer Operator
Q=Quantizer;
Q=uniformQuantizerShifted(Q,sM.range*.1,18);


%Simulate QNC
sim=QNCsimulation;
sim=performQNC(sim,code,sM,Q,1);
sim=collectNoises(sim);
sim=calculateEffTotNoise(sim,code,sM);

%[sim,code]=updateRows(sim,code);


DeltaQvals=max(sim.MargNoiseVec)-min(sim.MargNoiseVec)

figure(1),subplot(1,2,1),hist(sim.MargNoiseVec,50); title(['Marg Noise | QstepSize=' num2str(Q.stepSize)]); grid on;
figure(1),subplot(1,2,2),hist(sim.EffMeasNoiseTot{end},50); title(['Effective Noise | variance=' num2str(var(sim.EffMeasNoiseTot{end}))]); grid on;

%figure(3),stem(log(abs(sim.EffMeasNoiseTot{end})));

%L1min Decoding
 sim=L1minDecoder(sim,code,sM,Q,1);
eval=simEval;
 eval=calculateErrL1MIN(eval,sim,sM);
 figure(2),plot(eval.snrL1MIN(2:end),'ro-'); hold on; grid on;

%RBP Decoding
BPsteps=10;
sim=RelaxedBPDecoderTSGMM_AWGN(sim,code,sM,Q,BPsteps,1);
eval=calculateErrRBP(eval,sim,sM);


figure(2),plot(eval.snrRelaxedBP(2:end,end),'bs-'); hold on;
figure(2),plot(max(eval.snrRelaxedBP(2:end,:)'),'g^-'); hold on;
legend('L1MIN','RBPend','RBPmax');
%legend('RBPend','RBPmax'); grid on;

