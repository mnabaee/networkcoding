classdef sensorMessages < handle
    properties
        Xvals
        Svals
        Qvals
        phi
        range
        gaussian
    end
    methods
        function plotMessages(sM,figH)
            figure(figH),stem(sM.Xvals);
        end
        %Function: Generates from TWO state GMM
        function sM=generateMess2Gauss(sM,nodes,sigma2x,sigma20,rho)
            sM.phi=RandOrthMat(sM,nodes);
             for i=1:nodes
               if(rand<rho)
                    sM.Qvals(i,1)=1;
                    sM.Svals(i,1)=randn*sqrt(sigma2x);                  
               else
                    sM.Qvals(i,1)=0;
                    sM.Svals(i,1)=randn*sqrt(sigma20);
               end
             end
            sM.Xvals=sM.phi*sM.Svals;
            sM.range=sigma2x*[-4 +4];
            sM.gaussian.sigma2x=sigma2x;
            sM.gaussian.sigma20=sigma20;
            sM.gaussian.rho=rho;
        end
        function sM=generateMessGeo(sM,sD);
            
        end
        function M=RandOrthMat(sM,n)
            tol=1e-6;
            M = zeros(n); % prealloc
            vi = randn(n,1);  
            M(:,1) = vi ./ norm(vi);
            for i=2:n
              nrm = 0;
              while nrm<tol
                vi = randn(n,1);
                vi = vi -  M(:,1:i-1)  * ( M(:,1:i-1).' * vi )  ;
                nrm = norm(vi);
              end
              M(:,i) = vi ./ nrm;
            end 
        end  

        
    end
end