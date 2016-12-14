%Show the Results

close all;
clear all;
clc;

saveFileName='resMain2run1';

load(saveFileName);
doneRlz
edges
RmWd=7;
for spInd=1:length(spVec)
    dataPt1BP=[]; dataPt2BP=[];
    dataPt1L1=[]; dataPt2L1=[];
for blInd=1:length(bLenVec)
    bLen=bLenVec(blInd);
        avgxNorm(blInd,spInd)=mean(xNormOneStepQNC(1:doneRlz,blInd,spInd));
        for t=3:size(recErrNormL1min,1)
            DDD=recErrNormL1min(t,1:doneRlz,blInd,spInd);
            DDD=sort(DDD); DDD=DDD(RmWd:end-RmWd); avgRecErrL1(t,blInd,spInd)=mean(DDD);
            DDD=recErrNormBP(t,1:doneRlz,blInd,spInd);
            DDD=sort(DDD); DDD=DDD(RmWd:end-RmWd); avgRecErrBP(t,blInd,spInd)=mean(DDD);
            
            dataPt1L1=[dataPt1L1 (t-1)*bLen]; dataPt2L1=[dataPt2L1 20*log10(avgxNorm(blInd,spInd)/avgRecErrL1(t,blInd,spInd))];
            dataPt1BP=[dataPt1BP (t-1)*bLen]; dataPt2BP=[dataPt2BP 20*log10(avgxNorm(blInd,spInd)/avgRecErrBP(t,blInd,spInd))]; 
        end
end
[topFigXBP{spInd},topFigYBP{spInd}]=topFinder2(dataPt1BP,dataPt2BP);
[topFigXL1{spInd},topFigYL1{spInd}]=topFinder2(dataPt1L1,dataPt2L1);
if(spInd==1)
figure(1), hold on; grid on;
figure(1),plot(dataPt1L1,dataPt2L1,'ro');
figure(1),plot(dataPt1BP,dataPt2BP,'bs');
end
end
dataPt1PF=[]; dataPt2PF=[];
for blInd=1:length(bLenVec)  
    bLen=bLenVec(blInd);
    for t=2:iterationsRouting+1
        DDD=recErrNormRouting(t,1:doneRlz,blInd);
        DDD=sort(DDD);        DDD=DDD(RmWd:end-RmWd);        avgRecErrPF(t,blInd)=mean(DDD);
        dataPt1PF=[dataPt1PF (t-1)*bLen]; dataPt2PF=[dataPt2PF 20*log10(avgxNorm(blInd)/avgRecErrPF(t,blInd))];
    end
end
[topFigXPF,topFigYPF]=topFinder2(dataPt1PF,dataPt2PF);
figure(1),plot(dataPt1PF,dataPt2PF,'k^');

lw=1.5;
fS=14;
scrsz = get(0,'ScreenSize');
figure('Position',[20 20  scrsz(4)/2*1.3 scrsz(4)/2*1.1]);
hold on; grid on;     box on;     set(gca,'fontsize',fS);

plot(topFigXBP{1},topFigYBP{1},'r--d','linewidth',lw);
plot(topFigXL1{1},topFigYL1{1},'r:s','linewidth',lw);

% plot(topFigXBP{2},topFigYBP{2},'c--+','linewidth',lw);
% plot(topFigXL1{2},topFigYL1{2},'c:v','linewidth',lw);

plot(topFigXBP{3},topFigYBP{3},'b--^','linewidth',lw);
plot(topFigXL1{3},topFigYL1{3},'b:o','linewidth',lw);

plot(topFigXPF,topFigYPF,'k-','linewidth',lw);

legend(['QNC-BP k/n=' num2str(spVec(1))],['QNC-L_1  k/n=' num2str(spVec(1))],['QNC-BP k/n=' num2str(spVec(3))],['QNC-L_1  k/n=' num2str(spVec(3))],'Packet Forwarding');
title(['SNR vs Delivery Delay for ' num2str(perNodeEdges) ' edges per node'], 'fontsize',fS);
xlabel('Average Delivery Delay [channel use]','fontsize',fS); 
ylabel('Average SNR [dB]','fontsize',fS); 
figure(1),close;

