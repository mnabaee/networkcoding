classdef QNCcodeBook < handle
    properties
        QNCsteps
        A
        F
        B
        PsiTot
        epsSquaredCoefs
    end
    methods
        %Function: Generates QNC codes for Full QNC
        function QNCcode=generateCodeFull(QNCcode,sD,QNCsteps)
            QNCcode.QNCsteps=QNCsteps;
            
            for t=1:QNCsteps+1
                QNCcode.A{t}=zeros(sD.edges,sD.nodes);
                QNCcode.F{t}=zeros(sD.edges,sD.edges);
            end
            for node=1:sD.nodes
                inEdges=find(sD.edgeListHead==node);
                outEdges=find(sD.edgeListTail==node);
                
                absSum=0;
                for eOutInd=1:length(outEdges)
                    QNCcode.A{2}(outEdges(eOutInd),node)=1;%sign(randn);%randn;
                    absSum=absSum+abs(QNCcode.A{2}(outEdges(eOutInd),node));
                end
                %QNCcode.A{2}(:,node)=QNCcode.A{2}(:,node)/absSum;
                
                %Check the Condition
                if(length(inEdges)>=length(outEdges))
                    %We are Good!
                else
                    %Remove extra OutEdges
                    outEdges(length(inEdges)+1:end)=[];
                end
                for t=3:QNCsteps
                    basisVecs=RandOrthMat(length(inEdges))';
                    for eOutInd=1:length(outEdges)
                        for eInInd=1:length(inEdges)
                            QNCcode.F{t}(outEdges(eOutInd),inEdges(eInInd))=basisVecs(eOutInd,eInInd);
                        end
                        QNCcode.F{t}(outEdges(eOutInd),:)=QNCcode.F{t}(outEdges(eOutInd),:)/sum(abs(QNCcode.F{t}(outEdges(eOutInd),:)));
                    end
                end
            end
            inEdges=find(sD.edgeListHead==sD.GWnode);
            QNCcode.B=zeros(length(inEdges),sD.edges);
            for eInInd=1:length(inEdges)
                QNCcode.B(eInInd,inEdges(eInInd))=1;
            end
        end
        %Function: Generates QNC codes for One-Step QNC
        function QNCcode=generateCodeOneStep(QNCcode,sD,QNCsteps)
            QNCcode.QNCsteps=QNCsteps;
            
            for t=1:QNCsteps+1
                QNCcode.A{t}=zeros(sD.edges,sD.nodes);
                QNCcode.F{t}=zeros(sD.edges,sD.edges);
            end
            for node=1:sD.nodes
                inEdges=find(sD.edgeListHead==node);
                outEdges=find(sD.edgeListTail==node);
                
                absSum=0;
                for eOutInd=1:length(outEdges)
                    QNCcode.A{2}(outEdges(eOutInd),node)=1;%sign(randn);%randn;
                    absSum=absSum+abs(QNCcode.A{2}(outEdges(eOutInd),node));
                end
                %QNCcode.A{2}(:,node)=QNCcode.A{2}(:,node)/absSum;
                
                %Check the Condition
                if(length(inEdges)>=length(outEdges))
                    %We are Good!
                else
                    %Remove extra OutEdges
                    outEdges(length(inEdges)+1:end)=[];
                end
                for t=3:QNCsteps
                    basisVecs=RandOrthMat(length(inEdges))';
                    for eOutInd=1:length(outEdges)
                        for eInInd=1:length(inEdges)
                            QNCcode.F{t}(outEdges(eOutInd),inEdges(eInInd))=basisVecs(eOutInd,eInInd);
                        end
                        QNCcode.F{t}(outEdges(eOutInd),:)=QNCcode.F{t}(outEdges(eOutInd),:)/sum(abs(QNCcode.F{t}(outEdges(eOutInd),:)));
                    end
                end
            end
            inEdges=find(sD.edgeListHead==sD.GWnode);
            QNCcode.B=zeros(length(inEdges),sD.edges);
            for eInInd=1:length(inEdges)
                QNCcode.B(eInInd,inEdges(eInInd))=1;
            end
        end
        %Function: Calculate PsiTot
        function QNCcode=calculatePsiTot(QNCcode)
            %Calculate Psi(t)
            sum=QNCcode.A{2};
            Psi=QNCcode.B*sum;
            QNCcode.PsiTot{2}=Psi;
            for t=3:QNCcode.QNCsteps+1
                sum=QNCcode.F{t}*sum+QNCcode.A{t};
                Psi=QNCcode.B*sum;
                QNCcode.PsiTot{t}=[QNCcode.PsiTot{t-1};Psi];
            end
        end
        %Function: Calculate epsMaxCoefficient for L1 recovery
        function QNCcode=calculateEpsRec(QNCcode)
            QNCcode.epsSquaredCoefs=zeros(QNCcode.QNCsteps+1,1);
            QNCcode.epsSquaredCoefs(1)=0;
            edges=size(QNCcode.F{2},1);
            for t=2:QNCcode.QNCsteps+1
                if(t<11)
                    Fprod=eye(edges,edges);
                    sum=zeros(edges,edges);
                    for tPrime=1:t-1
                        for t2Prime=t:-1:tPrime+2
                            Fprod=Fprod*QNCcode.F{t2Prime};
                        end
                        sum=sum+abs(Fprod);
                    end
                    thisPortion=1/4*ones(1,edges)*sum'*QNCcode.B'*QNCcode.B*sum*ones(edges,1);
                else
                    thisPortion=0;
                end
                    QNCcode.epsSquaredCoefs(t)=QNCcode.epsSquaredCoefs(t-1)+thisPortion;
            end
        end
        
    end
end