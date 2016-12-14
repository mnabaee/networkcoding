classdef simEval
    properties
        recErrNormL1MIN
        recErrNormRelaxedBP
        snrL1MIN
        snrRelaxedBP
    end
    methods
        %Function: Calculates Err Norm of L1min Decoding Result
        function simEval=calculateErrL1MIN(simEval,QNCsim,sM);
            for t=2:QNCsim.QNCsteps+1
                simEval.recErrNormL1MIN(t)=norm(sM.Xvals-QNCsim.recXl1min{t},2);
                simEval.snrL1MIN(t)=20*log10(norm(sM.Xvals,2)/simEval.recErrNormL1MIN(t));
            end
        end
        %Function: Calculates Err Norm of RBP Decoding Result
        function simEval=calculateErrRBP(simEval,QNCsim,sM);
            for t=2:QNCsim.QNCsteps+1
                for BPiter=2:size(QNCsim.recXrbp,2)
                    simEval.recErrNormRelaxedBP(t,BPiter)=norm(sM.Xvals-QNCsim.recXrbp{t,BPiter},2);
                    simEval.snrRelaxedBP(t,BPiter)=20*log10(norm(sM.Xvals,2)/simEval.recErrNormRelaxedBP(t,BPiter));
                end
            end
        end
    end
end