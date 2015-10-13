function [Image]=Crop_byIndex(mROIs,zoneROIs,number)
RowPull=mROIs{number,2};
Six=zoneROIs{1};
Seven=zoneROIs{2};
[mPull_Index]=Find_RowPull(mROIs(:,2),RowPull);
[rPull_Index]=Find_RowPull(Six(:,3),RowPull);
Image=false(mROIs{mPull_Index,4}+1);
for i=1:numel(rPull_Index)
    PL=regionprops(Six{rPull_Index(i),1},'pixellist');
    Shift=Seven(rPull_Index(i),:)-mROIs{mPull_Index,3};
    PL=PL.PixelList;
    sPL=PL+repmat(Shift,size(PL,1),1);
    sPL(sPL<1)=1;
    for j=1:size(sPL,1)
    Image(sPL(j,2),sPL(j,1),sPL(j,3))=1;
    end
end

end