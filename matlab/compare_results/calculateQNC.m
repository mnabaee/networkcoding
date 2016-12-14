function [PsiTot,epsSquaredCoefs]=calculateQNC(iterations,A,F,B);
edges=size(B,2);
Psi{2}=B*A{2};
PsiTot{2}=Psi{2};
Fprod=eye(edges,edges);
for t=3:iterations+1
    Fprod=F{t}*Fprod;
    Psi{t}=B*Fprod*A{2};
    PsiTot{t}=[PsiTot{t-1};Psi{t}];
end

epsSquaredCoefs=zeros(iterations+1,1);

% fprintf(['epsRec ']);
% epsSquaredCoefs(1)=0;
% for t=2:iterations+1
%     if(t<11)
%     Calculate \underline{R}(t)
%     Fprod=eye(edges,edges);
%     sum=zeros(edges,edges);
%     for tPrime=1:t-1
%         for t2Prime=t:-1:tPrime+2
%                 Fprod=Fprod*F{t2Prime};
%         end
%         sum=sum+abs(Fprod);
%     end
%     thisPortion=1/4*ones(1,edges)*sum'*B'*B*sum*ones(edges,1);
%     else
%     thisPortion=0;
%     end
%     epsSquaredCoefs(t)=epsSquaredCoefs(t-1)+thisPortion;
%     fprintf([ num2str(t) '..']);
%    fprintf([ num2str(thisPortion) '_' num2str(t) '..']);
% end
