function [zTot,n]=simulateQNC(iterations,Delta,x,A,F,B);
edges=size(F{3},1);
y{1}=zeros(edges,1); y2{1}=y{1};
for t=2:iterations+1
    if(t==2)
        y2{t}=A{2}*x;
    else
        y2{t}=F{t}*y{t-1};
    end
    y{t}=round(y2{t}/Delta)*Delta;
    n{t}=y{t}-y2{t};
    z{t}=B*y{t};
    if(t==2)
       zTot{t}=z{t}; 
    else
        zTot{t}=[zTot{t-1};z{t}];
    end
end

