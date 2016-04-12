function [allTable,summaryTable]=Measure_Distance(Query_PL,Ref_PL,Region_Objs,Distrobution_Distance,H)
%Mode Determines the Function to use on the set of pair wise distances once computed 
%Mode: 'min'
%Mode: 'max'
%Mode: 'mean'

Ana_ID=Query_PL{2};
Query_PL=Query_PL{1};
Ref_ID=Ref_PL{2};
Ref_PL=Ref_PL{1};
absDist=zeros(size(Query_PL,1),1);
Obj_Region_Chan=Region_Objs.mROI_Name;
Start_Pos=[2,5,8];
allTable=cell(size(Query_PL,1)*size(Ref_PL,1),11);
summaryTable=cell(size(Ref_PL,1),3);


z=1;

for p=1:size(Ref_PL,1)
    for k=1:size(Query_PL,1)
        if (strcmp(Ref_ID,Ana_ID) && p==k)
            if size(Ref_PL,1) ==1 && size(Query_PL,1)==1
        allTable{z,1}=sprintf('%s:%s_%d to %s_%d',Obj_Region_Chan,Ref_ID,p,Ana_ID,k);
        allTable{z,2}=0;

        allTable(z,3:end)=arrayfun(@(x) {x},nan(1,9));
            end
        else
        allTable{z,1}=sprintf('%s:%s_%d to %s_%d',Obj_Region_Chan,Ref_ID,p,Ana_ID,k);
        All_Dist=pdist2(Query_PL{k,1},Ref_PL{p,1});


        All_Dist=All_Dist(:);
        absDist(z,1)=H.Comp_Mode(All_Dist);
        allTable{z,2}=absDist(z,1);
        for O=1:3
            if ~isempty(Distrobution_Distance{1,O})
                [pVal,...
                    pVal_uCI,...
                    pVal_lCI]=Bootstrap_Error(absDist(z,1),...
                    Distrobution_Distance{1,O}{p,1},...
                    H);
            else
                pVal=nan; pVal_uCI=nan; pVal_lCI=nan;
            end
            allTable{z,Start_Pos(O)+1}=pVal;
            allTable{z,Start_Pos(O)+2}=pVal_uCI;
            allTable{z,Start_Pos(O)+3}=pVal_lCI;
            
        end
        end
            z=z+1;
    
    end
    

end
    Name=sprintf('%s:%s to %s Summary',Obj_Region_Chan,Ref_ID,Ana_ID); 
    [summaryTable{1,1},summaryTable{1,2},summaryTable{1,3}]=toSignal_Summary(allTable(:,2:end),Name,11,H,'Within');

summaryTable=[{vertcat(summaryTable{:,1})},{vertcat(summaryTable{:,2})},{vertcat(summaryTable{:,3})}];
allTable=allTable(~cellfun(@isempty,allTable(:,1)),:);
end