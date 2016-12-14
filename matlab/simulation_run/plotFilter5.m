%Data Filtering and Plot5
close all;
clear all;
clc;
saveFileName1='resMain5Run37';
saveFileName2='resMain6Run1400-1';
FontSize=11;
cutNumsL=5;
cutNumsR=35;


load(saveFileName1);

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

for spInd=1:length(spVec)
    data1X=[];
    data1Y=[];
    if(spInd==1)
        data2X=[];
        data2Y=[];
    end
    for blInd=1:length(bLenVec)
        yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); 

        data1X=[data1X [2:iterations+1]*bLenVec(blInd)];
        data1Y=[data1Y yVec];
        
        if(spInd==1)
            yVec=reshape(SNRpf(blInd,2:end),1,iterations); 
            data2X=[data2X [2:iterations+1]*bLenVec(blInd)];
            data2Y=[data2Y yVec];
        end
    end
    [xVec1{spInd},yVec1{spInd}]=topFinder(data1X,data1Y);
end

%Finding the top points
[xVec2,yVec2]=topFinder(data2X,data2Y);

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500])

hold on; xlabel('Average Delivery Delay [channel use]','fontsize',FontSize); ylabel('Average SNR [dB]','fontsize',FontSize); grid on; title([num2str(edges) ' edges'],'fontsize',FontSize);
set(gca,'fontsize',FontSize);
set(gca,'box','on');
plot(xVec1{1},yVec1{1},'r-s'); 
plot(xVec1{2},yVec1{2},'r-o'); 
plot(xVec1{3},yVec1{3},'r-^'); 
plot(xVec2,yVec2,'k-'); 


load(saveFileName2);

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

for spInd=1:length(spVec)
    data1X=[];
    data1Y=[];
    if(spInd==1)
        data2X=[];
        data2Y=[];
    end
    for blInd=1:length(bLenVec)
        yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); 

        data1X=[data1X [2:iterations+1]*bLenVec(blInd)];
        data1Y=[data1Y yVec];
        
        if(spInd==1)
            yVec=reshape(SNRpf(blInd,2:end),1,iterations); 
            data2X=[data2X [2:iterations+1]*bLenVec(blInd)];
            data2Y=[data2Y yVec];
        end
    end
    [xVec1{spInd},yVec1{spInd}]=topFinder(data1X,data1Y);
end

%Finding the top points
[xVec2,yVec2]=topFinder(data2X,data2Y);

plot(xVec1{1},yVec1{1},'b--s'); 
plot(xVec1{2},yVec1{2},'b--o'); 
plot(xVec1{3},yVec1{3},'b--^'); 
%plot(xVec2,yVec2,'m--'); 
legend('QNC-orth-sp=0.1','QNC-orth-sp=0.2','QNC-orth-sp=0.3','Packet Forwarding','QNC-North-sp=0.1','QNC-North-sp=0.2','QNC-North-sp=0.3');
