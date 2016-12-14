%Main Module to calculate R(t) mainCalculateRt2.m

close all;
clear all;
format long;
clc;

nodes=100;
iterations=15;
C0=1;
q=10; xRange=q;
RlzS=30;

radioDecay=.25;
connPerc=.9;
innerR=sqrt(2)/2*.0;
outerR=sqrt(2)/2*.25;

saveFileName='resCalcRt2_102_25_9_0_25';

allResults.radioDecay=radioDecay;
allResults.connPerc=connPerc;
allResults.innerR=innerR;
allResults.outerR=outerR;

rlzInd=1;
while(1) 
    %try;
    [htList,GWnode,B,xLoc,yLoc]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);
    [GWnode,B]=pickDecoder(xLoc,yLoc,htList,innerR,outerR);
    edges=size(htList,1);
    phi=orth(rand(nodes,nodes));
    fprintf(['run=' num2str(rlzInd) ' -Network Generated with ' num2str(edges) ' edges->']);
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
    [PsiTot,epsSquaredCoefs]=calculateQNC(iterations,A,F,B); 
    fprintf([' QNC coef Generated - ']);  
    
    %Find OutEdges and InEdges
    for node=1:nodes
        outEdges{node}=find(htList(:,2)==node);
    end
    GWinEdges=find(htList(:,1)==GWnode);
    fprintf([' List of Edges is calculated - ']);  
    
    fprintf([' calculating Fprods - ']);  
    tic;
    Fprods=[];
    Fprods{iterations+2,iterations+2}=[];
    for t=2:iterations+1
        for t1=2:t
            for t11=2:t1
                tLeft=t11+1;
                tRight=t1;
                if(isempty(Fprods{tLeft,tRight}))
                    %Calculate Fprod(tLeft,tRight)
                    Fprods{tLeft,tRight}=eye(edges,edges);
                    if(tRight>=tLeft)
                        for tIndex=tRight:-1:tLeft
                            Fprods{tLeft,tRight}=F{tIndex} * Fprods{tLeft,tRight};
                        end
                    end
                end
            end
        end
        fprintf(['t=' num2str(t) '-']);
    end
    fprintf([' Fprods are calculated in ' num2str(toc) ' seconds - ']);  
    
    R(1:iterations+1)=0;
    for t=2:iterations+1
        %Calculate Numerator
        numerator(t)=0;
        for t1=2:t
            for eInIndex=1:length(GWinEdges)
                eIn=GWinEdges(eInIndex);
                summand=0;
                for t11=2:t1
                    for eOut=1:edges
                        tLeft=t11+1;
                        tRight=t1;
                        summand=summand+abs(Fprods{tLeft,tRight}(eIn,eOut));
                    end
                end
                numerator(t)=numerator(t)+summand^2;
            end
        end
        %Calcualte Denumerator
        denumeratorS=zeros(nodes,1);
            for t1=2:t
                for eInIndex=1:length(GWinEdges)
                    eIn=GWinEdges(eInIndex);
                    for t11=2:t1
                        tLeft=t11+1;
                        tRight=t1;
                        %for node=1:nodes
                        for j=1:nodes
                            for eOutIndex=1:length(outEdges{j})
                                eOut=outEdges{j}(eOutIndex);
                                denumeratorS(:,1)=denumeratorS(:,1)+(Fprods{tLeft,tRight}(eIn,eOut))^2*(phi(j,:)').^2;
                            end
                        end
                        %end
                    end
                end
            end
            denumerator(t)=min(denumeratorS);
            
            R(t)=numerator(t)/denumerator(t);
            fprintf([' t=' num2str(t) ', R(t)=' num2str(R(t)) '- ']);  
        end
    fprintf(' DONE. \n');
       
    allResults.Rvalues{rlzInd}=R;
    allResults.Numeratorvalues{rlzInd}=numerator;
    allResults.Denumeratorvalues{rlzInd}=denumerator;
    
    doneRun=rlzInd;
    save(saveFileName,'allResults');
    if(doneRun==RlzS)
       break; 
    else
        rlzInd=rlzInd+1;
    end
        fprintf('\n');
   % catch
   %     fprintf('!!!Error Occured!!! \n');
   % end
end
%stem(R);

% FontSize=13;
% lw=1.5;
% scrsz = get(0,'ScreenSize');
% figure('Position',[50 50 600 500]); 
% xlabel('Time Index (t)','fontsize',FontSize); 
% ylabel('Logarithmic R(t)','fontsize',FontSize); 
% hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
% %title(['edges=' num2str(edges)],'fontsize',FontSize);
% 
% for i=1:12%length(allResults.Rvalues)
%     if(mod(i,4)==0)
%         plot(log(allResults.Rvalues{i}),'r-o','linewidth',lw);
%     elseif(mod(i,4)==1)
%         plot(log(allResults.Rvalues{i}),'g-s','linewidth',lw);
%     elseif(mod(i,4)==2)
%         plot(log(allResults.Rvalues{i}),'b-*','linewidth',lw);
%     elseif(mod(i,4)==3)
%         plot(log(allResults.Rvalues{i}),'c-^','linewidth',lw);
%     end
% end



