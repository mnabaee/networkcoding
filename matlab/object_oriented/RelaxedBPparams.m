classdef RelaxedBPparams
    properties
        RBPiterations
        Fin
        Ein
        xHatj
        muXj
        D12
        D2inv
        printReport
        pQ
        
        ratio1x
        ratio10
        ratio2x
        ratio20
        ratio3x
        ratio30
        nX
        n0
        nXln
        n0ln
        
        matCond1
        matCond2
        matCond3
    end
    methods
        %Function: Create RBP input functions for two-state GMM
        function RBP=createRBPinputTSGMM(RBP,sigma2x,sigma20,rho,n)
            rTH=10^-15;
            rounder=@(in) ((abs(in)>=rTH).*in+(abs(in)<rTH)*rTH) ;
            %rounder=@(in) (in);
            %RBP.pQ=@(q,mu) (rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu)));
            %intX2et1=@(q,mu,sigma2) normpdf(q,0,sqrt(sigma2+mu)).*sigma2.*(sigma2*(q.^2+mu)+mu.^2)./((sigma2+mu).^2);
            for j=1:1%n
                RBP.ratio1x=@(q,mu) (sigma2x.*q./(sigma2x+mu));
                RBP.ratio10=@(q,mu) (sigma20.*q./(sigma20+mu));
                RBP.ratio3x=@(q,mu) sigma2x*(sigma2x*(q.^2+mu)+mu.^2)./((sigma2x+mu).^2);
                RBP.ratio30=@(q,mu) sigma20*(sigma20*(q.^2+mu)+mu.^2)./((sigma20+mu).^2);
                
                RBP.nX = @(q,mu) rho*normpdf(q,0,sqrt(sigma2x+mu));
                RBP.n0 = @(q,mu) (1-rho)*normpdf(q,0,sqrt(sigma20+mu));
                RBP.nXln= @(q,mu) log(rho)-.5*log(2*pi*(sigma2x+mu))-q.^2./2./(sigma2x+mu);
                RBP.n0ln= @(q,mu) log(1-rho)-.5*log(2*pi*(sigma20+mu))-q.^2./2./(sigma20+mu);
                
                diffTH=100*log(10)*1;
                
                RBP.matCond1=@(q,mu) RBP.nXln(q,mu)>RBP.n0ln(q,mu)+diffTH;
                RBP.matCond2=@(q,mu) RBP.n0ln(q,mu)>RBP.nXln(q,mu)+diffTH;
                RBP.matCond3=@(q,mu) (~RBP.matCond1(q,mu))&(~RBP.matCond2(q,mu));
                
%                 RBP.ratio2x(matCond1(q,mu))=@(q,mu) 1;
%                 RBP.ratio2x(matCond2(q,mu))=@(q,mu) 0;
%                 RBP.ratio2x(matCond3(q,mu))=@(q,mu) (rho.*normpdf(q,0,sqrt(sigma2x+mu))./(rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu))));
                
                RBP.ratio2x = @(q,mu) exp(RBP.nXln(q,mu)-max(RBP.nXln(q,mu),RBP.nXln(q,mu)));
                
                
                %RBP.ratio2x=@(q,mu) (RBP.nXln(q,mu)>RBP.n0ln(q,mu)+diffTH).*1+(RBP.n0ln(q,mu)>RBP.nXln(q,mu)+diffTH).*0+(RBP.nXln(q,mu)>RBP.n0ln(q,mu)-diffTH).*(RBP.nXln(q,mu)<RBP.n0ln(q,mu)+diffTH).*(rho.*normpdf(q,0,sqrt(sigma2x+mu))./(rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu))));
                %RBP.ratio20=@(q,mu) (RBP.n0ln(q,mu)>RBP.nXln(q,mu)+diffTH).*1+(RBP.nXln(q,mu)>RBP.n0ln(q,mu)+diffTH).*0;%+(RBP.n0ln(q,mu)>RBP.nXln(q,mu)-diffTH).*(RBP.n0ln(q,mu)<RBP.nXln(q,mu)+diffTH).*((1-rho).*normpdf(q,0,sqrt(sigma20+mu))./(rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu))));
                RBP.ratio20=@(q,mu) 1-RBP.ratio2x(q,mu);
                
                %RBP.ratio2x=@(q,mu) (rho.*normpdf(q,0,sqrt(sigma2x+mu))./(rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu))));
                %RBP.ratio20=@(q,mu) ((1-rho).*normpdf(q,0,sqrt(sigma20+mu))./(rho.*normpdf(q,0,sqrt(sigma2x+mu))+(1-rho).*normpdf(q,0,sqrt(sigma20+mu))));

                RBP.Fin{j}=@(q,mu) RBP.ratio1x(q,mu).*RBP.ratio2x(q,mu)+RBP.ratio10(q,mu).*RBP.ratio20(q,mu);
                
                RBP.Ein{j}=@(q,mu) RBP.ratio2x(q,mu) .* RBP.ratio3x(q,mu)+RBP.ratio20(q,mu) .* RBP.ratio30(q,mu)-(RBP.Fin{j}(q,mu)).^2;
                
                %RBP.Fin{j}=@(q,mu) (rho.*normpdf(q,0,sqrt(sigma2x+mu)).*sigma2x.*q./(sigma2x+mu)+(1-rho).*normpdf(q,0,sqrt(sigma20+mu)).*sigma20.*q./(sigma20+mu))./rounder(RBP.pQ(q,mu));
                %RBP.Ein{j}=@(q,mu) (rho.*intX2et1(q,mu,sigma2x)+(1-rho).*intX2et1(q,mu,sigma20))./rounder(RBP.pQ(q,mu))-(RBP.Fin{j}(q,mu)).^2;
            end
            for j=1:n
                RBP.xHatj(j)=0;
                RBP.muXj(j)=rho.*sigma2x+(1-rho).*sigma20;                
            end
        end
        %Function: Create RBP output functions for AWGN
        function RBP=createRBPoutputAWGN(RBP,sigma2Ni)
            for i=1:1%length(sigma2Ni)
                RBP.D12{i}=@(y,zHat,mu) (repmat(y,[1,1,size(zHat,3)])-zHat);
                RBP.D2inv{i}=@(y,zHat,mu) (mu+sigma2Ni(i));
            end
        end
        %----------------------------------------------
        %Function: Perform Decoding
        function recX=performDecoding(RBP,meas,Theta,sigma2x,sigma20,rho)
            tic;
            m=size(Theta,1);
            n=size(Theta,2);
            if(length(meas)~=m)
               error('Size Mismatch...'); 
            end
            xHatjToi=zeros(RBP.RBPiterations+1,m,n);
            muXjToi=zeros(RBP.RBPiterations+1,m,n);
            zHati=zeros(RBP.RBPiterations+1,m,1);
            muZi=zeros(RBP.RBPiterations+1,m,1);
            zHatiToj=zeros(RBP.RBPiterations+1,m,n);
            muZiToj=zeros(RBP.RBPiterations+1,m,n);
            uHatiToj=zeros(RBP.RBPiterations+1,m,n);
            muUiToj=zeros(RBP.RBPiterations+1,m,n);
            muQjToi=zeros(RBP.RBPiterations+1,m,n);
            qHatjToi=zeros(RBP.RBPiterations+1,m,n);
            muQj=zeros(RBP.RBPiterations+1,1,n);
            qHatj=zeros(RBP.RBPiterations+1,1,n);
            xHatjToi=zeros(RBP.RBPiterations+1,m,n);
            muXjToi=zeros(RBP.RBPiterations+1,m,n);
            xHatj=zeros(RBP.RBPiterations+1,1,n);
            muXj=zeros(RBP.RBPiterations+1,1,n);
            Theta2=zeros(1,size(Theta,1),size(Theta,2));
            Theta2(1,:,:)=Theta;
%             meas2=zeros(1,size(Theta,1),size(Theta,2));
%             meas2(1,:,:)=repmat(meas,1,size(Theta,2));
            meas=meas';

            t=1;
            %Step 1
            for j=1:n
                xHatjToi(t,1:m,j)=RBP.xHatj(j);
                muXjToi(t,1:m,j)=RBP.muXj(j);
            end
            if(RBP.printReport)
                disp([' -- BP Decoding Report: BP Preparation is done in ' num2str(toc) ' seconds.']);
            end
            while(t<=RBP.RBPiterations)
                tic;
                %Step 2
%                 disp('xHatjToi');  disp(sum(sum(isnan(xHatjToi(t,:,:)))));
%                 disp('muXjToi');  disp(sum(sum(isnan(muXjToi(t,:,:)))));
                
                %disp('Theta2'); disp(sum(sum(sum(isnan(xHatjToi(t,:,:))))));
                %disp('Theta2'); disp(sum(sum(sum(isnan(Theta2)))));
                    zHati(t,:,1)=sum(Theta2(1,:,:).*xHatjToi(t,:,:),3);
                    muZi(t,:,1)=sum((Theta2(1,:,:).^2).*muXjToi(t,:,:),3);
                    zHatiToj(t,:,:)=repmat(zHati(t,:,1),[1,1,n])-Theta2(1,:,:).*xHatjToi(t,:,:);
                    muZiToj(t,:,:)=repmat(muZi(t,:,1),[1,1,n])-(Theta2(1,:,:).^2).*muXjToi(t,:,:);
                %Step 3 %%REFINE FOR DIFFERNET i's
%                 disp('zHati');  disp(sum(sum(isnan(zHati(t,:,:)))));
%                 disp('muZi');  disp(sum(sum(isnan(muZi(t,:,:)))));
%                 disp('zHatiToj');  disp(sum(sum(isnan(zHatiToj(t,:,:)))));
%                 disp('muZiToj');  disp(sum(sum(isnan(muZiToj(t,:,:)))));
                    uHatiToj(t,:,:)=RBP.D12{1}(meas,zHatiToj(t,:,:),muZiToj(t,:,:));
                    muUiToj(t,:,:)=RBP.D2inv{1}(meas,zHatiToj(t,:,:),muZiToj(t,:,:));
                %Step 4
%                  disp('muUiToj');  disp(sum(sum(isnan(muUiToj(t,:,:)))));
%                   disp('uHatiToj');  disp(sum(sum(isnan(uHatiToj(t,:,:)))));
                      muQjToi(t,:,:)=1./(repmat(sum((Theta2(1,:,:).^2)./muUiToj(t,:,:),2),[1,m,1])-(Theta2(1,:,:).^2)./muUiToj(t,:,:));
                      qHatjToi(t,:,:)=muQjToi(t,:,:) .* (repmat(sum(Theta2(1,:,:).*uHatiToj(t,:,:)./muUiToj(t,:,:),2),[1,m,1])-Theta2(1,:,:).*uHatiToj(t,:,:)./muUiToj(t,:,:));
                      muQj(t,1,:)=1./(sum((Theta2(1,:,:).^2)./muUiToj(t,:,:),2));
                      qHatj(t,1,:)=muQj(t,1,:) .* (sum(Theta2(1,:,:).*uHatiToj(t,:,:)./muUiToj(t,:,:),2));
                %Step 5 %%REFINE FOR DIFFERNET j's
%                 disp('qHatjToi');  disp(sum(sum(isnan(qHatjToi(t,:,:)))));
%                 disp('muQjToi');  disp(sum(sum(isnan(muQjToi(t,:,:)))));
%                 disp('qHatj');  disp(sum(sum(isnan(qHatj(t,:,:)))));
%                 disp('muQj');  disp(sum(sum(isnan(muQj(t,:,:)))));
                
                rat2x=zeros(size(RBP.matCond1(qHatjToi(t,:,:),muQjToi(t,:,:))));
                rat2x(RBP.matCond1(qHatjToi(t,:,:),muQjToi(t,:,:)))= 1;
                rat2x(RBP.matCond2(qHatjToi(t,:,:),muQjToi(t,:,:)))= 0;
                bBuf=(rho.*normpdf(qHatjToi(t,:,:),0,sqrt(sigma2x+muQjToi(t,:,:)))./(rho.*normpdf(qHatjToi(t,:,:),0,sqrt(sigma2x+muQjToi(t,:,:)))+(1-rho).*normpdf(qHatjToi(t,:,:),0,sqrt(sigma20+muQjToi(t,:,:)))));
                vbuf=RBP.matCond3(qHatjToi(t,:,:),muQjToi(t,:,:));
                
                for i1=1:size(bBuf,2);
                    for i2=1:size(bBuf,3)
                        if(vbuf(1,i1,i2)==1)
                            rat2x(1,i1,i2)=bBuf(1,i1,i2);
                        end
                    end
                end
                
                rat20=1-rat2x;
                
                    xHatjToi(t+1,:,:)=RBP.ratio1x(qHatjToi(t,:,:),muQjToi(t,:,:)).*rat2x+RBP.ratio10(qHatjToi(t,:,:),muQjToi(t,:,:)).*rat20;
                    muXjToi(t+1,:,:)=rat2x .* RBP.ratio3x(qHatjToi(t,:,:),muQjToi(t,:,:))+rat20 .* RBP.ratio30(qHatjToi(t,:,:),muQjToi(t,:,:))-(xHatjToi(t+1,:,:)).^2;
                
                    
                rat2x=zeros(size(RBP.matCond1(qHatj(t,1,:),muQj(t,1,:))));
                rat2x(RBP.matCond1(qHatj(t,1,:),muQj(t,1,:)))= 1;
                rat2x(RBP.matCond2(qHatj(t,1,:),muQj(t,1,:)))= 0;
                bBuf=(rho.*normpdf(qHatj(t,1,:),0,sqrt(sigma2x+muQj(t,1,:)))./(rho.*normpdf(qHatj(t,1,:),0,sqrt(sigma2x+muQj(t,1,:)))+(1-rho).*normpdf(qHatj(t,1,:),0,sqrt(sigma20+muQj(t,1,:)))));
                vbuf=RBP.matCond3(qHatj(t,1,:),muQj(t,1,:));
                for i1=1:size(bBuf,2);
                    for i2=1:size(bBuf,3)
                        if(vbuf(1,i1,i2)==1)
                            rat2x(1,i1,i2)=bBuf(1,i1,i2);
                        end
                    end
                end
                
                %rat2x(RBP.matCond3(qHatj(t,1,:),muQj(t,1,:)))= 
                rat20=1-rat2x;
                
                    xHatj(t+1,1,:)=RBP.ratio1x(qHatj(t,1,:),muQj(t,1,:)).*rat2x+RBP.ratio10(qHatj(t,1,:),muQj(t,1,:)).*rat20;
                    muXj(t+1,1,:)=rat2x .* RBP.ratio3x(qHatj(t,1,:),muQj(t,1,:))+rat20 .* RBP.ratio30(qHatj(t,1,:),muQj(t,1,:))-(xHatj(t+1,1,:)).^2;
                    
                      %xHatjToi(t+1,:,:)=RBP.Fin{1}(qHatjToi(t,:,:),muQjToi(t,:,:));
                      %muXjToi(t+1,:,:)=RBP.Ein{1}(qHatjToi(t,:,:),muQjToi(t,:,:)); 
                      %xHatj(t+1,1,:)=RBP.Fin{1}(qHatj(t,1,:),muQj(t,1,:)); 
                      %muXj(t+1,1,:)=RBP.Ein{1}(qHatj(t,1,:),muQj(t,1,:)); 
                      
%                       disp('nX');disp(min(min(((RBP.nX(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('n0');disp(min(min(((RBP.n0(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       
%                       disp('1x');disp(sum(sum(isnan((RBP.ratio1x(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('2x');disp(sum(sum(isnan((RBP.ratio2x(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('3x');disp(sum(sum(isnan((RBP.ratio3x(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('10');disp(sum(sum(isnan((RBP.ratio10(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('20');disp(sum(sum(isnan((RBP.ratio20(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
%                       disp('30');disp(sum(sum(isnan((RBP.ratio30(qHatjToi(t,:,:),muQjToi(t,:,:)))))));
                      
                       disp('xHatjToi');disp(sum(sum(sum(isnan(xHatjToi)))));
                       disp('muXjToi');disp(sum(sum(sum(isnan(muXjToi)))));
                       disp('xHatj');disp(sum(sum(sum(isnan(xHatj)))));
                       disp('muXj');disp(sum(sum(sum(isnan(muXj)))));

%                       GGG=RBP.pQ(qHatjToi(t,:,:),muQjToi(t,:,:));
%                 if((sum(sum(sum(~isfinite([xHatjToi(t+1,:,:)]))))>0))
%                     min(min(min(abs(qHatjToi(t,:,:)))))
%                     min(min(min(abs(muQjToi(t,:,:)))))
%                     save('FU2','xHatjToi','GGG');
%                     error('NANNed5') ;
%                 end
                %Return to Step 2
                recX{t+1}=reshape(xHatj(t+1,1,:),n,1);
%                 disp('recX'); disp(sum(isnan(recX{t+1})));
                if(RBP.printReport)
                    disp([' -- BP Decoding Report: BP iteration ' num2str(t) '/' num2str(RBP.RBPiterations) ' is done in ' num2str(toc) ' seconds.']);
                end
                t=t+1;
            end
        end
    end
end


