%plotResRev2:Filtering Data and Plotting the Results

close all;
clear all;
clc;

%FileName='resMain2Run101-35-9-85-95';
%FileName='resMain2Run101-35-9-0-25';
%FileName='resMain2Run101-15-9-85-95';
FileName='resMain2Run101-15-9-0-25';
%FileName='resMain2Run101-25-9-0-25';
%FileName='resMain2Run101-25-9-85-95';

load(FileName);

blIndMarg=9;

disp(['Number of Deployment Realizations: ' num2str(doneRun)]);
disp(['Deployment Generation Parameters: Radio Range=' num2str(radioDecay) ', connPerc=' num2str(connPerc)]);
disp(['Deployment Generation Parameters: Inner Radius=' num2str(innerR/(sqrt(2)/2)) ', Outer Radius=' num2str(outerR/(sqrt(2)/2))]);

%Routing
avgXnorm=mean(xNormsPF(3,:));
for blInd=1:length(bLenVec)
for t=2:iterations+1
    data=[];
    for rlz=1:doneRun
        data(rlz)=recErrNormPF{blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort((data));
    dataFiltered=dataFiltered(0+1:end-0);
    MeanRecErrNormPF(t,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
    DelDelayPF(t,blInd)=bLenVec(blInd)*(t-1);
end
end
data1X=[];
data1Y=[];
for blInd=1:length(bLenVec)
    yVec=reshape(MeanRecErrNormPF(2:end,blInd),1,iterations); 
    xVec=reshape(DelDelayPF(2:end,blInd),1,iterations); 
    data1X=[data1X xVec];
    data1Y=[data1Y yVec];
end
[xVecPF,yVecPF]=topFinder(data1X,data1Y);

%QandNC
avgXnormQetNC=mean(xNormsQandNC);
minBlen=1;
while(1)
    if(~isempty(recErrNormQandNC{minBlen,1}))
       break;
    else
        minBlen=minBlen+1;
    end
end
for blInd=minBlen:size(recErrNormQandNC,1)
    data1=[];
    data2=[];
    for rlz=1:doneRun
        data1(rlz)=recErrNormQandNC{blInd,rlzInd};
        data2(rlz)=delay{blInd,rlzInd};
    end
    MeanRecErrNormQandNC(blInd)=20*log10(avgXnormQetNC)-20*log10(median(data1));
    DelDelayQandNC(blInd)=median(data2);
end
xVecQandNC=DelDelayQandNC;
yVecQandNC=MeanRecErrNormQandNC;

%yVecQandNC(7)=(yVecQandNC(6)+yVecQandNC(8))/2;


%[xVecQandNC,yVecQandNC]=topFinder(DelDelayQandNC,MeanRecErrNormQandNC);

%QNC
for spInd=1:length(spVec)
for epsKind=1:length(epsKvec)
for blInd=1:length(bLenVec)
        avgXnorm=mean(xNormL1(spInd,epsKind,blInd,:));
for t=2:iterations+1
    data=[];
    for rlz=1:doneRun
        data(rlz)=recErrNormL1{spInd,epsKind,blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort((data));
    dataFiltered=dataFiltered(1:end-0);
    MeanRecErrNormQNC(t,spInd,epsKind,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
    DelDelayQNC(t,spInd,epsKind,blInd)=bLenVec(blInd)*(t-1);
end
end
end
end
for spInd=1:length(spVec)
for epsKind=1:length(epsKvec)
    data1X=[];
    data1Y=[];
    for blInd=1:length(bLenVec)
        yVec=reshape(MeanRecErrNormQNC(2:end,spInd,epsKind,blInd),1,iterations); 
        xVec=reshape(DelDelayQNC(2:end,spInd,epsKind,blInd),1,iterations); 
        data1X=[data1X xVec];
        data1Y=[data1Y yVec];
    end
    %figure,plot(data1X,data1Y,'r-o'); hold on;
    [xVecQNC{spInd,epsKind},yVecQNC{spInd,epsKind}]=topFinder(data1X,data1Y);
end
end

%Plot the Results
FontSize=13;
lw=1.5;

scrsz = get(0,'ScreenSize');
for spInd=1:3
    figure('Position',[50 50 600 500]); 
    %figure('Position',[0 0 scrsz(3) scrsz(4) ] ); 
    plotLabel(FontSize);
    hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
    title([num2str(edges) ' edges, k/n=' num2str(spVec(spInd))],'fontsize',FontSize);
    plot(xVecQNC{spInd,1},yVecQNC{spInd,1},'r-^','linewidth',lw);
    plot(xVecQNC{spInd,2},yVecQNC{spInd,2},'g-s','linewidth',lw);
    plot(xVecQNC{spInd,3},yVecQNC{spInd,3},'b-o','linewidth',lw);
    plot(xVecQNC{spInd,4},yVecQNC{spInd,4},'c-d','linewidth',lw);
    plot(xVecPF,yVecPF,'k-*','linewidth',lw);
    plot(xVecQandNC,yVecQandNC,'k-v','linewidth',lw);
    if (spInd==1) 
        hh=legend(['QNC \epsilon_K=' num2str(epsKvec(1))],['QNC \epsilon_K=' num2str(epsKvec(2))],['QNC \epsilon_K=' num2str(epsKvec(3))],['QNC \epsilon_K=' num2str(epsKvec(4))],'Packet Forwarding','Q and NC'); 
        %set(hh,'interpreter','latex');
    end
    %saveas(gcf,[FileName '-sp' num2str(spInd)],'pdf');
end

for epsKind=1:4
    figure('Position',[50 50 600 500]); 
    %figure('Position',[0 0 scrsz(3) scrsz(4) ] ); 
    plotLabel(FontSize);
    hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
    title([num2str(edges) ' edges, \epsilon_K=' num2str(epsKvec(epsKind))],'fontsize',FontSize);
    plot(xVecQNC{1,epsKind},yVecQNC{1,epsKind},'r-^','linewidth',lw);
    plot(xVecQNC{2,epsKind},yVecQNC{2,epsKind},'g-s','linewidth',lw);
    plot(xVecQNC{3,epsKind},yVecQNC{3,epsKind},'b-o','linewidth',lw);
    plot(xVecPF,yVecPF,'k-*','linewidth',lw);
    plot(xVecQandNC,yVecQandNC,'k-v','linewidth',lw);
    if(epsKind==1)
        hh=legend(['QNC k/n=' num2str(spVec(1))],['QNC k/n=' num2str(spVec(2))],['QNC k/n=' num2str(spVec(3))],'Packet Forwarding','Q and NC'); 
        %set(hh,'interpreter','latex');
    end
    %saveas(gcf,[FileName '-epsK' num2str(epsKind)],'pdf');
end


%Plot Marginal Figures
blInd=blIndMarg;
epsKind=1;
yVec=[];
xVec=[];
for spInd=1:length(spVec)

    avgXnorm=mean(xNormL1(spInd,epsKind,blInd,:));
    for t=2:iterations+1
        data=[];
        for rlz=1:doneRun
            data(rlz)=recErrNormL1{spInd,epsKind,blInd,rlz}(t);
        end
        [dataFiltered,sortInd]=sort((data));
        dataFiltered=dataFiltered(1:end-0);
        MeanRecErrNormQNC(t,spInd,epsKind,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
        DelDelayQNC(t,spInd,epsKind,blInd)=bLenVec(blInd)*(t-1);
    end
        yVec{spInd}=reshape(MeanRecErrNormQNC(2:end,spInd,epsKind,blInd),1,iterations); 
        xVec{spInd}=reshape(DelDelayQNC(2:end,spInd,epsKind,blInd),1,iterations); 

end

figure('Position',[50 50 600 500]); 
%figure('Position',[0 0 scrsz(3) scrsz(4) ] ); 
plotLabel(FontSize);
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
title([num2str(edges) ' edges, \epsilon_K=' num2str(spVec(spInd))],'fontsize',FontSize);
plot(xVec{1},yVec{1},'r-^','linewidth',lw);
plot(xVec{2},yVec{2},'g-s','linewidth',lw);
plot(xVec{3},yVec{3},'b-o','linewidth',lw);

avgXnorm=mean(xNormsPF(3,:));
for t=2:iterations+1
    data=[];
    for rlz=1:doneRun
        data(rlz)=recErrNormPF{blInd,rlz}(t);
    end
    [dataFiltered,sortInd]=sort((data));
    dataFiltered=dataFiltered(0+1:end-0);
    MeanRecErrNormPF(t,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
    DelDelayPF(t,blInd)=bLenVec(blInd)*(t-1);
end
yVecPF=reshape(MeanRecErrNormPF(2:end,blInd),1,iterations); 
xVecPF=reshape(DelDelayPF(2:end,blInd),1,iterations); 
plot(xVecPF,yVecPF,'k-*','linewidth',lw);

avgXnormQetNC=mean(xNormsQandNC);
data1=[];
data2=[];
for rlz=1:doneRun
    data1(rlz)=recErrNormQandNC{blInd,rlzInd};
    data2(rlz)=delay{blInd,rlzInd};
end
MeanRecErrNormQandNC=20*log10(avgXnormQetNC)-20*log10(median(data1));
DelDelayQandNC=median(data2);

xVecQandNC=linspace(0,max(xVecPF),30);
yVecQandNC=0*xVecQandNC+min(min(yVecPF),min(MeanRecErrNormQandNC));
[c1,c2]=min(abs(DelDelayQandNC-xVecQandNC));
yVecQandNC(c2:end)=MeanRecErrNormQandNC;

plot(xVecQandNC,yVecQandNC,'c-v','linewidth',lw);
hh=legend(['QNC k/n=' num2str(spVec(1))],['QNC k/n=' num2str(spVec(2))],['QNC k/n=' num2str(spVec(3))],'Packet Forwarding','Q and NC'); 

