%Data Filtering and Plot4
close all;
clear all;
clc;
saveFileName='resMain5Run37';
FontSize=11;

load(saveFileName);

cutNumsL=5;
cutNumsR=35;

for spInd=1:length(spVec)
for blInd=1:length(bLenVec)
for t=2:iterations+1
    for rlz=1:RlzS
        dataL1(rlz)=recErrNormL1{spInd,blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort(dataL1);
    dataFiltered=dataFiltered(cutNumsL+1:end-cutNumsR);
    NormsFiltered=xNormsQNC(spInd,sortInd(cutNumsL+1:end-cutNumsR));
    SNRqnc(spInd,blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end
end

for blInd=1:length(bLenVec)
for t=2:iterations+1
    for rlz=1:RlzS
        dataPF(rlz)=recErrNormPF{blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort(dataPF);
    dataFiltered=dataFiltered(cutNumsL+1:end-cutNumsR);
    NormsFiltered=xNormsPF(length(spVec),sortInd(cutNumsL+1:end-cutNumsR));
    SNRpf(blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end

figure(1), hold on; xlabel('Average Delivery Delay [channel use]'); ylabel('Average SNR [dB]'); grid on;


for spInd=1:length(spVec)
    data1X=[];
    data1Y=[];
    if(spInd==1)
        data2X=[];
        data2Y=[];
    end
    for blInd=1:length(bLenVec)
        yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); 

        plot([2:iterations+1]*bLenVec(blInd),yVec,'r-o');

        data1X=[data1X [2:iterations+1]*bLenVec(blInd)];
        data1Y=[data1Y yVec];
        
        if(spInd==1)
            yVec=reshape(SNRpf(blInd,2:end),1,iterations); 
            plot([2:iterations+1]*bLenVec(blInd),yVec,'b-^');
            data2X=[data2X [2:iterations+1]*bLenVec(blInd)];
            data2Y=[data2Y yVec];
        end
    end
    [xVec1{spInd},yVec1{spInd}]=topFinder(data1X,data1Y);
end

%Finding the top points
[xVec2,yVec2]=topFinder(data2X,data2Y);

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600*2 500]); box on;

subplot(1,2,1), 
hold on; xlabel('Average Delivery Delay [channel use]','fontsize',FontSize); ylabel('Average SNR [dB]','fontsize',FontSize); grid on;
plot(xVec1{1},yVec1{1},'r-s'); 
plot(xVec1{2},yVec1{2},'b-o'); 
plot(xVec1{3},yVec1{3},'k-^'); 
plot(xVec2,yVec2,'m-p'); 
legend('QNC-sp=0.1','QNC-sp=0.2','QNC-sp=0.3','Packet Forwarding');
set(gca,'fontsize',FontSize);
axis([0 620 0 120]);


subplot(1,2,2), hold on; xlabel('Average Delivery Delay [channel use]','fontsize',FontSize); ylabel('Average SNR [dB]','fontsize',FontSize); grid on;
plot(xVec1{1},yVec1{1},'r-s'); 
plot(xVec1{2},yVec1{2},'b-o'); 
plot(xVec1{3},yVec1{3},'k-^'); 
plot(xVec2,yVec2,'m-p'); 
set(gca,'fontsize',FontSize);
axis([0 300 0 60]);

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500])
lW=2;
hold on; xlabel('Average Delivery Delay [channel use]','fontsize',FontSize); ylabel('Average SNR [dB]','fontsize',FontSize); grid on;
plot(xVec1{1},yVec1{1},'r-s','linewidth',lW); 
plot(xVec1{2},yVec1{2},'b-o','linewidth',lW); 
plot(xVec1{3},yVec1{3},'k-^','linewidth',lW); 
plot(xVec2,yVec2,'m-','linewidth',lW); 
legend('QNC-sp=0.1','QNC-sp=0.2','QNC-sp=0.3','Packet Forwarding');
set(gca,'fontsize',FontSize);
set(gca,'box','on');





