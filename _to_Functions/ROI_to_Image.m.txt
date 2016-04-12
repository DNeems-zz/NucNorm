function Image=ROI_to_Image(ROI,IMSize)
Image= false(IMSize);

for Regions=1:numel(ROI)
    PL=ROI(Regions).PixelList;
    for k=1:size(PL,1)
        Image(PL(k,2),PL(k,1),PL(k,3))=1;
    end
end
end