%plot Tail Prob for Orthogonal and Non-orthogonal cases

close all;
clear all;
clc;

load resMain5run1-orthComp;

figure(1),hold on; grid on; xlabel('log_{10}(m)','fontsize',12); ylabel('Log_{10} of Tail Probability','fontsize',12); box on;
plot(log10(mVec(3:end)),log10(tailProbGaussian(3:end)),'r-^');
plot(log10(mVec(3:end)),log10(tailProbWorst(3:end)),'b-o');

load resMain4run6-orthNcomp;
plot(log10(mVec(3:end)),log10(tailProbWorst(3:end)),'c->');

load resMain5run2-NorthComp;
plot(log10(mVec(3:end)),log10(tailProbWorst(3:end)),'g-s');

legend('Gaussian','QNC-Orthogonal-compensated','QNC-Orthogonal-NotCompensated','QNC-NonOrthogonal-compensated');
set(gca,'fontsize',12);
title('Tail Probability vs Number of Measurements for \epsilon = 0.2928','fontsize',12);

load resMain5run1-orthComp;

figure(2),hold on; grid on; xlabel('log_{10}(m)','fontsize',12); ylabel('Log_{10} of Tail Probability','fontsize',12); box on;
loglog((mVec(3:end)),(tailProbGaussian(3:end)),'r-^');
loglog((mVec(3:end)),(tailProbWorst(3:end)),'b-o');

load resMain4run6-orthNcomp;
loglog((mVec(3:end)),(tailProbWorst(3:end)),'c->');

load resMain5run2-NorthComp;
loglog((mVec(3:end)),(tailProbWorst(3:end)),'g-s');

legend('Gaussian','QNC-Orthogonal-compensated','QNC-Orthogonal-NotCompensated','QNC-NonOrthogonal-compensated');
set(gca,'fontsize',12);
title('Tail Probability vs Number of Measurements for \epsilon = 0.2928','fontsize',12);

