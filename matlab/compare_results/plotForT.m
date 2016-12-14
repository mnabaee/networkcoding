%plotForT: Filtering Data and Plotting the Results

close all;
clear all;
clc;

FileName='resMain2Run101-35-9-85-95';
load(FileName);

disp(['Number of Deployment Realizations: ' num2str(doneRun)]);
disp(['Deployment Generation Parameters: Radio Range=' num2str(radioDecay) ', connPerc=' num2str(connPerc)]);
disp(['Deployment Generation Parameters: Inner Radius=' num2str(innerR/(sqrt(2)/2)) ', Outer Radius=' num2str(outerR/(sqrt(2)/2))]);

FontSize=13;
lw=1.5;

%QNC
epsKind=1;
for spInd=1:length(spVec)
for blInd=1:length(bLenVec)
        avgXnorm=mean(xNormL1(spInd,epsKind,blInd,:));
for t=2:iterations+1
    data=[];
    for rlz=1:doneRun
        data(rlz)=recErrNormL1{spInd,epsKind,blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort((data));
    dataFiltered=dataFiltered(1:end-0);
    MeanSNRQNC(t,spInd,epsKind,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
    MeanRecErrNormQNC(t,spInd,epsKind,blInd)=median(dataFiltered.^2);
    DelDelayQNC(t,spInd,epsKind,blInd)=bLenVec(blInd)*(t-1);
end
end
end

spInd=1;
blInd=25;
forBlXvec=[]; forBlYvec=[];
for t=2:size(MeanRecErrNormQNC,1)
    fortXvec(t)=(t);
    fortYvec(t)=log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd));
end

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Time Index ( t )','fontsize',FontSize); 
ylabel('Logarithmic Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
title(['edges=' num2str(edges) ', bLen=' num2str(bLenVec(blInd)) ', k/n=' num2str(spVec(spInd))],'fontsize',FontSize);
%semilogx(fortXvec(2:end),fortYvec(2:end),'r-o','linewidth',lw);
hold on;
plot(fortXvec(2:end),fortYvec(2:end),'b-s','linewidth',lw);
