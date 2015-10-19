function [ROI]=Otsu_Filter(Image,HistImage,sHandles)
ROI=cell(size(Image,1),1);

for i=1:size(Image,1)
    [levels,Efficacy]=graythresh(HistImage{i,1});
    H=HistImage{i,1};
    H=H(:);
    lowercutoff=((max(H)-min(H))*levels)+min(H);
    LLimit=lowercutoff;
    if Efficacy<=.5
        display(sprintf('Warning low efficacy score of %1f',Efficacy));
    end
    Binary_Image=Image{i,1}>= round(LLimit);
    Binary_Image=BasicImage_Filter(Binary_Image,sHandles);
    ROI{i,1}=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
    for k=1:numel(ROI{i,1})
        ROI{i,1}(k).RegionNum=Image{i,2};
    end
end
end