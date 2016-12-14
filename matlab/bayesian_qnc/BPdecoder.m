%BP based Decoder for two-step Gaussian Mixture priori for One-Step QNC
function [recX,recErrNorm]=BPdecoder(x,Sdomain,zTot,PsiTot,F,A,B,phi,k,sigmaBig,sigmaQ);
addpath('../trunk/code/main');
QNCiterations=length(zTot);
n=size(phi,1);
edges=size(B,2);

for t=2:QNCiterations
    m=size(PsiTot{t},1);
    
    %Calculate Noise Model
    %%We assume independent noises at each edge and time

    for t2=2:t
        PsiN=zeros(size(B,1),(t-1)*edges);
        for t3=t2:-1:2
            if(t3==t2)
                Fprod=eye(edges);
            else
                Fprod=Fprod*F{t3+1};
            end
            %Matrix Func from t3's to t2's
            PsiN(1:size(B,1),(t3-2)*edges+1:(t3-1)*edges)=B*Fprod;
        end
        if(t2==2)
            PsiNtot=PsiN;
        else
            PsiNtot=[PsiNtot;PsiN];
        end
    end

    SigmaNtot=sigmaQ*eye(edges*(t-1));
    if(t>=4)
        SigmaNtot(edges*2+1:end,edges*2+1:end)=0;
    end
    
    SigmaNtotEff=PsiNtot*SigmaNtot*PsiNtot';
    [uN,LambdaN]=eig(SigmaNtotEff);
    
    
    thisZ=(LambdaN^.5*uN')*zTot{t};
    thisZ=zTot{t};

    thisPsi=(LambdaN^.5*uN')*PsiTot{t}*phi;
    thisPsi=PsiTot{t}*phi;
    
    %thisZ=thisPsi*Sdomain;
    
    %noise=thisZ-thisPsi*x;
    %varN=var(noise)^.5;
    

    xmean0=0;
    xvar0=sigmaBig;
    inputEst0 = AwgnEstimIn(xmean0, xvar0);
    inputEst = SparseScaEstim( inputEst0, k/n );
    wvar=sigmaQ*0;
    outputEst = AwgnEstimOut(thisZ, wvar);
    
    opt = GampOpt();
    [shat] = gampEst(inputEst, outputEst, thisPsi, opt);
    
    xhat=phi*shat;
    
    recX{t}=xhat;
    recErrNorm(t,1)=norm(xhat-x,2);
    %disp(t);
end
