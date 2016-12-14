%Analyzing RIP of order 'sp' for PsiTot

function [coh,cohTot]=coherenceQNC(iterations ,Psi,PsiTot);
for t=2:iterations+1
    coh(t)=cohMat(Psi{t});
    cohTot(t)=cohMat(PsiTot{t});
end
