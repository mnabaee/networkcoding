function [recXl1min,recErrNorml1min]=L1MINdecoder(zTot,PsiTot,phi,x,DeltaQ,A,F,B);
addpath(genpath('../cvx'));
iterations=length(zTot);
epsSquared(1)=0;
edges=size(F{2},1);
for t=2:iterations
    
    %Calculate epsSquared(t)
    for tZegond=1:t-1
        Fprod=eye(edges,edges);
        for t3prime=tZegond+2:t
            Fprod=F{t3prime}*Fprod;
        end
        summ=DeltaQ*ones(1,edges)*abs(Fprod);
        size(summ);
        epsSquared(t)=epsSquared(t-1)+1/4*summ*B'*B*summ';
    end
    
   
    zTotInd=zTot{t};
    PsiTotInd=PsiTot{t};
    normValNoise=epsSquared(t)^.5;
    
    cvx_begin quiet
    variable s(size(phi,1));
    minimize(norm(s,1));
    subject to
        norm(zTotInd-PsiTotInd*phi*s,2)<normValNoise;
    cvx_end
    
    recXl1min{t}=phi*s;
    recErrNorml1min(t,1)=norm(recXl1min{t}-x,1);
end
