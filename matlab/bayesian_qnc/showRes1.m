%Show the Results

close all;
clear all;
clc;

saveFileName='resMain2run2';

load(saveFileName);

dataPt1BP=[]; dataPt2BP=[];
dataPt1L1=[]; dataPt2L1=[];
dataPt1PI=[]; dataPt2PI=[];

for spInd=1:length(spVec)
    for blInd=1:length(bLenVec)
        avgxNorm(blInd,spInd)=mean(xNorm(:,blInd,spInd));
        for t=2:iterations+1
            avgRecErrBP(t,blInd,spInd)=mean(recErrNormBP(t,:,blInd,spInd));
            avgRecErrL1(t,blInd,spInd)=mean(recErrNorml1min(t,:,blInd,spInd));
            avgRecErrPI(t,blInd,spInd)=mean(recErrNormPinv(t,:,blInd,spInd));
            
            avgTimeBP(blInd,spInd)=mean(decTimeBP(:,blInd,spInd));
            avgTimeL1(blInd,spInd)=mean(decTimeL1(:,blInd,spInd));
            avgTimePI(blInd,spInd)=mean(decTimePI(:,blInd,spInd));
            
            dataPt1BP=[dataPt1BP t]; dataPt2BP=[dataPt2BP 20*log10(avgxNorm(blInd,spInd)/avgRecErrBP(t,blInd,spInd))];
            dataPt1L1=[dataPt1L1 t]; dataPt2L1=[dataPt2L1 20*log10(avgxNorm(blInd,spInd)/avgRecErrL1(t,blInd,spInd))];
            dataPt1PI=[dataPt1PI t]; dataPt2PI=[dataPt2PI 20*log10(avgxNorm(blInd,spInd)/avgRecErrPI(t,blInd,spInd))];
            
            20*log10(avgxNorm(blInd,spInd)/avgRecErrBP(t,blInd,spInd));
            20*log10(avgxNorm(blInd,spInd)/avgRecErrL1(t,blInd,spInd));
            20*log10(avgxNorm(blInd,spInd)/avgRecErrPI(t,blInd,spInd));
        end
        
    end
end


figure(1), hold on;
plot(dataPt1BP,dataPt2BP,'ro');
plot(dataPt1L1,dataPt2L1,'b^');
%plot(dataPt1PI,dataPt2PI,'ks');
legend('BP','L1'); grid on;
xlabel('t'); ylabel('Decoding SNR');