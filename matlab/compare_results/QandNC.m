function [recErrNorm,recX,delay]=QandNC(nodes,edges,htList,x,GWnode,bLen,C0,qMax,B,Awindow2,Fwindow2);
digits=bLen*C0;
fieldSize=2^digits;

iterations=ceil(nodes/size(B,1));

%Quantize Messags at the sources
for node=1:nodes
    QxFF1(node,1)=round((x(node)/2/qMax+1/2)*fieldSize);
    if(QxFF1(node)<0)
        QxFF1(node)=0;
    elseif(QxFF1(node)>fieldSize-1)
        QxFF1(node)=fieldSize-1;
    end
end
QxFF=gf(QxFF1,digits);

%Generate Network Coding Coefficients in Finite Field
for t=1:iterations+1
    edgeContent{t}=gf(zeros(edges,1),digits);
    F{t}=gf(zeros(edges,edges),digits);
    A{t}=gf(zeros(edges,nodes),digits);
end

Awindow=gf(Awindow2,digits);
Fwindow=gf(Fwindow2,digits);
for t=2:iterations+1
    F{t}=Fwindow.*(gf(floor(rand(edges,edges)*fieldSize),digits));
    if(t==2)
        A{t}=Awindow.*(gf(floor(rand(edges,nodes)*fieldSize),digits));
    else
        
    end
end

measTot{1}=[];
for t=2:iterations+1
    edgeContent{t}=F{t}*edgeContent{t-1}+A{t}*QxFF;
    measTot{t}=[measTot{t-1};B*edgeContent{t}];
end

%Calculate PsiTot
Psi{2}=gf(B,digits)*A{2};
PsiTot{2}=Psi{2};
Fprod=gf(eye(edges,edges),digits);
Bb=gf(B,digits);
for t=3:iterations+1
    Fprod=F{t}*Fprod;
    Psi{t}=Bb*Fprod*A{2};
    PsiTot{t}=[PsiTot{t-1};Psi{t}];
end
delay=(iterations+1)*bLen;

%for final t:
t=iterations+1;
finalPsiTot=PsiTot{t}(end-nodes+1:end,:);
finalMeasurements=measTot{t}(end-nodes+1:end);
decQx=(finalPsiTot)\finalMeasurements;

vec=[0:2^digits-1];
for node=1:nodes
    m1=find(vec==decQx(node));
    recX(node,1)=vec(m1);
    recX(node)=(recX(node)/fieldSize-1/2)*2*qMax;
end
recErrNorm=norm(recX-x,2);
