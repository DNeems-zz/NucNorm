function [Pull_Index]=Find_RowPull(Pull_From,IndexPull)

Pull_Index=false(numel(Pull_From),1);
for j=1:numel(IndexPull)
    for i=1:numel(Pull_From)
        if sum(vertcat(Pull_From{i})==IndexPull(j))>0
            Pull_Index(i,1)=true;
        end
    end
end
Pull_Index=find(Pull_Index);
end