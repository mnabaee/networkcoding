% L1-min for Decoding

function [recErrNorm,numMeas,xRec]=L1minDec(PsiTot,zTot,phi,x);
eps=10^-3;
for t=2:length(zTot)
    zTotInd=zTot{t};
    PsiTotInd=PsiTot{t};
    
    normValNoise=norm(zTotInd-PsiTotInd*x,2);
    
    cvx_begin quiet
    variable s(size(phi,1));
    minimize(norm(s,1));
    subject to
        norm(zTotInd-PsiTotInd*phi*s,2)<normValNoise;
    cvx_end
    xRec{t}=phi*s;
    
    recErrNorm(t)=norm(x-xRec{t},2);
    numMeas(t)=length(zTot{t});
end




