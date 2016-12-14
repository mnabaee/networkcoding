% L1-min for Decoding

function [xRec]=L1minDec(PsiTot,zTot,phi);
eps=10^-3;
cvx_begin quiet
    variable s(size(phi,1));
    minimize(norm(s,1));
    subject to
        norm(zTot-PsiTot*phi*s,2)<eps;
cvx_end

xRec=phi*s;
