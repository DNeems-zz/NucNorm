function [Filtered_ROIs]=Unique_association(mROIs,Filtered_ROIs)
mROI_Center=zeros(size(mROIs,1),size(mROIs{1,3},2));
for i=1:size(mROIs,1)
    mROI_Center(i,:)=[mROIs{i,3}(1)+(mROIs{i,4}(2)+mROIs{i,3}(1)),...
        mROIs{i,3}(2)+(mROIs{i,4}(1)+mROIs{i,3}(2)),...
        mROIs{i,3}(3)+(mROIs{i,4}(3)+mROIs{i,3}(3))]./2;
end

for j=1:size(Filtered_ROIs{2},1)
    if numel(Filtered_ROIs{2}{j,3})>1
   [~,I]=min(pdist2(mROI_Center,Filtered_ROIs{2}{j,4}));
   Filtered_ROIs{2}{j,3}=mROIs{I,2};
    end
end


end