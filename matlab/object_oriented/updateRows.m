function [sim,code]=updateRows(sim,code);

for t=2:sim.QNCsteps+1
    newPsiTot=code.PsiTot{t};
    newMeasTot=sim.MeasurementTot{t};
    newNoiseEffTot=sim.EffMeasNoiseTot{t};
    cnt=1;
    for i=1:size(newPsiTot,1)
        rowNorm=norm(code.PsiTot{t}(i,:),2);
        rowNorm=sum(abs(code.PsiTot{t}(i,:)));
        if(rowNorm~=0)
            newPsiTot(cnt,:)=code.PsiTot{t}(i,:);%/rowNorm;
            newNoiseEffTot(cnt,1)=sim.EffMeasNoiseTot{t}(i);%/rowNorm;
            newMeasTot(cnt,1)=sim.MeasurementTot{t}(i);%/rowNorm;
            cnt=cnt+1;
        else
            newPsiTot(cnt,:)=[];
            newNoiseEffTot(cnt)=[];
            newMeasTot(cnt)=[];
        end
    end
    code.PsiTot{t}=newPsiTot;
    sim.EffMeasNoiseTot{t}=newNoiseEffTot;
    sim.MeasurementTot{t}=newMeasTot;
    

end