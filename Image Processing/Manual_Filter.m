function [ROI]=Manual_Filter(Image,sHandles)
ROI=cell(size(Image,1),1);
UseAll=false;

for i=1:size(Image,1)
    if UseAll
    else
        H=ManualSlider(max(Image{i,1},[],3));
        if size(Image,1)==1
            set(H.All,'visible','off')
        end
        waitfor(H.fh,'userdata')
        Res=guidata(H.fh);
        LLimit=floor(get(Res{1}.Slider,'value'));
        UseAll=get(H.All,'value');
        close(H.fh)
    end
    Binary_Image=Image{i,1}>= round(LLimit);
    Binary_Image=BasicImage_Filter(Binary_Image,sHandles);
    ROI{i,1}=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
    for k=1:numel(ROI{i,1})
        ROI{i,1}(k).RegionNum=Image{i,2};
    end
end
end