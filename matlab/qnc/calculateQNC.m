%Calculate Quantized Network Coding

function [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations ,htList,Delta,x,n,A,F,B);

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

%Calculate effective noise
sum{2}=n{2};
nEff{2}=B*sum{2};
nEffTot{2}=nEff{2};
nEffTotNorm(2)=norm(nEffTot{2},2);
for t=3:iterations+1
    sum{t}=F{t}*sum{t-1}+n{t};
    nEff{t}=B*sum{t};
    nEffTot{t}=[nEffTot{t-1};nEff{t}];
    nEffTotNorm(t)=norm(nEffTot{t},2);
end
nEff{1}=nEff{2}*0;

%Calculate noise multiplicant
oneVec=ones(edges,1);
prod=eye(edges,edges);
sumVec=oneVec'*abs(prod');
coef(2)=sumVec*(B'*B)*sumVec';
for t=3:iterations+1
    prod=F{t}*prod;
    sumVec=sumVec+oneVec'*abs(prod');
    coef(t)=sumVec*(B'*B)*sumVec';
end
epsilon=(coef.^.5)*(Delta/2);

