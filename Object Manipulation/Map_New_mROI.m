function  [data]=Map_New_mROI(data)

NumChan=numel(data{9});
MChan=data{10}(1).Channel_Master;
for i=1:NumChan
    if i==MChan || isempty(data{9}{i})
    else
        PolyGons=data{9}{data{10}(1).Channel_Master}{2,9}(:,1);
        New_ROIs=data{9}{i}{2,6};
        for j=1:size(New_ROIs,1)
            Match=false(size(PolyGons,1),1);
            for ii=1:size(PolyGons,1)
                Match(ii,1)=inpolygon(New_ROIs{j,4}(1),New_ROIs{j,4}(2),PolyGons{ii}(:,1),PolyGons{ii}(:,2));
            end
            data{9}{i}{2,6}{j,3}=cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(Match,2));
        end
    end
end
end
