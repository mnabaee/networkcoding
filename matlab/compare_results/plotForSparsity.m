%plotForSparsity: Filtering Data and Plotting the Results

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

% t_s = [30,35];
% b_s = [25,15];
t_s = [35];
b_s = [15];

scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('\fontfamily{cmr}Sparsity Factor $k/n$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
ylabel('\fontfamily{cmr}Average $|| \underline{x} - \underline{\hat{x}}_{\rm{QNC}}(t) ||^2_{\ell_2}$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
%ylabel('Average Norm of Recovery Error','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
%title(['edges=' num2str(edges) ', t=' num2str(t) ', L=' num2str(bLenVec(blInd))],'fontsize',FontSize);
for uu=1:length(t_s)
   
t=30;
blInd=25;
t=t_s(uu);
blInd=b_s(uu);
forSpXvec=[]; forSpYvec=[];
for spInd=1:length(spVec)
    forSpXvec(spInd)=spVec(spInd);
    forSpYvec(spInd)=MeanRecErrNormQNC(t,spInd,epsKind,blInd);
end

if(uu==1)
    ps = 'r-^';
elseif(uu==2)
    ps='b-o';
elseif(uu==3)
    ps='k-s';
elseif(uu==4)
    ps='b-o';
elseif(uu==5)
    ps='b-o';
end
plot(forSpXvec,(forSpYvec),ps,'linewidth',lw);
disp(['edges=' num2str(edges) ', t=' num2str(t) ', L=' num2str(bLenVec(blInd))]);

end

