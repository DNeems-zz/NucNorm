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
if size(Query_PL{1,1},1)==1
Query_Type='Centroid';
else
Query_Type='Perimeter';    
end

uRows=true(size(Query_PL,1)*size(Ref_PL,1),1);
if strcmp(Query_Type,H.Pixel_Set)==1
    Possible_Pairs=sort(allcomb([1:size(Ref_PL,1)],[1:size(Query_PL,1)]),2);
    uPairs=unique(Possible_Pairs,'rows');
    for i=1:size(uPairs,1)
        uRows(find(ismember(Possible_Pairs,uPairs(i,:),'rows'),1,'first'),1)=false;
    end
    uRows=~uRows;
end

z=1;
for p=1:size(Ref_PL,1)
    Group_Start=z;
    for k=1:size(Query_PL,1)
        if (strcmp(Ref_ID,Ana_ID) && p==k) ||  uRows(z)==0
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
                    pVal_lCI]=Bootstrap_Error(absDist(z,1),Distrobution_Distance{1,O}{p,1},str2double(get(H.AnProp(2).AnaProp(5),'string')),str2double(get(H.AnProp(2).AnaProp(7),'string')));
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
    Name=sprintf('%s:%s_%d to %s Summary',Obj_Region_Chan,Ref_ID,p,Ana_ID);
     [summaryTable{p,1},summaryTable{p,2},summaryTable{p,3}]=toSignal_Summary(allTable(Group_Start:z-1,2:end),Name,11);

end

summaryTable=[{vertcat(summaryTable{:,1})},{vertcat(summaryTable{:,2})},{vertcat(summaryTable{:,3})}];
allTable=allTable(~cellfun(@isempty,allTable(:,1)),:);
end