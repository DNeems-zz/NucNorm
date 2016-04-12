function [Mod_ROIs,delta_ROIs,data]=Remove_Assosciation(Mod_ROIs,dRow,data,Working_Region)
delete_ROIs=cell(1,3);

for j=1:numel(dRow)
    if sum(ismember(Mod_ROIs{2}{dRow(j),3},Working_Region)~=1)>0

        Mod_ROIs{2}{dRow(j),3}=Mod_ROIs{2}{dRow(j),3}(~ismember(Mod_ROIs{2}{dRow(j),3},Working_Region));
        dRow(j,1)=nan;
    end
end
dRows=dRow(~isnan(dRow));
for i=1:3
    delete_ROIs{1,i}= Mod_ROIs{1,i}(dRows,:);
    Mod_ROIs{i}(dRows,:)=[];
end
delta_ROIs=cell(size(delete_ROIs{1},1),2);
%delta ROIs column 2 == 1 flag to delete, 2 would be add

for i=1:size(delete_ROIs{1},1)
    for j=1:3
        delta_ROIs{i,1}{1,j}=delete_ROIs{1,j}(i,:);
    end
    delta_ROIs{i,2}=1;
end
end
