%MATLAB Function to generate Network Coding Projection Matrix
function [P,cncP,cncPnlzd,G,H]=genNCmat(conMat,GWnode,its,nrlzdFactor);
N=length(conMat);
%Generate Conn Matrix of N^2
C=zeros(N^2,N^2);
for a=1:N^2;
for b=1:N^2;
    i=ceil(a/N);
    j=ceil(b/N);
    i2=a-(i-1)*N;
    j2=b-(j-1)*N;
    C(a,b)=conMat(i2,i)*conMat(i,j);
end
end
%disp('------ C matrix is calculated.-----');

%Calculate G
G=zeros(N^2,N);
for i=1:N
    G(i+(i-1)*N,i)=1;
end
%disp('------ G matrix is calculated.-----');

%Calculate H
m=sum(conMat(:,GWnode)>0); %Number of GW Ports
H=zeros(m,N^2);
GWconn=conMat(:,GWnode);
GWinnodes=[];
for i=1:N
    if(GWconn(i)==1)
       GWinnodes=[GWinnodes i]; 
    end
end
for i=1:m
    H(i,(GWnode-1)*N+GWinnodes(i))=1;
end
%disp('------ H matrix is calculated.-----');

%Generate random A and P;
As{1}=eye(N^2,N^2);
P{1}=H*As{1}*G;
cncP{1}=P{1};
for t=2:its
    B{t}=randn(N^2,N^2)/N;
    A{t}=B{t}.*C;
    As{t}=A{t}*As{t-1};
    P{t}=H*As{t}*G;
    cncP{t}=[cncP{t-1};P{t}];
    cncPnlzd{t}=[cncP{t-1}*nrlzdFactor;P{t}*(1-nrlzdFactor)];
%disp(['------ Iteration ' num2str(t) ' is finished.-----']);
end

