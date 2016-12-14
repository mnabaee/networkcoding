function res=EbarIn(mu,rho,sigma2X,sigma20)
res=rho*sigma2X+(1-rho)*sigma20;
qVec=linspace(-5*sigma2X,5*sigma2X,100);
intV=0;
%@pQ (q,mu,rho,sigma2X,sigma20)=rho*gPDF(q,sigma2X+mu)+(1-rho)*gPDF(q,sigma20+mu);
pQ = @(q,mu,rho,sigma2X,sigma20) rho*normpdf(q,0,sqrt(sigma2X+mu))+(1-rho)* normpdf(q,0,sqrt(sigma20+mu));
for qInd=1:length(qVec)
    q=qVec(qInd);
    intV=intV+q^2/pQ(q,mu,rho,sigma2X,sigma20)*(rho*sigma2X/(sigma2X+mu)*normpdf(q,0,sqrt(sigma2X+mu))+(1-rho)*sigma20/(sigma20+mu)*normpdf(q,0,sqrt(sigma20+mu)))^2;
end
intV=intV*(qVec(2)-qVec(1));
res=res-intV;