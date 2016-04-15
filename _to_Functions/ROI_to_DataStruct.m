function [DataStruct]=ROI_to_DataStruct(ROI,BaseImage)
%Base Image: Varaible Structure
%Col 1) 3D GrayScale Image
%Col 2) ROI Number 
%Col 3) FrameShift

N_ROIs=numel(ROI);

Five=cell(N_ROIs,2);
Six=cell(N_ROIs,4);
Seven=cell(N_ROIs,3);

for i=1:N_ROIs
    for j=1:numel(ROI{i})
        Six{i,1}{j,1}=ROI{i}(j).Image;
        Six{i,1}{j,2}=max(ROI{i}(j).Image,[],3);
        Six{i,1}{j,3}=ROI{i}(j).RegionNum;
        BB=ceil(ROI{i}(j).BoundingBox);
        if length(BB)==4
            BB=[BB(1:2),1,BB(3:4),1];
        end
        try
        cImage=Crop_Image(BaseImage{i,1},...
            BB(1),BB(2),BB(3),...
            BB(4)-1,BB(5)-1,BB(6)-1);
        catch
            keyboard
        end
        Five{i,1}{j,1}=cImage;
        Five{i,1}{j,2}=max(cImage,[],3);
        
        Seven{i,1}(j,:)=abs(BaseImage{i,3}+[min(ROI{i}(j).PixelList)-[1,1,1]]);
        
        Six{i,1}{j,4}=mean(ROI{i}(j).PixelList,1)+BaseImage{i,3};
    end
end
DataStruct=[{vertcat(Five{:,1})},{vertcat(Six{:,1})},{vertcat(Seven{:,1})}];
end