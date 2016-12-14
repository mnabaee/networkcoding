function [recErrNorml1min,recXl1min]=L1MINdecoder(zTot,PsiTot,phi,x,DeltaQ,epsSquaredCoefs,edges);
iterations=length(zTot);
for t=2:iterations
    
    zTotInd=zTot{t};
    ThetaTot=PsiTot{t}*phi;
    normValNoise=(epsSquaredCoefs(t)^.5)*DeltaQ;
    
    %normValNoise=norm(zTotInd-PsiTotInd*x,2);
    %noiseNorm(t)=norm(zTotInd-PsiTotInd*x,2);
    
    cvx_begin quiet
    variable s(size(phi,1));
    minimize(norm(s,1));
    subject to
        norm(zTotInd-ThetaTot*s,2)<=normValNoise;
    cvx_end
    
    recXl1min{t}=phi*s;
    
    clear s;
    
    recErrNorml1min(t,1)=norm(recXl1min{t}-x,2);
end
