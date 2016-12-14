%Calculates Coherence of a Matrix
function res=cohMat(A);
for i=1:size(A,2)
    for j=1:size(A,2)
        coh(i,j)=(A(:,i)')*(A(:,j))/(norm(A(:,i),2)*norm(A(:,j),2));
    end
end
coh2=coh-coh.*eye(size(A,2));
res=max(max(abs(coh2)));