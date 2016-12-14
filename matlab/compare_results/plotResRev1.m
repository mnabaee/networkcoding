%plotResRev1:Filtering Data and Plotting the Results

close all;
clear all;
clc;

%load('resMain2Run101-35-9-85-95');
%load('resMain2Run101-35-9-0-25');
%load('resMain2Run101-15-9-85-95');
%load('resMain2Run101-15-9-0-25');
%load('resMain2Run101-25-9-0-25');
load('resMain2Run101-25-9-85-95');


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
FontSize=10;


scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
%figure('Position',[0 0 scrsz(3) scrsz(4) ] ); 
for spInd=1:3
    subplot(2,2,spInd), 
    plotLabel(FontSize);
    hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
    title([num2str(edges) ' edges, sp=' num2str(spVec(spInd))],'fontsize',FontSize);
    plot(xVecQNC{spInd,1},yVecQNC{spInd,1},'r-^');
    plot(xVecQNC{spInd,2},yVecQNC{spInd,2},'g-s');
    plot(xVecQNC{spInd,3},yVecQNC{spInd,3},'b-o');
    plot(xVecQNC{spInd,4},yVecQNC{spInd,4},'c-d');
    plot(xVecPF,yVecPF,'k-*');
    plot(xVecQandNC,yVecQandNC,'k-v');
    if (spInd==1) legend(['QNC epsK=' num2str(epsKvec(1))],['QNC epsK=' num2str(epsKvec(2))],['QNC epsK=' num2str(epsKvec(3))],['QNC epsK=' num2str(epsKvec(4))],'Packet Forwarding','Q and NC'); end
end


scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
%figure('Position',[0 0 scrsz(3) scrsz(4) ] ); 

for epsKind=1:4
    subplot(2,2,epsKind), 
    plotLabel(FontSize);
    hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
    title([num2str(edges) ' edges, \epsilon_K=' num2str(epsKvec(epsKind))],'fontsize',FontSize);
    plot(xVecQNC{1,epsKind},yVecQNC{1,epsKind},'r-^');
    plot(xVecQNC{2,epsKind},yVecQNC{2,epsKind},'g-s');
    plot(xVecQNC{3,epsKind},yVecQNC{3,epsKind},'b-o');
    plot(xVecPF,yVecPF,'k-*');
    plot(xVecQandNC,yVecQandNC,'k-v');
    if(epsKind==1)
        legend(['QNC sp=' num2str(spVec(1))],['QNC sp=' num2str(spVec(2))],['QNC sp=' num2str(spVec(3))],'Packet Forwarding','Q and NC'); 
    end
end

