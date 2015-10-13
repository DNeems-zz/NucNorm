function Image=Six_to_Image(Six,Seven,IMSize,type)
% Type can be one of three strings
% 1) Compose: Build an image from all the ROIs given in six and seven
% 2) Remove: Remove the ROIs given in six and seven and return a
% subtraction mask
% 3) Add: Add the ROIs given in six and seven and return an Addition mask

if strcmp(type,'Compose')
    Choice=1;
elseif strcmp(type,'Remove')
    Choice=2;
elseif strcmp(type,'Add')
    Choice=3;
else
    error('Invalid Choice')
end

Image=false(IMSize);
switch Choice
    case 1
        
        PL=cell(size(Six,1),1);
        for i=1:size(Six,1)
            tROI=regionprops(Six{i,1},'pixellist');
            PL{i,1}=tROI.PixelList+repmat(Seven(i,:),size(tROI.PixelList,1),1);
        end
        PL=vertcat(PL{:});
        for i=1:size(PL,1)
            Image(PL(i,2),PL(i,1),PL(i,3))=1;
        end
    case {2,3}
        PL=cell(size(Six,1),1);
        for i=1:size(Six,1)
            tROI=regionprops(Six{i,1},'pixellist');
            if size(tROI.PixelList,2)~=size(Six{i,4},2)
            tROI.PixelList=[tROI.PixelList,ones(size(tROI.PixelList,1),1)];
            end
            PL{i,1}=tROI.PixelList+repmat(Seven(i,:),size(tROI.PixelList,1),1);
        end
        PL=vertcat(PL{:});
        for i=1:size(PL,1)
            Image(PL(i,2),PL(i,1),PL(i,3))=1;
        end
end
end