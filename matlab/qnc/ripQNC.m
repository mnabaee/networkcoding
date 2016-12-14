%Analyzing RIP of order 'sp' for PsiTot

function [ratio,nlzRatio,meanRatio,ratioX]=ripQNC(nodes, iterations ,x,q,sp,Psi,PsiTot,phi);
sp=2*sp;
vRlzs=1000;
for t=2:iterations+1
    for vRlz=1:vRlzs
        v=(rand(nodes,1)-.5)*2*q;
        support=randi(nodes,round(sp*nodes),1);
        v(support)=0;
        ratio{t}(vRlz)=norm(PsiTot{t}*phi*v,2)/norm(v,2);
    end
    meanRatio(t)=mean(ratio{t});
    nlzRatio{t}=ratio{t}/meanRatio(t);
    ratioX(t)=norm(PsiTot{t}*phi'*x,2)/norm(x,2);
end


