%Data Filtering and Plot
close all;
clear all;
clc;
load resRun1;
FontSize=11;

for i=1:2*length(spVec)+1
for j=2:iterations+1
    dataRecErrNorm=recErrNorm(i,j,:);
    dataxNorm=xNorm(i,j,:);
    datanumMeas=numMeas(i,j,:);
    dataRecErrNorm=reshape(dataRecErrNorm,size(recErrNorm,3),1);
    dataxNorm=reshape(dataxNorm,size(recErrNorm,3),1);
    datanumMeas=reshape(datanumMeas,size(recErrNorm,3),1);
    [h1,h2]=hist(dataRecErrNorm,40);
    [sortRes,sortInd]=sort(dataRecErrNorm);
    ind1=30;
    ind2=size(recErrNorm,3)-ind1;
    
    dataRecErrNorm=dataRecErrNorm(sortInd(ind1:ind2));
    dataxNorm=dataxNorm(sortInd(ind1:ind2));
    datanumMeas=datanumMeas(sortInd(ind1:ind2));
    
    
    avgRecErrNorm(i,j)=mean(dataRecErrNorm);
    avgxNorm(i,j)=mean(dataxNorm);
    avgSNR(i,j)=20*log10(avgxNorm(i,j)/avgRecErrNorm(i,j));
    avgNoMeas(i,j)=mean(datanumMeas);
end
end
    avgCRatio=avgNoMeas/nodes;
    convertCoef=avgNoMeas(1,2)*bLen*nodes;
    
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600*2 500])
subplot(1,2,1)
HaxDD=gca;
xlabel(HaxDD,'Average Delivery Delay [channel use]','fontsize',FontSize);
set(HaxDD,'XAxisLocation','bottom','fontsize',FontSize);
HaxCR = axes('Position',get(HaxDD,'Position'),...
           'XAxisLocation','top',...
           'color','none',...
           'YAxisLocation','right');
line(avgCRatio(1,2:end),avgSNR(1,2:end),'color','r','marker','s','parent',HaxCR); hold on;
line(avgCRatio(3,2:end),avgSNR(3,2:end),'color','b','marker','o','parent',HaxCR); hold on;
line(avgCRatio(5,2:end),avgSNR(5,2:end),'color','k','marker','^','parent',HaxCR); hold on;
line(avgCRatio(7,2:end),avgSNR(7,2:end),'color','m','marker','p','parent',HaxCR); hold on;
xlabel(HaxCR,'Average Compression Ratio','fontsize',FontSize); 
ylabel(HaxDD,'Average SNR [dB]','fontsize',FontSize);
legH=legend(HaxCR,['QNC-sp=' num2str(spVec(1))],['QNC-sp=' num2str(spVec(2))],['QNC-sp=' num2str(spVec(3))],'Packet Forwarding'); grid on;
set(legH,'color','white');
axCR=[0 3.3 -3 152];
axDD=[axCR(1)*convertCoef axCR(2)*convertCoef axCR(3) axCR(4)];
axis(HaxDD,axDD);
axis(HaxCR,axCR);

%%%%%%%%%%%%%%%%%%Zoomed Version
subplot(1,2,2)
HaxDD=gca;
xlabel(HaxDD,'Average Delivery Delay [channel use]','fontsize',FontSize);
set(HaxDD,'XAxisLocation','bottom','fontsize',FontSize);
HaxCR = axes('Position',get(HaxDD,'Position'),...
           'XAxisLocation','top',...
           'color','none',...
           'YAxisLocation','right');
line(avgCRatio(1,2:end),avgSNR(1,2:end),'color','r','marker','s','parent',HaxCR); hold on;
line(avgCRatio(3,2:end),avgSNR(3,2:end),'color','b','marker','o','parent',HaxCR); hold on;
line(avgCRatio(5,2:end),avgSNR(5,2:end),'color','k','marker','^','parent',HaxCR); hold on;
line(avgCRatio(7,2:end),avgSNR(7,2:end),'color','m','marker','p','parent',HaxCR); hold on;
xlabel(HaxCR,'Average Compression Ratio','fontsize',FontSize); 
ylabel(HaxDD,'Average SNR [dB]','fontsize',FontSize); grid on;

axCR=[0 2.5 -3 63];
axDD=[axCR(1)*convertCoef axCR(2)*convertCoef axCR(3) axCR(4)];
axis(HaxDD,axDD);
axis(HaxCR,axCR);




