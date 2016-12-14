classdef QNCsimulation
    properties
        QNCsteps
        EdgeContent
        MeasurementTot
        MargNoise
        EffMeasNoiseTot
        MargNoiseVec
        recXl1min
        recXrbp
    end
    methods
        %Function: Performs QNC with the Given codes, messages and Q
        function QNCsim=performQNC(QNCsim,QNCcode,sM,Q,reportPrint)
            tic;
            QNCsim.QNCsteps=QNCcode.QNCsteps;
            edges=size(QNCcode.F{2},1);
            QNCsim.EdgeContent{1}=zeros(edges,1);
            QNCsim.MargNoise{1}=zeros(edges,1);
            QNCsim.MeasurementTot{1}=zeros(0,1);
            for t=1:QNCcode.QNCsteps
                Y2=QNCcode.A{t+1}*sM.Xvals+QNCcode.F{t+1}*QNCsim.EdgeContent{t};
                %QNCsim.EdgeContent{t+1}=performQ(Q,Y2); 
                QNCsim.EdgeContent{t+1}=performUQshifted(Q,Y2); 
                QNCsim.MargNoise{t+1}=QNCsim.EdgeContent{t+1}-Y2;
                QNCsim.MeasurementTot{t+1}=[QNCsim.MeasurementTot{t}; QNCcode.B*QNCsim.EdgeContent{t+1}];
            end
        if(reportPrint)
            disp([' -- QNC Simulation Report: Scenario is simulated in ' num2str(toc) ' seconds.']);
        end
        end
        %Function: Calculate Effective Total Meas Noise
        function QNCsim=calculateEffTotNoise(QNCsim,QNCcode,sM)
            for t=2:QNCcode.QNCsteps+1
                QNCsim.EffMeasNoiseTot{t}=QNCsim.MeasurementTot{t}-QNCcode.PsiTot{t}*sM.Xvals;
            end
        end
        %Function: collect marginal noises in a vector
        function QNCsim=collectNoises(QNCsim)
            QNCsim.MargNoiseVec=[];
            for t=2:QNCsim.QNCsteps+1
                QNCsim.MargNoiseVec=[QNCsim.MargNoiseVec;QNCsim.MargNoise{t}];
            end
        end
        %Function: L1min Decoding
        function QNCsim=L1minDecoder(QNCsim,QNCcode,sM,Q,reportPrint)
                    addpath(genpath('../cvx'));
            tic;            
            QNCcode=calculateEpsRec(QNCcode);
            if(reportPrint)
                disp([' -- L1MIN Decoding Report: EpsRec Coefficients are calculated in ' num2str(toc) ' seconds.']);
            end
            DeltaQ=Q.stepSize;
            tic;
            for t=2:QNCsim.QNCsteps+1
                zTotInd=QNCsim.MeasurementTot{t};
                PsiTotInd=QNCcode.PsiTot{t};
                normValNoise=(QNCcode.epsSquaredCoefs(t)^.5)*DeltaQ;

                cvx_begin quiet
                variable s(size(sM.phi,1));
                minimize(norm(s,1));
                subject to
                    norm(zTotInd-PsiTotInd*sM.phi*s,2)<=normValNoise;
                cvx_end

                QNCsim.recXl1min{t}=sM.phi*s;
            end
            if(reportPrint)
                disp([' -- L1MIN Decoding Report: Decoding is done in ' num2str(toc) ' seconds.']);
            end
        end
        %Function: Relaxed BP Decoding with Gaussian in and outs
        function QNCsim=RelaxedBPDecoderTSGMM_AWGN(QNCsim,QNCcode,sM,Q,BPsteps,reportPrint)
            rbp=RelaxedBPparams;
            rbp.printReport=reportPrint;
            rbp.RBPiterations=BPsteps;
            rbp=createRBPinputTSGMM(rbp,sM.gaussian.sigma2x,sM.gaussian.sigma20,sM.gaussian.rho,size(sM.phi,1));
            sigma2w=3.832092531972172e-007;
            %sigma2w=2.2e-005;
            for t=2:QNCsim.QNCsteps+1
                Theta=QNCcode.PsiTot{t}*sM.phi;
                %SNR0=sum(sum(Theta.^2))*(sM.gaussian.rho*sM.gaussian.sigma2x+(1-sM.gaussian.rho)*sM.gaussian.sigma20);
                %SNR0=SNR0/(sigma2w*size(Theta,1));
                %SNR0est=10*log10(SNR0)
                %SNR0=20*log10(norm(QNCsim.MeasurementTot{t},2)/norm(QNCsim.EffMeasNoiseTot{t},2))
                rbp=createRBPoutputAWGN(rbp,ones(1,length(QNCsim.MeasurementTot{t}))*sigma2w);
                res=performDecoding(rbp,QNCsim.MeasurementTot{t},Theta,sM.gaussian.sigma2x,sM.gaussian.sigma20,sM.gaussian.rho);
                for BPiter=2:length(res)
                    QNCsim.recXrbp{t,BPiter}=sM.phi*res{BPiter};
                end
                disp([' ** t= ' num2str(t) ' is done ***']);
            end
        end
        
        %Function: GAMP Decoding with Gaussian in and outs
        function QNCsim=GAMPDecoderTSGMM_AWGN(QNCsim,QNCcode,sM,Q)
            addpath('../trunk/code/main');
            warning off;
            numWdIters=20;
            DeltaQ=Q.stepSize;
            sigmaQ=DeltaQ^2*0.2;
            sigmaBig=sM.gaussian.sigma2x;
            k=round(sM.gaussian.rho*size(sM.phi,1));
            for t=2:QNCsim.QNCsteps+1
                Theta=QNCcode.PsiTot{t}*sM.phi;
                [xhat]=BPdecoder2(sM.Xvals,QNCsim.MeasurementTot{t},Theta,sM.phi,k,sigmaBig,sigmaQ,numWdIters);
                QNCsim.recXrbp{t,2}=xhat;
                disp([' ** t= ' num2str(t) ' is done ***']);
            end
        end
        
    end
end