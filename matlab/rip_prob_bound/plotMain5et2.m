%plot Tail Prob for Orthogonal and Non-orthogonal cases

close all;
clear all;
clc;

load resMain5run1-orthComp;

figure(1),hold on; grid on; 
plot(log10(mVec(3:end)),log10(tailProbGaussian(3:end)),'r-^');
plot(log10(mVec(3:end)),log10(tailProbWorst(3:end)),'b-o');


legend('Gaussian','QNC-Orthogonal-compensated');
set(gca,'fontsize',12);
title('Tail Probability vs Number of Measurements for $\epsilon = \frac{\delta_k}{\sqrt{2}}$', 'Interpreter', 'Latex','fontsize',12);
xlabel('$\log_{10}(m)$', 'Interpreter', 'Latex','fontsize',12); 
ylabel('$\log_{10}$ of Tail Probability', 'Interpreter', 'Latex','fontsize',12); 
box on;

pTailMin=[min(tailProbGaussian(3),tailProbWorst(3))];
pTailMax=[max(tailProbGaussian(end),tailProbWorst(end))];

[i2,i]=min(abs(pTailMin-tailProbWorst(3:end)));
i=i+2;
if(pTailMin<tailProbWorst(i))
    firstI=i+1;
else
    firstI=i;
end
lastI=length(tailProbWorst);

count=1;
for i=firstI:lastI
    mQNC(count)=mVec(i);
    pTail(count)=tailProbWorst(i);
    
    %Find the corresponding m_G
    [m1,m2]=min(abs(pTail(count)-tailProbGaussian));
    if(pTail(count)<tailProbGaussian(m2))
        mG(count)=mVec(m2)+(mVec(m2+1)-mVec(m2))/(tailProbGaussian(m2+1)-tailProbGaussian(m2))*(pTail(count)-tailProbGaussian(m2));
    else
        mG(count)=mVec(m2-1)+(mVec(m2)-mVec(m2-1))/(tailProbGaussian(m2)-tailProbGaussian(m2-1))*(pTail(count)-tailProbGaussian(m2-1));
    end
    
    count=count+1;
end


plot(log10(mQNC(1:end)),log10(pTail(1:end)),'g-^');
plot(log10(mG(1:end)),log10(pTail(1:end)),'k-o');

figure(2), hold on; grid on; box on;
plot(log10(mQNC(1:end)./mG(1:end)),log10(pTail(1:end)),'b-^');
ylabel('$\log_{10}(\textbf{p}_{tail})$', 'Interpreter', 'Latex','fontsize',12); 
xlabel('$\log_{10}({M_{QNC}}/{M_{G}})$', 'Interpreter', 'Latex','fontsize',12); 
set(gca,'fontsize',11);

