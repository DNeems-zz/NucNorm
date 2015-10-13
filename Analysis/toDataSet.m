function Dataset_Result=toDataSet(Table)
warning('off', 'stats:dataset:ModifiedVarnames')
Table(:,find(cellfun(@isnan,Table(2,2:end)))+1)=[];
if size(Table,1)==1
Dataset_Result=nan;
else
    Dataset_Result=cell2dataset(Table,'ReadVarNames',true,'ReadObsNames',true);
    Dataset_Result.Properties.Description=Table{1,1};
    Dataset_Result.Properties.UserData=Table(1,:);
end
end
