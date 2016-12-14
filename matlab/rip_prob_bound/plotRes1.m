%Plot for mainTail3

close all
clear all;
clc;

%load resLowUp001;
load all1;

%mVec tP1low tP1up tP2low tP2up tPglow tPgup nodes edges

figure(1), hold on; grid on
for i=1:1%size(tP1low,2)
    plot(mVec,tP1low(:,i),'r-^');
    plot(mVec,tP2low(:,i),'b-o');
    plot(mVec,tPglow(:,i),'g-s');
    xlabel('m'); ylabel('Probability of Left Tail');
end
legend('QNC1','QNC2','Gaussian');

figure(2), hold on; grid on
for i=1:1%size(tP1up,2)
    plot(mVec,tP1up(:,i),'r-^');
    plot(mVec,tP2up(:,i),'b-o');
    plot(mVec,tPgup(:,i),'g-s');
    xlabel('m'); ylabel('Probability of Right Tail');
end
legend('QNC1','QNC2','Gaussian');

