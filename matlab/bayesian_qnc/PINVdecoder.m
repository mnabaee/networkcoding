function [recXPinv,recErrNormPinv]=PINVdecoder(zTot,PsiTot,phi,x);
iterations=length(zTot);
for t=2:iterations
    recXPinv{t}=pinv(PsiTot{t}*phi)*zTot{t};
    recErrNormPinv(t)=norm(recXPinv{t}-x,1);
end