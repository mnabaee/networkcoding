%Generate Sparse Messages with 2-step Mixture Gaussian Prior's
function [x,phi,xNorm,Sdomain,SdomainSupport]=GenMess(nodes,htList,phiSparsityOrder,k,xRange,sigmaBig);
edges=size(htList,1);

Srandperm=randperm(nodes);
Srandperm=Srandperm(1:k);
SdomainSupport=zeros(nodes,1);
SdomainSupport(Srandperm)=1;

for i=1:nodes
    if(SdomainSupport(i)==1)
        Sdomain(i,1)=randn*sigmaBig;
    else
        Sdomain(i,1)=0;
    end
end

%Generate phi
if(phiSparsityOrder==0)
    %phi=I
    phi=eye(nodes);
    
elseif(phiSparsityOrder==-1)
    phi=RandOrthMat(nodes);
else
    permut=randperm(nodes);
    count=0;
    while(count<=nodes)
        if(count+1+phiSparsityOrder>nodes)
            thisNodes=permut(count+1:end);
        else
            thisNodes=permut(count+1:count+1+phiSparsityOrder);
            
        end
        thisRandProj=RandOrthMat(length(thisNodes));
        for i=1:length(thisNodes)
            for j=1:length(thisNodes)
                phi(thisNodes(i),thisNodes(j))=thisRandProj(i,j);
            end
        end
        count=count+1+phiSparsityOrder;
    end
    phi=eye(nodes);
end

x=phi*Sdomain;

% for v=1:length(x)
%     if(abs(x(v))>xRange)
%         x(v)=sign(x(v))*xRange;
%     end
% end
xNorm=norm(x,2);
