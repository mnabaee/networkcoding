% Optimality Test for vector choice of tail probability

close all;
clear all;
clc;

load resMain5run4;

tailProbWorstVec

%Reference Vector 
refVecInd=54;

%Calculate cos(angle) of all vectors with 
for vInd=1:size(randVecs,1)
    corrRef(vInd)=sum(randVecs(vInd,:).*randVecs(refVecInd,:));
end

t=20;
plot(corrRef,tailProbV(t,:),'ro');
