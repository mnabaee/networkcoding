%Calculate Quantized Network Coding

function [Psi,PsiTot]=calculateQNC(iterations,A,F,B);

%Calculate Psi(t)
sum{2}=A{2};
Psi{2}=B*sum{2};
PsiTot{2}=Psi{2};
for t=3:iterations+1
    sum{t}=F{t}*sum{t-1}+A{t};
    Psi{t}=B*sum{t};
    PsiTot{t}=[PsiTot{t-1};Psi{t}];
end
Psi{1}=Psi{2}*0;



