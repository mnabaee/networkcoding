%plotForEdges: Filtering Data and Plotting the Results

close all;
clear all;
clc;

FileName{1}='resMain2Run101-35-9-85-95';
FileName{2}='resMain2Run101-25-9-85-95';
FileName{3}='resMain2Run101-15-9-85-95';

% FileName{1}='resMain2Run101-35-9-0-25';
% FileName{2}='resMain2Run101-25-9-0-25';
% FileName{3}='resMain2Run101-15-9-0-25';

FontSize=13;
lw=1.5;
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Time Index ( t )','fontsize',FontSize); 
ylabel('Logarithmic Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;

%semilogx(fortXvec(2:end),fortYvec(2:end),'r-o','linewidth',lw);

for fNameIndx=1:3
    
    load(FileName{fNameIndx});
    edgesVec{fNameIndx}=edges;
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
        MeanSNRQNC{fNameIndx}(t,spInd,epsKind,blInd)=20*log10(avgXnorm)-20*log10(median(dataFiltered));
        MeanRecErrNormQNC{fNameIndx}(t,spInd,epsKind,blInd)=median(dataFiltered.^2);
        DelDelayQNC{fNameIndx}(t,spInd,epsKind,blInd)=bLenVec(blInd)*(t-1);
    end
    end
    end

    spInd=1;
    blInd=25;
    forBlXvec=[]; forBlYvec=[];
    for t=2:size(MeanRecErrNormQNC{fNameIndx},1)
        forEdgesXvec(t)=(t);
        forEdgesYvec(t)=log10(MeanRecErrNormQNC{fNameIndx}(t,spInd,epsKind,blInd));
    end
    if(fNameIndx==1)
        plot(forEdgesXvec(2:end),forEdgesYvec(2:end),'b-s','linewidth',lw);
    elseif(fNameIndx==2)
        plot(forEdgesXvec(2:end),forEdgesYvec(2:end),'r-o','linewidth',lw);
    elseif(fNameIndx==3)
        plot(forEdgesXvec(2:end),forEdgesYvec(2:end),'g-d','linewidth',lw);
    end
    
end
legend(['edges=' num2str(edgesVec{1})],['edges=' num2str(edgesVec{2})],['edges=' num2str(edgesVec{3})]);
title(['bLen=' num2str(bLenVec(blInd)) ', k/n=' num2str(spVec(spInd))],'fontsize',FontSize);

%Figure2
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Number of Edges','fontsize',FontSize); 
ylabel('Logarithmic Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
epsKind=1;

spInd=1;
blInd=25;
t=10;
for edgeIndx=1:length(MeanRecErrNormQNC)
    forEdges2x(edgeIndx)=edgesVec{edgeIndx};
    forEdges2y(edgeIndx)=log10(MeanRecErrNormQNC{edgeIndx}(t,spInd,epsKind,blInd));
end
plot(forEdges2x,forEdges2y,'r-o','linewidth',lw);
legendSt1=['k/n=' num2str(spVec(spInd)) ', bLen=' num2str(bLenVec(blInd)) ', t=' num2str(t)];

spInd=1;
blInd=15;
t=10;
for edgeIndx=1:length(MeanRecErrNormQNC)
    forEdges2x(edgeIndx)=edgesVec{edgeIndx};
    forEdges2y(edgeIndx)=log10(MeanRecErrNormQNC{edgeIndx}(t,spInd,epsKind,blInd));
end
plot(forEdges2x,forEdges2y,'b-s','linewidth',lw);
legendSt2=['k/n=' num2str(spVec(spInd)) ', bLen=' num2str(bLenVec(blInd)) ', t=' num2str(t)];

spInd=1;
blInd=25;
t=30;
for edgeIndx=1:length(MeanRecErrNormQNC)
    forEdges2x(edgeIndx)=edgesVec{edgeIndx};
    forEdges2y(edgeIndx)=log10(MeanRecErrNormQNC{edgeIndx}(t,spInd,epsKind,blInd));
end
plot(forEdges2x,forEdges2y,'g-^','linewidth',lw);
legendSt3=['k/n=' num2str(spVec(spInd)) ', bLen=' num2str(bLenVec(blInd)) ', t=' num2str(t)];

spInd=1;
blInd=15;
t=30;
for edgeIndx=1:length(MeanRecErrNormQNC)
    forEdges2x(edgeIndx)=edgesVec{edgeIndx};
    forEdges2y(edgeIndx)=log10(MeanRecErrNormQNC{edgeIndx}(t,spInd,epsKind,blInd));
end
plot(forEdges2x,forEdges2y,'k-d','linewidth',lw);
legendSt4=['k/n=' num2str(spVec(spInd)) ', bLen=' num2str(bLenVec(blInd)) ', t=' num2str(t)];
legend(legendSt1,legendSt2,legendSt3,legendSt4);
%title('GW_{corner}','fontsize',FontSize);

xlabel('\fontfamily{cmr}Number of Edges $|\mathcal{E}|$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
ylabel('\fontfamily{cmr}Average $\log_{10}(|| \underline{x} - \underline{\hat{x}}_{\rm{QNC}}(t) ||^2_{\ell_2})$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 