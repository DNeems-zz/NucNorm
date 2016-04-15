function [Image]=SixSeven_to_Image(Six,Seven,IMSize)

Image=false(IMSize);
for i=1:size(Six,1)
    PL=regionprops(Six{i,1},'pixellist');
    PL=PL.PixelList;
    sPL=PL+repmat(Seven(i,:),size(PL,1),1);
    for k=1:size(sPL,1)
    Image(sPL(k,2),sPL(k,1),sPL(k,3))=1;
    end
end
end