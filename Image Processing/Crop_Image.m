function [cImage,varargout]=Crop_Image(wholeImage,CornerX,CornerY,CornerZ,Height,Width,Depth,varargin)
IMSize=size(wholeImage);

if ~isempty(varargin)
   
    Expand=varargin{1};
    CornerX=CornerX-floor(Height*Expand);
    CornerY=CornerY-floor(Width*Expand);
    CornerZ=CornerZ-floor(Depth*Expand);
    E=floor([Height,Width,Depth]+[Height,Width,Depth].*(Expand*2));

    Height=E(1);
    Width=E(2);
    Depth=E(3);
    if CornerX<=0
        CornerX=1;
        Height=Height-1;
    end
    if CornerY<=0
        CornerY=1;
        Width=Width-1;
    end
    if CornerZ<=0
        CornerZ=1;
        Depth=Depth-1;
    end
    if CornerY+Width>IMSize(1)
        Width=IMSize(1)-CornerY;
    end
    if CornerX+Height>IMSize(2)
        Height=IMSize(2)-CornerX;
    end
    
    if CornerZ+Depth>IMSize(3)
        Depth=IMSize(3)-CornerZ;
    end
    

    varargout={CornerX,CornerY,CornerZ};
end

cImage=wholeImage(CornerY:CornerY+Width,...
    CornerX:CornerX+Height,...
    CornerZ:CornerZ+Depth);


end