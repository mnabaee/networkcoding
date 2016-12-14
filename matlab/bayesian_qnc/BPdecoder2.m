%BP based Decoder for two-step Gaussian Mixture priori for One-Step QNC
function [recX,recErrNorm,recErrNormWindow]=BPdecoder2(x,Sdomain,zTot,PsiTot,F,A,B,phi,k,sigmaBig,sigmaQ,numWdIters);
addpath('../trunk/code/main');
QNCiterations=length(zTot);
n=size(phi,1);
edges=size(B,2);

for t=2:QNCiterations
    
    windowVals=round(linspace(1,size(PsiTot{t},1),numWdIters));

    
    for windowIndx=1:length(windowVals)
        wd=windowVals(windowIndx);
        
    
    thisZ=zTot{t}(wd:end,:);

    thisPsi=PsiTot{t}(wd:end,:)*phi;
    
    xmean0=0;
    xvar0=sigmaBig;
    inputEst0 = AwgnEstimIn(xmean0, xvar0);
    inputEst = SparseScaEstim( inputEst0, k/n );
    wvar=sigmaQ*0;
    outputEst = AwgnEstimOut(thisZ, wvar);
    
    opt = GampOpt();
    opt.nit=40;
    [shat] = gampEst(inputEst, outputEst, thisPsi, opt);
    
    xhatWindow{windowIndx}=phi*shat;
    recErrNormWindow(t,windowIndx)=norm(xhatWindow{windowIndx}-x,2);
    end
    
    [mm1,mm2]=min(recErrNormWindow(t,:));
    
    recX{t}=xhatWindow{mm2};
    recErrNorm(t,1)=mm1;
   
end
