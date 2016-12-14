%Main Module

%GAMP Decoder

close all;
clear all;
clc;
format long;

%Creating Sensor Deployment
s=sensorDepl;
s=createDeplGeo(s,100,10,10,4.0,.9);
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
Q=uniformQuantizerShifted(Q,sM.range*.1,24);


%Simulate QNC
sim=QNCsimulation;
sim=performQNC(sim,code,sM,Q,1);
sim=collectNoises(sim);
sim=calculateEffTotNoise(sim,code,sM);

%[sim,code]=updateRows(sim,code);


DeltaQvals=max(sim.MargNoiseVec)-min(sim.MargNoiseVec)

figure(1),subplot(1,2,1),hist(sim.MargNoiseVec,50); title(['Marg Noise | QstepSize=' num2str(Q.stepSize)]); grid on;
figure(1),subplot(1,2,2),hist(repmat(sim.EffMeasNoiseTot{end},round(length(sim.MargNoiseVec)/length(sim.EffMeasNoiseTot{end})),1),50); title(['Effective Noise | variance=' num2str(var(sim.EffMeasNoiseTot{end}))]); grid on; hold on;
histfit(repmat(sim.EffMeasNoiseTot{end},round(length(sim.MargNoiseVec)/length(sim.EffMeasNoiseTot{end})),1),50);

%Plot the Normalized Histogram
[h1,h2]=hist(sim.MargNoiseVec,50);
[h3,h4]=hist(repmat(sim.EffMeasNoiseTot{end},round(length(sim.MargNoiseVec)/length(sim.EffMeasNoiseTot{end})),1),50);
figure(11),bar(h2,h1/sum(h1)); title(['Marg Noise | QstepSize=' num2str(Q.stepSize)]); grid on; xlabel('Marginal Quantization Noises'); ylabel('Normalized Histogram');
figure(12),bar(h4,h3/sum(h3)); title(['Effective Noise | variance=' num2str(var(sim.EffMeasNoiseTot{end}))]); grid on; hold on;
%[h5]=histfit(repmat(sim.EffMeasNoiseTot{end},round(length(sim.MargNoiseVec)/length(sim.EffMeasNoiseTot{end})),1),50);
%figure(12),bar(h6,h5/sum(h5),'r');
[mu,sigma]=normfit(repmat(sim.EffMeasNoiseTot{end},round(length(sim.MargNoiseVec)/length(sim.EffMeasNoiseTot{end})),1));
x1=linspace(mu-5*sigma,mu+5*sigma,100);
y1=normpdf(x1,mu,sigma);
y1=y1/sum(y1);
figure(12),plot(x1,y1,'r-o','linewidth',2); xlabel('Effective Quantization Noises'); ylabel('Normalized Histogram');
figure(12),legend('Normalized Histogram','Fitted Gaussian PDF');
figure(3),stem(log(abs(sim.EffMeasNoiseTot{end})));

% %L1min Decoding
%  sim=L1minDecoder(sim,code,sM,Q,1);
% eval=simEval;
%  eval=calculateErrL1MIN(eval,sim,sM);
%  figure(2),plot(eval.snrL1MIN(2:end),'ro-'); hold on; grid on;
% 
% %RBP Decoding
% BPsteps=10;
% sim=GAMPDecoderTSGMM_AWGN(sim,code,sM,Q);
% eval=calculateErrRBP(eval,sim,sM);
% 
% 
% figure(2),plot(eval.snrRelaxedBP(2:end,end),'bs-'); hold on;
% figure(2),plot(max(eval.snrRelaxedBP(2:end,:)'),'g^-'); hold on;
% legend('L1MIN','RBPend','RBPmax');
% %legend('RBPend','RBPmax'); grid on;

