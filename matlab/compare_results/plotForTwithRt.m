%plotForTwithRt: Filtering Data and Plotting the Results

close all;
clear all;
clc;

FileNameRealResults='resMain2Run101-25-9-0-25';
loadFileNameBound='resCalcRt_101_25_9_0_25';
%loadFileNameBound='resCalcRt2_101_25_9_0_25';
FontSize=13;
lw=1.5;

load(FileNameRealResults);
disp(['Number of Deployment Realizations: ' num2str(doneRun)]);
disp(['Deployment Generation Parameters: Radio Range=' num2str(radioDecay) ', connPerc=' num2str(connPerc)]);
disp(['Deployment Generation Parameters: Inner Radius=' num2str(innerR/(sqrt(2)/2)) ', Outer Radius=' num2str(outerR/(sqrt(2)/2))]);

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
blInd=14;
forBlXvec=[]; forBlYvec=[];
for t=2:size(MeanRecErrNormQNC,1)
    fortXvec(t)=(t);
    fortYvec(t)=20*log10(MeanRecErrNormQNC(t,spInd,epsKind,blInd))/10;
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


%%%%%Calculate and Plot theoretical Bound
load(loadFileNameBound);
rVal=[];
for t=1:length(allResults.Rvalues{1})
    data=[];
    for i=1:length(allResults.Rvalues)
        data=[data allResults.Rvalues{i}(t)];
    end
    rVal(t)=median(data);
end
gamma0=1;%sqrt(q);
bLength=bLenVec(blInd);
%bLength=30;
%deltaQ=2*q/(2^(bLength*C0));
avgXnorm=avgXnorm;
for spInd=1:1%length(spVec)
    kVal=round(spVec(spInd)*nodes);
    fortXvec2=[];
    fortYvec2=[];
    for t=2:length(allResults.Rvalues{1})
        fortXvec2(t)=t;
        fortYvec2(t)=(10*log10(2*kVal)+20*log10(2*q)-20*log10(2)*C0*bLength-20*log10(gamma0)+20*log10(rVal(t)))/10;
    end
    plot(fortXvec2(2:end),fortYvec2(2:end),'r-o','linewidth',lw);
end

xlabel('\fontfamily{cmr}Time Index $t$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
ylabel('\fontfamily{cmr}Average $\log_{10}(|| \underline{x} - \underline{\hat{x}}_{\rm{QNC}}(t) ||^2_{\ell_2})$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 

legend('Decoding Error of L_2 min Decoder','Proposed Upper Bound');