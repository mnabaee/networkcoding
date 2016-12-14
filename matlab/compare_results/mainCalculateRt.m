%Main Module to calculate R(t) mainCalculateRt.m

close all;
clear all;
format long;
clc;

nodes=100;
iterations=25;
C0=1;
q=10; xRange=q;
RlzS=25;

radioDecay=.35;
connPerc=.9;
innerR=sqrt(2)/2*.0;
outerR=sqrt(2)/2*.25;

saveFileName='resCalcRt_101_35_9_0_25';

allResults.radioDecay=radioDecay;
allResults.connPerc=connPerc;
allResults.innerR=innerR;
allResults.outerR=outerR;

rlzInd=1;
while(1) 
    try;
    [htList,GWnode,B,xLoc,yLoc]=GenNetCapsuleDecayWise(nodes,radioDecay,connPerc);
    [GWnode,B]=pickDecoder(xLoc,yLoc,htList,innerR,outerR);
    edges=size(htList,1);
    phi=orth(rand(nodes,nodes));
    fprintf(['run=' num2str(rlzInd) ' -Network Generated with ' num2str(edges) ' edges->']);
    [A,F]=GenQNCcoef(nodes,edges,iterations,htList);
    [PsiTot,epsSquaredCoefs]=calculateQNC(iterations,A,F,B); 
    fprintf([' QNC coef Generated - ']);  

   
    
    for t=2:iterations
       nonZero(t)=sum(sum(PsiTot{t}~=0)>0); 
    end
    t11=find(nonZero==nodes);
    if(~isempty(t11))
    t11=t11(1);
    %stem(nonZero); grid on;
    
    %Find OutEdges and InEdges
    for node=1:nodes
        outEdges{node}=find(htList(:,2)==node);
    end
    GWinEdges=find(htList(:,1)==GWnode);
    fprintf([' List of Edges is calculated - ']);  
    R(1:t11)=0;
    for t=t11:iterations+1
        %Calculate Numerator
        nums=zeros(nodes,1);
        for t1=2:1:t
            sum2s=zeros(nodes,1);
            %Calculate Fprod's
            for t2=2:1:t1
                Fprod{t2}=eye(edges,edges);
                if(t1>=t2+1)
                    for tIndx=t2+1:1:t1
                        Fprod{t2} = F{tIndx} * Fprod{t2};
                    end
                end
            end
            for e1Indx=1:length(GWinEdges)
                e1=GWinEdges(e1Indx);
                sum1s=zeros(nodes,1);
                for t2=2:1:t1
                    for j=1:nodes
                        for e2Indx=1:length(outEdges{j})
                            e2=outEdges{j}(e2Indx);
                            sum1s(j)=sum1s(j)+ abs( Fprod{t2}(e1,e2));
                        end
                    end
                end
                sum2s=sum2s+sum1s.^2;
            end
            nums=nums+sum2s;
        end
        numerator(t)=sum(nums);
        %Calculate Denumerator
        denums=zeros(nodes,1);
        for t1=2:1:t
            sum2s=zeros(nodes,1);
            %Calculate Fprod's
            for t2=2:1:t1
                Fprod{t2}=eye(edges,edges);
                if(t1>=t2+1)
                    for tIndx=t2+1:1:t1
                        Fprod{t2} = F{tIndx} * Fprod{t2};
                    end
                end
            end
            for e1Indx=1:length(GWinEdges)
                e1=GWinEdges(e1Indx);
                sum1s=zeros(nodes,1);
                for t2=2:1:t1
                    for j=1:nodes
                        for e2Indx=1:length(outEdges{j})
                            e2=outEdges{j}(e2Indx);
                            sum1s(j)=sum1s(j)+ Fprod{t2}(e1,e2)^2;
                        end
                    end
                end
                sum2s=sum2s+sum1s;
            end
            denums=denums+sum2s;
        end
        denumerator(t)=min(denums);
        R(t)=numerator(t)/denumerator(t);
        fprintf([' t=' num2str(t) ', R(t)=' num2str(R(t)) '- ']);  
    end
    fprintf(' DONE. \n');
       
    allResults.Rvalues{rlzInd}=R;
    
    doneRun=rlzInd;
    save(saveFileName,'allResults');
    if(doneRun==RlzS)
       break; 
    else
        rlzInd=rlzInd+1;
    end
    else
        fprintf('\n');
    end
    catch
        fprintf('!!!Error Occured!!! \n');
    end
end
%stem(R);

FontSize=13;
lw=1.5;
scrsz = get(0,'ScreenSize');
figure('Position',[50 50 600 500]); 
xlabel('Time Index (t)','fontsize',FontSize); 
ylabel('Logarithmic R(t)','fontsize',FontSize); 
hold on; set(gca,'box','on'); set(gca,'fontsize',FontSize); grid on;
%title(['edges=' num2str(edges)],'fontsize',FontSize);

for i=1:12%length(allResults.Rvalues)
    if(mod(i,4)==0)
        plot(log(allResults.Rvalues{i}),'r-o','linewidth',lw);
    elseif(mod(i,4)==1)
        plot(log(allResults.Rvalues{i}),'g-s','linewidth',lw);
    elseif(mod(i,4)==2)
        plot(log(allResults.Rvalues{i}),'b-*','linewidth',lw);
    elseif(mod(i,4)==3)
        plot(log(allResults.Rvalues{i}),'c-^','linewidth',lw);
    end
end



