%Test BP Class
close all;
clear all;
clc;
format long;
n=100;
beta=2;
m=round(1/beta*n);
dB=20;

%x prior: N(0,1) Two: State Mixture
rho=.2;
sigma2X=1/rho;
sigma20=sigma2X*10^-10;
for j=1:n
   S(j)=rand<rho;
   if(S(j)==1)
       x(1,j)=randn*sqrt(sigma2X);
   else
       x(1,j)=randn*sqrt(sigma20)*0;
   end
end
Psi=randn(m,n)*sqrt(1/m);
Theta=Psi;
z=Psi*x';
sigma2W=10*log10(sum(sum(Theta.^2))*(rho*sigma2X+(1-rho)*sigma20));
sigma2W=(1/n)*10^((sigma2W-dB)/10);
for i=1:m
    N(i)=randn*sqrt(sigma2W);
    y(i)=z(i)+N(i);
end
iters=20;
%Define Functions
EbarOutI=inline('mu+sigma2Ni','mu','sigma2Ni');

%Guarantees
muZ(1)=beta*(rho*sigma2X+(1-rho)*sigma20);
for t=1:iters
    muQ(t)=EbarOutI(muZ(t),sigma2W);
    muZ(t+1)=beta*EbarIn(muQ(t),rho,sigma2X,sigma20);
    muX(t+1)=EbarIn(muQ(t),rho,sigma2X,sigma20);
    estErrNorm(t+1)=muX(t+1)*n;
    snrEst(t+1)=10*log10((rho*sigma2X+(1-rho)*sigma20)*n/estErrNorm(t+1));
end

SNR0est=10*log10(sum(sum(Theta.^2))*(rho*sigma2X+(1-rho)*sigma20)/(n*sigma2W))
SNR0=10*log10(norm(z,2)^2/norm(N)^2)

rbp=RelaxedBPparams;
rbp.printReport=1;
rbp.RBPiterations=iters;
rbp=createRBPinputTSGMM(rbp,sigma2X,sigma20,rho,n);
rbp=createRBPoutputAWGN(rbp,[1:m]*sigma2W);

res=performDecoding(rbp,y',Theta,sigma2X,sigma20,rho);

for i=2:rbp.RBPiterations+1
snr(i)=20*log10(norm(x,2)/norm(x-res{i}',2));
end
plot(snr,'r'); grid on; hold on;
plot(snrEst,'b'); legend('decoded','estimated');