function [minRow,maxRow,meanRow]=toSignal_Summary(table,Name,nRows,H,Type)
%Type is either Within or Among
table(cellfun(@isempty,table(:,1)),:)=[];
Summary_Table=cell(3,1);
Funcs=H.Funcs.(Type);
if ~isempty(table)
    
    for i=1:numel(H.Funcs.(Type))
        Summary_Table{i,1}=cell(1,nRows);
        if H.Usage.(Type)(i)==1
            Summary_Table{i,1}{1,1}=Name;
            try
                [~,I]=Funcs{i}(cell2mat(table(:,1)));
                Summary_Table{i,1}(2:end)=table(I,:);
            catch
                Summary_Table{i,1}(2:end)=arrayfun(@(x) {x},Funcs{i}(cell2mat(table),1));
            end
        end
    end
end
[minRow,maxRow,meanRow]=Summary_Table{:};
end
