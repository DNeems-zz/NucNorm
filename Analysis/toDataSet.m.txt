function Dataset_Result=toDataSet(Table)
warning('off', 'stats:dataset:ModifiedVarnames')

Table(:,find(cellfun(@isnan,Table(2,2:end)))+1)=[];
if size(Table,1)==1
Dataset_Result=nan;
else
    RNs=cell(size(Table,1)-1,1);
    mROI_Prefix=cell(size(Table,1)-1,1);
    for i=2:size(Table,1)
        Procces_Name=arrayfun(@(x) regexp(x,'::','split'),Table(i,1));
        mROI_Prefix{i-1,1}=Procces_Name{1}{1};
        Procces_Name=arrayfun(@(x) regexp(x{1}{2},' to ','split'),Procces_Name,'uniformoutput',0);
        Row_Name=regexp(Procces_Name{1},'_','split');
        RNs{i-1,1}=[Row_Name{:}];
    end
   Redundant_Rows=false(numel(RNs),numel(RNs));
   for i=1:numel(RNs)
       for j=1:numel(RNs)
       if sum(ismember(RNs{i},RNs{j}))==4 && sum(ismember(RNs{j},RNs{i}))==4 && i~=j
       Redundant_Rows(i,j)=true;
       end
       end
   end
   [R,C]=find(Redundant_Rows);
   Possible_Redundatant_Pairs=unique(sort([R,C],2),'rows');
   Del_Rows=false(size(Table,1),1);
   for i=1:size(Possible_Redundatant_Pairs,1)
       E1=cell2mat(Table(Possible_Redundatant_Pairs(i,1)+1,2:end));
       E2=cell2mat(Table(Possible_Redundatant_Pairs(i,2)+1,2:end));
       if ismember(E1,E2,'rows')==1 && strcmp(mROI_Prefix{Possible_Redundatant_Pairs(i,2)},mROI_Prefix{Possible_Redundatant_Pairs(i,1)})
           Del_Rows(Possible_Redundatant_Pairs(i,2)+1,1)=true;
       end
   end
   Table(Del_Rows,:)=[];
try
   Dataset_Result=cell2dataset(Table,'ReadVarNames',true,'ReadObsNames',true);
catch
    keyboard
end
   Dataset_Result.Properties.Description=Table{1,1};
   Dataset_Result.Properties.UserData=Table(1,:);
end
end
