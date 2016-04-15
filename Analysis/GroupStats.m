function [TableGroups,gStats]=GroupStats(Table,Cluster_ID,H)

Obj_Region_Chan=regexp(Table{1}{1},'::','split');
Obj_Region_Chan=Obj_Region_Chan{1};
Cluster_Pairs=cell(size(Cluster_ID,1),1);
for CC=1:size(Cluster_ID,1)
    for k=1:size(Cluster_ID(CC,:),2)
        for j=1:cellfun('size',Cluster_ID(CC,k),2)
            Cluster_Pairs{CC,1}(end+1,1:2)=[{k},Cluster_ID{CC,k}(j)];
        end
    end
end
%Cluster_Pairs:  Channel Number then Obj Number

Comp_Code=cell(size(Table));
for i=1:size(Table,2)
    for j=1:size(Table,1)
        Procces_Name=arrayfun(@(x) regexp(x,'::','split'),Table{j,i}(:,1));
        Procces_Name=arrayfun(@(x) regexp(x{1}{2},' to ','split'),Procces_Name,'uniformoutput',0);
        z=1;
        for k=1:size(Procces_Name,1)
            Row_Name=regexp(Procces_Name{k},'_','split');
            Row_Name=[Row_Name{:}];
            for m=1:2:4
                Comp_Code{j,i}(z,m:m+1)=[{find(ismember(H.Channel_Names,Row_Name{m}))},{str2double(Row_Name{m+1})}];
            end
            z=z+1;
        end
        
    end
end

InCluster_ID=cell(size(Table));
for i=1:size(Table,2)
    for j=1:size(Table,1)
        InCluster_ID{j,i}=Pair_inCluster(Comp_Code{j,i},Cluster_Pairs);
    end
end
Linear_Cluster_ID=InCluster_ID(:);
Linear_Table=Table(:);
Group_Columns=cell(numel(Linear_Table),size(Cluster_ID,1));
for i=1:numel(Linear_Cluster_ID)
    for j=1:size(Cluster_ID,1)
        Group_Columns{i,j}=Linear_Table{i,1}(Linear_Cluster_ID{i}==j,:);
    end
end
TableGroups=cell(1,size(Cluster_ID,1));
for j=1:size(Cluster_ID,1)
    TableGroups{1,j}=vertcat(Group_Columns{:,j});
end

Ref=regexp(Table{1,1}{1,1},'::','split');
Ref=regexp(Ref{2},' to ','split');
gStats=cell(size(Table,2),3);

for i=1:size(TableGroups,2)
    if get(H.CProps.Pairwise,'value')==1
        Name=sprintf('%s::Within Group %d_',Obj_Region_Chan,i);
    else
        Name=sprintf('%s::%s to Within Group %d_',Obj_Region_Chan,Ref{1},i);
    end
        [gStats{i,1},gStats{i,2},gStats{i,3}]=toSignal_Summary(TableGroups{1,i}(:,2:end),Name,size(TableGroups{1,i},2),H,'Among');
    
        TableGroups{1,i}=vertcat([Name,...
            arrayfun(@(x) {x},zeros(1,sum(~cellfun(@isnan,TableGroups{1,i}(1,2:end))))),...
            arrayfun(@(x) {x},nan(1,sum(cellfun(@isnan,TableGroups{1,i}(1,2:end)))))],...
            TableGroups{1,i});
    
end
end

function [Logical_Pass]=Pair_inCluster(Pair,Clusters)
Logical_Pass=zeros(size(Pair,1),1);

for j=1:numel(Clusters)
    for i=1:size(Pair,1)
        if isempty(Pair{i,1})
        FirstIn=true;
                    SecondIn=sum(ismember(cell2mat(Clusters{j}),cell2mat(Pair(i,3:4)),'rows'))==1;
        elseif isempty(Pair{i,2})
            FirstIn=sum(ismember(cell2mat(Clusters{j}),cell2mat(Pair(i,1:2)),'rows'))==1;
        SecondIn=true;
        else
            FirstIn=sum(ismember(cell2mat(Clusters{j}),cell2mat(Pair(i,1:2)),'rows'))==1;
            SecondIn=sum(ismember(cell2mat(Clusters{j}),cell2mat(Pair(i,3:4)),'rows'))==1;
        end
            if FirstIn && SecondIn
                In=true;
            else
                In=false;
            end
    if In
        Logical_Pass(i,1)=j;
    end
    end
end

end
