%BP based Decoder for two-step Gaussian Mixture priori for One-Step QNC
%function [recX,recErrNorm,recErrNormWindow]=BPdecoder2(x,thisZ,thisTheta,k,sigmaBig,sigmaQ,numWdIters);
function [xhat,shat,recErrNormWindow]=BPdecoder2(x,thisZ,thisTheta,phi,k,sigmaBig,sigmaQ,numWdIters);
n=size(phi,1);
    windowVals=round(linspace(1,size(thisTheta,1),numWdIters));
    for windowIndx=1:length(windowVals)
        wd=windowVals(windowIndx);
    xmean0=0;
    xvar0=sigmaBig;
    inputEst0 = AwgnEstimIn(xmean0, xvar0);
    inputEst = SparseScaEstim( inputEst0, k/n );
    wvar=sigmaQ*0;
    outputEst = AwgnEstimOut(thisZ, wvar);
    
    opt = GampOpt();
    opt.nit=40;
    [shat] = gampEst(inputEst, outputEst, thisTheta, opt);
    
    xhatWindow{windowIndx}=phi*shat;
    recErrNormWindow(windowIndx)=norm(xhatWindow{windowIndx}-x,2);
    end
    [mm1,mm2]=min(recErrNormWindow(:));
    xhat=xhatWindow{mm2};
   
