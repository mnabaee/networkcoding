% P-inv Decoder

function [recErrNorm,xRec]=pInvDec(PsiTot,zTot,x);

for t=2:length(zTot)
    zTotInd=zTot{t};
    PsiTotInd=PsiTot{t};
    
    xRec{t}=pinv(PsiTot{t})*zTot{t};
    
    recErrNorm(t)=norm(x-xRec{t},2);
end
