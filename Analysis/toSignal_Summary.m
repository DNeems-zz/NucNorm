function [minRow,maxRow,meanRow]=toSignal_Summary(table,Name,nRows)

table(cellfun(@isempty,table(:,1)),:)=[];
minRow=cell(1,nRows);
maxRow=cell(1,nRows);
meanRow=cell(1,nRows);
minRow{1,1}=Name;
maxRow{1,1}=Name;
meanRow{1,1}=Name;
if isempty(table)
minRow(2:end)=arrayfun(@(x) {x},nan(1,numel(minRow)-1));
maxRow(2:end)=arrayfun(@(x) {x},nan(1,numel(maxRow)-1));
meanRow(2:end)=arrayfun(@(x) {x},nan(1,numel(meanRow)-1));

else
[~,I]=min(cell2mat(table(:,1)));

minRow(2:end)=table(I,:);
[~,I]=max(cell2mat(table(:,1)));
maxRow(2:end)=table(I,:);

meanRow(2:end)=arrayfun(@(x) {x},mean(cell2mat(table),1));
end


end
