%plotForBLen: Filtering Data and Plotting the Results

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

t=10;
spInd=2;
forBlXvec=[]; forBlYvec=[];
for blInd=1:length(bLenVec)
    forBlXvec(blInd)=(bLenVec(blInd));
    forBlYvec(blInd)=log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd));
end

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Packet Length L','fontsize',FontSize); 
ylabel('Logarithmic Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
title(['edges=' num2str(edges) ', t=' num2str(t) ', k/n=' num2str(spVec(spInd))],'fontsize',FontSize);
plot(forBlXvec,forBlYvec,'r-o','linewidth',lw);

%%%NEW FIGURE
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Packet Length L','fontsize',FontSize); 
ylabel('Logarithmic Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
%title(['edges=' num2str(edges)],'fontsize',FontSize);

t=10;
spInd=1;
forBlXvec=[]; forBlYvec=[];
for blInd=1:length(bLenVec)
    forBlXvec(blInd)=(bLenVec(blInd));
    forBlYvec(blInd)=log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd));
end
plot(forBlXvec,forBlYvec,'r-o','linewidth',lw);

t=25;
spInd=2;
forBlXvec=[]; forBlYvec=[];
for blInd=1:length(bLenVec)
    forBlXvec(blInd)=(bLenVec(blInd));
    forBlYvec(blInd)=log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd));
end
plot(forBlXvec,forBlYvec,'b-s','linewidth',lw);

t=39;
spInd=3;
forBlXvec=[]; forBlYvec=[];
for blInd=1:length(bLenVec)
    forBlXvec(blInd)=(bLenVec(blInd));
    forBlYvec(blInd)=log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd));
end
plot(forBlXvec,forBlYvec,'g-d','linewidth',lw);
xlabel('\fontfamily{cmr}Packet Length $L$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
ylabel('\fontfamily{cmr}Average $\log_{10}(|| \underline{x} - \underline{\hat{x}}_{\rm{QNC}}(t) ||^2_{\ell_2})$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
%ylabel('Average Norm of Recovery Error','fontsize',FontSize); 
legend(['t=' num2str(10) ', k/n=' num2str(spVec(1))],['t=' num2str(25) ', k/n=' num2str(spVec(2))],['t=' num2str(39) ', k/n=' num2str(spVec(1))]);
