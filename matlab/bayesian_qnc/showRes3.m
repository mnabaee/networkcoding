%Show the Results

close all;
clear all;
clc;

saveFileName='resMain3run5';
saveFileName='resMain3run6';

load(saveFileName);
doneRlz


RmWd=7;
%Delay vs SNR
figure(2), hold on;
for spInd=1:3
    dataPt1BP=[]; dataPt2BP=[];
    dataPt1L1=[]; dataPt2L1=[];
    dataPt1PI=[]; dataPt2PI=[];
    for blInd=1:length(bLenVec)
        bLen=bLenVec(blInd);
        avgxNorm(blInd,spInd)=mean(xNorm(:,blInd,spInd));
        for t=2:iterations+1
            DDD=recErrNormBP(t,1:doneRlz,blInd,spInd);
            DDD=sort(DDD);          DDD=DDD(RmWd:end-RmWd); avgRecErrBP(t,blInd,spInd)=mean(DDD);
            DDD=recErrNorml1min(t,1:doneRlz,blInd,spInd);
            DDD=sort(DDD);          DDD=DDD(RmWd:end-RmWd); avgRecErrL1(t,blInd,spInd)=mean(DDD);
            DDD=recErrNormPinv(t,1:doneRlz,blInd,spInd);
            DDD=sort(DDD);          DDD=DDD(RmWd:end-RmWd); avgRecErrPI(t,blInd,spInd)=mean(DDD);
           
            %avgTimeBP(blInd,spInd)=mean(decTimeBP(1:doneRlz,blInd,spInd));
            %avgTimeL1(blInd,spInd)=mean(decTimeL1(1:doneRlz,blInd,spInd));
            %avgTimePI(blInd,spInd)=mean(decTimePI(1:doneRlz,blInd,spInd));
            
            dataPt1BP=[dataPt1BP (t-1)*bLen]; dataPt2BP=[dataPt2BP 20*log10(avgxNorm(blInd,spInd)/avgRecErrBP(t,blInd,spInd))];
            dataPt1L1=[dataPt1L1 (t-1)*bLen]; dataPt2L1=[dataPt2L1 20*log10(avgxNorm(blInd,spInd)/avgRecErrL1(t,blInd,spInd))];
            dataPt1PI=[dataPt1PI (t-1)*bLen]; dataPt2PI=[dataPt2PI 20*log10(avgxNorm(blInd,spInd)/avgRecErrPI(t,blInd,spInd))];

        end
        
    end

    if(spInd==1)
        plot(dataPt1BP,dataPt2BP,'ro');
    elseif(spInd==2)
        plot(dataPt1BP,dataPt2BP,'g^');
    elseif(spInd==3)
        plot(dataPt1BP,dataPt2BP,'y*');
    end
    
    [topFigXBP{spInd},topFigYBP{spInd}]=topFinder2(dataPt1BP,dataPt2BP);
    [topFigXL1{spInd},topFigYL1{spInd}]=topFinder2(dataPt1L1,dataPt2L1);
    
end
%For Routing
dataPt1PF=[]; dataPt2PF=[];

for blInd=1:length(bLenVecRouting)
    bLen=bLenVecRouting(blInd);
    avgxNorm(blInd)=mean(xNorm(:,blInd,spInd));
    for t=2:iterationsRouting+1
        
        DDD=recErrNormRouting(t,1:doneRlz,blInd);
        DDD=sort(DDD);
        DDD=DDD(RmWd:end-RmWd);
        
        avgRecErrPF(t,blInd)=mean(DDD);

        dataPt1PF=[dataPt1PF (t-1)*bLen]; dataPt2PF=[dataPt2PF 20*log10(avgxNorm(blInd)/avgRecErrPF(t,blInd))];
    end

end
[topFigXPF,topFigYPF]=topFinder2(dataPt1PF,dataPt2PF);
plot(dataPt1PF,dataPt2PF,'ks');
%legend('BP','Routing'); grid on;
xlabel('Delay '); ylabel('Decoding SNR'); grid on;

lw=1.5;
fS=14;
scrsz = get(0,'ScreenSize');
figure('Position',[20 20  scrsz(4)/2*1.3 scrsz(4)/2*1.1]);
hold on; grid on;     box on;     set(gca,'fontsize',fS);

plot(topFigXBP{1},topFigYBP{1},'r--d','linewidth',lw);
plot(topFigXL1{1},topFigYL1{1},'r:s','linewidth',lw);

% plot(topFigXBP{2},topFigYBP{2},'k--+','linewidth',lw);
% plot(topFigXL1{2},topFigYL1{2},'k:v','linewidth',lw);

plot(topFigXBP{3},topFigYBP{3},'b--^','linewidth',lw);
plot(topFigXL1{3},topFigYL1{3},'b:o','linewidth',lw);

% plot(topFigXBP{1},topFigYBP{1},'r-d','linewidth',lw);
% plot(topFigXBP{2},topFigYBP{2},'k-s','linewidth',lw);
% plot(topFigXBP{3},topFigYBP{3},'b-^','linewidth',lw);
% 
% plot(topFigXL1{1},topFigYL1{1},'r:d','linewidth',lw);
% plot(topFigXL1{2},topFigYL1{2},'k:s','linewidth',lw);
% plot(topFigXL1{3},topFigYL1{3},'b:^','linewidth',lw);

plot(topFigXPF,topFigYPF,'k-','linewidth',lw);

%legend(['QNC k/n=' num2str(spVec(1))],['QNC k/n=' num2str(spVec(2))],['QNC k/n=' num2str(spVec(3))],'Packet Forwarding');
%legend(['QNC-BP k/n=' num2str(spVec(1))],['QNC-BP k/n=' num2str(spVec(2))],['QNC-BP k/n=' num2str(spVec(3))],['QNC-L_1 k/n=' num2str(spVec(1))],['QNC-L_1 k/n=' num2str(spVec(2))],['QNC-L_1 k/n=' num2str(spVec(3))],'Packet Forwarding');
legend(['QNC-GAMP k/n=' num2str(spVec(1))],['QNC-L_1  k/n=' num2str(spVec(1))],['QNC-GAMP k/n=' num2str(spVec(3))],['QNC-L_1  k/n=' num2str(spVec(3))],'Packet Forwarding');
%title(['SNR vs Delivery Delay for ' num2str(perNodeEdges) ' edges per node'], 'fontsize',fS);
xlabel('Average Delivery Delay [channel use]','fontsize',fS); 
ylabel('Average SNR [dB]','fontsize',fS); 
edges
figure(2),close;
