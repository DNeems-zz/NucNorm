function [minRow,maxRow,meanRow]=toSignal_Summary(table,Name,nRows,H)

table(cellfun(@isempty,table(:,1)),:)=[];
Summary_Table=cell(3,1);
Funcs=get(H.GS.Within(ismember(get(H.GS.Within,'visible'),'on')),'userdata');

for i=1:sum(ismember(get(H.GS.Within,'visible'),'on')) %Number of visable items in the group
    Summary_Table{i,1}=cell(1,nRows);
    if get(H.GS.Within(i),'value')==1
        Summary_Table{i,1}{1,1}=Name;
        try
            [~,I]=Funcs{i}(cell2mat(table(:,1)));
            Summary_Table{i-1,1}(2:end)=table(I,:);
        catch
            Summary_Table{i,1}(2:end)=arrayfun(@(x) {x},Funcs{i}(cell2mat(table)));
        end
    end
end
[minRow,maxRow,meanRow]=Summary_Table{:};
end
