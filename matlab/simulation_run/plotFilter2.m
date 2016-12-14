%Data Filtering and Plot2
close all;
clear all;
clc;
saveFileName='resMain5Run32';
FontSize=11;

load(saveFileName);

cutNums=20;

for spInd=1:length(spVec)
for blInd=1:length(bLenVec)
for t=2:iterations+1
    for rlz=1:RlzS
        dataL1(rlz)=recErrNormL1{spInd,blInd,rlz}(t);
    end
    [dataFiltered,sInd]=sort(dataL1);
    dataFiltered=dataFiltered(cutNums+1:end-cutNums);
    NormsFiltered=xNormsQNC(spInd,sInd(cutNums+1:end-cutNums));
    SNRqnc(spInd,blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end
end

for blInd=1:length(bLenVec)
for t=2:iterations+1
    for rlz=1:RlzS
        dataPF(rlz)=recErrNormPF{blInd,rlz}(t);
    end
    [dataFiltered,sInd]=sort(dataPF);
    dataFiltered=dataFiltered(1:end);
    NormsFiltered=xNormsPF(length(spVec),:);
    SNRpf(blInd,t)=20*log10(mean(NormsFiltered)/mean(dataFiltered));
end
end

figure(1), hold on; xlabel('Delivery Delay [channel use]'); ylabel('Average SNR [dB]'); grid on;

spInd=3;

blInd=1; yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'r-o');
blInd=2; yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'g-o');
blInd=3; yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'b-o');
blInd=4; yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'c-o');
%blInd=5; yVec=reshape(SNRqnc(spInd,blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'k-o');

blInd=1; yVec=reshape(SNRpf(blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'r-^');
blInd=2; yVec=reshape(SNRpf(blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'g-^');
blInd=3; yVec=reshape(SNRpf(blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'b-^');
blInd=4; yVec=reshape(SNRpf(blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'c-^');
%blInd=5; yVec=reshape(SNRpf(blInd,2:end),1,iterations); plot([2:iterations+1]*bLenVec(blInd),yVec,'k-^');

legend('QNC-blen=25','QNC-blen=20','QNC-blen=15','QNC-blen=10','PF-blen=25','PF-blen=20','PF-blen=15','PF-blen=10');
title('edges=1400'); 
