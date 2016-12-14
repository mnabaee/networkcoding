%Data Filtering and Plot3
close all;
clear all;
clc;
saveFileName='resMain5Run34';
FontSize=11;

load(saveFileName);

cutNums=20;

for spInd=1:length(spVec)
for blInd=1:length(bLenVecfull)
for t=2:iterations+1
    for rlz=1:RlzS
        dataL1(rlz)=recErrNormL1full{spInd,blInd,rlz}(t);
    end
    [dataFiltered,sInd]=sort(dataL1);
    dataFiltered=dataFiltered(cutNums+1:end-cutNums);
    NormsFiltered=xNormsQNCfull(spInd,blInd,sInd(cutNums+1:end-cutNums));
    SNRqnc(spInd,blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end
end

for blInd=1:length(bLenVecfull)
for t=2:iterations+1
    for rlz=1:RlzS
        dataPF(rlz)=recErrNormPFfull{blInd,rlz}(t);
    end
    [dataFiltered,sInd]=sort(dataPF);
    dataFiltered=dataFiltered(1:end);
    NormsFiltered=xNormsPFfull(length(spVec),blInd,:);
    SNRpf(blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end

figure(1), hold on; xlabel('Delivery Delay [channel use]'); ylabel('Average SNR [dB]'); grid on;

spInd=3;

for blInd=1:length(bLenVecfull)
    yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); 
    plot([2:iterations+1]*bLenVecfull(blInd),yVec,'r-o');
    
    yVec=reshape(SNRpf(blInd,2:end),1,iterations); 
    plot([2:iterations+1]*bLenVecfull(blInd),yVec,'b-^');
end

