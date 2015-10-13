function [allTable,summaryTable]=Measure_Shells(Query_PL,Shell_PL,Region_Objs,H)

Ana_ID=Query_PL{2};
Query_PL=Query_PL{1};
Ref_ID=Shell_PL{2};
Ref_PL=Shell_PL{1};
Obj_Region_Chan=Region_Objs.mROI_Name;
allTable=cell(size(Query_PL,1),1+((H.Num_Shell+2)*4));
summaryTable=cell(size(Ref_PL,1),3);
z=1;
Start_Pos=[2,2+(H.Num_Shell+2),2+(H.Num_Shell+2)*2,2+(H.Num_Shell+2)*3,2+(H.Num_Shell+2)*4];

for p=1:size(Ref_PL,1)
    Group_Start=z;
    for k=1:size(Query_PL,1)
        if strcmp(Ref_ID,Ana_ID) && p==k
        else
            allTable{z,1}=sprintf('%s:%s_%d to %s_%d',Obj_Region_Chan,Ref_ID,p,Ana_ID,k);
            if numel(unique(Ref_PL{1,1}{1,1}(:,3)))==1
                nSize=9;
            else
                nSize=27;
            end
            
            for j=1:size(Ref_PL,2)
                if ~isempty(Ref_PL{p,j})
                    Shell_Res_Count=zeros(1,H.Num_Shell+1);
                    Shell_Res_Percent=zeros(1,H.Num_Shell+2);
                    
                    for i=1:size(Query_PL{k,1},1)
                        toHull_Dist=nan(H.Num_Shell,1);
                        for S=1:H.Num_Shell
                            nnIndex=knnsearch(Query_PL{k,1}(i,:),Ref_PL{p,j}{1,S},nSize);
                            toHull_Dist(S,1)=min(min(pdist2(Query_PL{k,1}(i,:),Ref_PL{p,j}{1,S}(nnIndex,:))));
                        end
                        if sum(toHull_Dist<=H.Cutoff)>0
                            [~,I]=min(toHull_Dist);
                            Shell_Res_Count(1,I+1)=Shell_Res_Count(1,I+1)+1;
                        else
                            Shell_Res_Count(1,1)=Shell_Res_Count(1,1)+1;
                        end
                    end
                    
                    Shell_Res_Percent(1,:)=[sum(Shell_Res_Count(1,:).*[0:H.Num_Shell])/sum(Shell_Res_Count(1,:)),...
                        Shell_Res_Count(1,:)./sum(Shell_Res_Count(1,:))];
                    allTable(z,Start_Pos(j):Start_Pos(j+1)-1)=arrayfun(@(x) {x},Shell_Res_Percent);

                    else
                     allTable(z,Start_Pos(j):Start_Pos(j+1)-1)=arrayfun(@(x) {x},nan(1,numel(allTable(z,Start_Pos(j):Start_Pos(j+1)-1))));
                end
            end
                z=z+1;
           
        end
       Name=sprintf('%s:%s_%d to %s Summary',Obj_Region_Chan,Ref_ID,p,Ana_ID);
    [summaryTable{p,1},summaryTable{p,2},summaryTable{p,3}]=toSignal_Summary(allTable(Group_Start:z-1,2:end),Name,size(allTable,2));    
    end
 end
summaryTable=[{vertcat(summaryTable{:,1})},{vertcat(summaryTable{:,2})},{vertcat(summaryTable{:,3})}];
allTable=allTable(~cellfun(@isempty,allTable(:,1)),:);
end