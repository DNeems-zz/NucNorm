function [gStats]=GroupStats(Table,Cluster_ID)
TableGroups=cell(size(Cluster_ID));
Obj_Region_Chan=regexp(Table{1}{1,1},'::','split');
Obj_Region_Chan=Obj_Region_Chan{1};
for i=1:size(Table,2)
    Num_Extract=arrayfun(@(x) regexp(x,' to ','split'),Table{1,i}(:,1));
    Num_Extract=arrayfun(@(x) regexp(x{1}{end},'_','split'),Num_Extract,'uniformoutput',0);
    Num_Extract=arrayfun(@(x) str2double(x{1}{2}),Num_Extract);
    for j=1:size(Cluster_ID,1)
    TableGroups{j,i}=Table{1,i}(ismember(Num_Extract,Cluster_ID{j,i}),:);
    end
end
gStats=cell(size(Table,2),3);
Ref=regexp(Table{1,1}{1,1},'::','split');
Ref=regexp(Ref{2},' to ','split');

for i=1:size(TableGroups,1)
Name=sprintf('%s::%s to Within Group %d_',Obj_Region_Chan,Ref{1},i);
tt=vertcat(TableGroups{i,:});
[gStats{i,1},gStats{i,2},gStats{i,3}]=toSignal_Summary(tt(:,2:end),Name,size(tt,2));
end
end
