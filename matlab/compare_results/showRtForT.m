%Main Module to show R(t) showRtForT.m

close all;
clear all;
clc;

loadFileName='resCalcRt_101_25_9_0_25';
load(loadFileName);
allResults

FontSize=13;
lw=1.5;
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Time Index (t)','fontsize',FontSize); 
ylabel('Logarithmic R(t)','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
%title(['edges=' num2str(edges)],'fontsize',FontSize);

fff = [];
for i=1:length(allResults.Rvalues)
    if(mod(i,4)==0)
        plot(log10(allResults.Rvalues{i}),'r--o','linewidth',lw);
    elseif(mod(i,4)==1)
        plot(log10(allResults.Rvalues{i}),'g--s','linewidth',lw);
    elseif(mod(i,4)==2)
        plot(log10(allResults.Rvalues{i}),'b--*','linewidth',lw);
    elseif(mod(i,4)==3)
        plot(log10(allResults.Rvalues{i}),'c--^','linewidth',lw);
    end
    
    fff = [fff;log10(allResults.Rvalues{i})];
end

h2 = plot(log10(allResults.Rvalues{i}),'k-^','linewidth',2);


xlabel('\fontfamily{cmr}Time Index $t$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
ylabel('\fontfamily{cmr}$\log_{10}(R_{\rm{network}}(t))$','fontsize',FontSize,'Interpreter','LaTex','FontName', 'Helvetica'); 
legend(h2,'Average R_{\rm{network}}(t)');