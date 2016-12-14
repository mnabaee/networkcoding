%Plot the Results3

close all;
clear all;
clc;

FontSize=11;

load resRun13;
for hop=1:length(rlzNoMeasQNC{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasQNC{rlzInd}(hop);
        data2(rlzInd)=rlzSNRQNC{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormQNC{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormQNC{rlzInd}(3)*(10^(rlzSNRQNC{rlzInd}(3)/20));
    end
    avgNoMeasQNC(hop)=mean(data1);
    avgRecErrNormQNC(hop)=mean(data3);
    stdRecErrNormQNC(hop)=std(data3);
    avgSNRQNC(hop)=20*log10(NormX{rlzInd}/avgRecErrNormQNC(hop));
    stdSNRQNC(hop)=20*log10(NormX{rlzInd}/stdRecErrNormQNC(hop));
end
for hop=1:length(rlzNoMeasR{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasR{rlzInd}(hop);
        data2(rlzInd)=rlzSNRR{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormR{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormR{rlzInd}(3)*(10^(rlzSNRR{rlzInd}(3)/20));
    end
    avgNoMeasR(hop)=mean(data1);
    avgRecErrNormR(hop)=mean(data3);
    stdRecErrNormR(hop)=std(data3);
    avgSNRR(hop)=20*log10(NormX{rlzInd}/avgRecErrNormR(hop));
    stdSNRR(hop)=20*log10(NormX{rlzInd}/stdRecErrNormR(hop));
end

hl1 = line(avgNoMeasQNC(2:end)/nodes,avgSNRR(2:end),'Color','k','Marker','^'); hold on;
line(avgNoMeasQNC(2:end)/nodes,avgSNRQNC(2:end),'Color','b','Marker','s'); hold on;
xlabel('Compression Ratio','fontsize',FontSize); ylabel('SNR [dB]','fontsize',FontSize);grid on;
%axis([avgNoMeasQNC(2)/nodes avgNoMeasQNC(end)/nodes avgSNRR(2) avgSNRR(end)]);
axis tight;
axCR=axis;

ax1 = gca;
ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k');
       
%hl2 = line(avgNoMeasQNC(2:end)/avgNoMeasQNC(2)*bLen,avgSNRR(2:end),'Color','k','Parent',ax2);  
hl2 = line([],[],'Color','k','Parent',ax2);  
xlabel('Delivery Delay','fontsize',FontSize);

%axis([avgNoMeasQNC(2)/avgNoMeasQNC(2)*bLen,avgNoMeasQNC(end)/avgNoMeasQNC(2)*bLen avgSNRR(2) avgSNRR(end)]);
 
load resRun23;
for hop=1:length(rlzNoMeasQNC{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasQNC{rlzInd}(hop);
        data2(rlzInd)=rlzSNRQNC{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormQNC{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormQNC{rlzInd}(3)*(10^(rlzSNRQNC{rlzInd}(3)/20));
    end
    avgNoMeasQNC(hop)=mean(data1);
    avgRecErrNormQNC(hop)=mean(data3);
    stdRecErrNormQNC(hop)=std(data3);
    avgSNRQNC(hop)=20*log10(NormX{rlzInd}/avgRecErrNormQNC(hop));
    stdSNRQNC(hop)=20*log10(NormX{rlzInd}/stdRecErrNormQNC(hop));
end
for hop=1:length(rlzNoMeasR{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasR{rlzInd}(hop);
        data2(rlzInd)=rlzSNRR{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormR{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormR{rlzInd}(3)*(10^(rlzSNRR{rlzInd}(3)/20));
    end
    avgNoMeasR(hop)=mean(data1);
    avgRecErrNormR(hop)=mean(data3);
    stdRecErrNormR(hop)=std(data3);
    avgSNRR(hop)=20*log10(NormX{rlzInd}/avgRecErrNormR(hop));
    stdSNRR(hop)=20*log10(NormX{rlzInd}/stdRecErrNormR(hop));
end
GWports=avgNoMeasQNC(2);

line(avgNoMeasQNC(2:end)/nodes,avgSNRQNC(2:end),'Color','r','Marker','o','Parent',ax1); hold on;

load resRun33;
for hop=1:length(rlzNoMeasQNC{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasQNC{rlzInd}(hop);
        data2(rlzInd)=rlzSNRQNC{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormQNC{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormQNC{rlzInd}(3)*(10^(rlzSNRQNC{rlzInd}(3)/20));
    end
    avgNoMeasQNC(hop)=mean(data1);
    avgRecErrNormQNC(hop)=mean(data3);
    stdRecErrNormQNC(hop)=std(data3);
    avgSNRQNC(hop)=20*log10(NormX{rlzInd}/avgRecErrNormQNC(hop));
    stdSNRQNC(hop)=20*log10(NormX{rlzInd}/stdRecErrNormQNC(hop));
end
for hop=1:length(rlzNoMeasR{1})
    for  rlzInd=1:RlzS
        data1(rlzInd)=rlzNoMeasR{rlzInd}(hop);
        data2(rlzInd)=rlzSNRR{rlzInd}(hop);
        data3(rlzInd)=rlzRecErrNormR{rlzInd}(hop);
        NormX{rlzInd}=rlzRecErrNormR{rlzInd}(3)*(10^(rlzSNRR{rlzInd}(3)/20));
    end
    avgNoMeasR(hop)=mean(data1);
    avgRecErrNormR(hop)=mean(data3);
    stdRecErrNormR(hop)=std(data3);
    avgSNRR(hop)=20*log10(NormX{rlzInd}/avgRecErrNormR(hop));
    stdSNRR(hop)=20*log10(NormX{rlzInd}/stdRecErrNormR(hop));
end
GWports=avgNoMeasQNC(2);

line(avgNoMeasQNC(2:end)/nodes,avgSNRQNC(2:end),'Color','g','Marker','p','Parent',ax1); hold on;
legend(ax1,'Routing','QNC-sp=0.10','QNC-sp=0.15','QNC-sp=0.20');

%axCR=[axDelay(1)*avgNoMeasQNC(2)/bLen/nodes axDelay(2)*avgNoMeasQNC(2)/bLen/nodes axDelay(3) axDelay(4)];
axDelay=[axCR(1)/avgNoMeasQNC(2)*bLen*nodes axCR(2)/avgNoMeasQNC(2)*bLen*nodes axCR(3) axCR(4)];
axis(ax2,axDelay);
set(ax1,'fontsize',FontSize);
set(ax2,'fontsize',FontSize);

