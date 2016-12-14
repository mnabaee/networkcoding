%plot Tail Prob for Orthogonal and Non-orthogonal cases

close all;
clear all;
clc;
format long;
load resMain6run5_1100edges.mat;

%Calculate pTail for Gaussian
omegaVec=linspace(-100,100,10^5);
omegaDel=omegaVec(2)-omegaVec(1);
for m=1:max(mVec)
    omegaVal=exp(-j*omegaVec)./(omegaVec.*(1-j*2*omegaVec/m).^(m/2));
    for deltaInd=1:length(deltaVec)
        pTailG(m,deltaInd)=real(1-1/pi*omegaDel*sum(omegaVal.*sin(omegaVec*deltaVec(deltaInd)/sqrt(2))));
    end
end

scrsz = get(0,'ScreenSize');
figure('Position',[20 20  scrsz(4)/2 scrsz(3)/3])
for deltaInd=1:length(deltaVec)
    numMeasVec=mVec(3:end);
    tailPVec=tailProbWorst(3:end,deltaInd);
    
    for mInd=1:length(numMeasVec)
        [min1,min2]=min(abs(tailPVec(mInd)-pTailG(:,deltaInd)));
        if(pTailG(min2,deltaInd)>tailPVec(mInd))
            corrM(mInd,deltaInd)=min2+1;
        else
            corrM(mInd,deltaInd)=min2;
        end
        ratioQNCtoG(mInd,deltaInd)=numMeasVec(mInd)/corrM(mInd,deltaInd);
        tailProb(mInd,deltaInd)=tailPVec(mInd);
    end

    hold on; grid on;     box on;     set(gca,'fontsize',12);
    if(deltaInd==1)
        plot(log10(ratioQNCtoG(:,deltaInd)),log10(tailProb(:,deltaInd)),'b-o');
    elseif(deltaInd==2)
        plot(log10(ratioQNCtoG(:,deltaInd)),log10(tailProb(:,deltaInd)),'r-^');
    elseif(deltaInd==3)
        plot(log10(ratioQNCtoG(:,deltaInd)),log10(tailProb(:,deltaInd)),'k-s');
    elseif(deltaInd==4)
        plot(log10(ratioQNCtoG(:,deltaInd)),log10(tailProb(:,deltaInd)),'g-*');
    elseif(deltaInd==5)
        plot(log10(ratioQNCtoG(:,deltaInd)),log10(tailProb(:,deltaInd)),'c->');
    end
    
    
%    loglog((ratioQNCtoG(:,deltaInd)),(tailProb(:,deltaInd)),'b-o');

end

legend(['\delta_k=' num2str(deltaVec(1))],['\delta_k=' num2str(deltaVec(2))],['\delta_k=' num2str(deltaVec(3))],['\delta_k=' num2str(deltaVec(4))],['\delta_k=' num2str(deltaVec(5))]);
title(['Tail Probability vs Number of Measurements for ' num2str(edges) ' edges'], 'fontsize',12);
xlabel('$\log_{10}(\frac{M_{QNC}}{M_{G}})$', 'Interpreter', 'Latex','fontsize',12); 
ylabel('$\log_{10}(\textbf{p}_{tail})$', 'Interpreter', 'Latex','fontsize',12); 
set(gcf, 'PaperPosition', [.25 2.5 8 10]);

