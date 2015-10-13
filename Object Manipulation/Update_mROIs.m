function [ROI_List,data]=Update_mROIs(data,ROI_List,rm_ROI)
MChan=data{10}(1).Channel_Master;
RawImage=Extract_Data(data,2,get(data{1}.ChannelMenu,'value'),1);
maxROI_Num=max(cell2mat(data{9}{MChan}{2,9}(:,2)));
New_Rows=find(cellfun(@isempty,ROI_List{2}(:,3)));

New_ROIs=cell(1,3);
for i=1:size(New_Rows,1)
    ROI_List{2}{New_Rows(i),3}=maxROI_Num+i;
    New_ROIs{2}(i,:)= ROI_List{2}(New_Rows(i),:);
    New_ROIs{3}(i,:)= ROI_List{3}(New_Rows(i),:);
end
[mROI_data]=Create_MasterROI_Desc(New_ROIs{2},...
    New_ROIs{3},...
    RawImage,...
    data{1}.MasterExpansion);
data{9}{MChan}{2,9}=[data{9}{MChan}{2,9};mROI_data];
[data]=Map_New_mROI(data);
rmROI=[{cell2mat(rm_ROI{2}(:,3))},get(data{1}.ChannelMenu,'value')];
MasterROI_Removal(data,rmROI)
data=guidata(data{1}.fh);
end