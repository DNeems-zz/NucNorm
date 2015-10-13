function [Image,HistImage]=Create_Input_Images(data,iHandles,sHandles)
Input_Image_Type=find([get(sHandles.MaxPRadio,'value'),get(sHandles.StackRadio,'value'),get(sHandles.MPRadio,'value'),get(sHandles.InMaster,'value')]);
Input_Image_Group=find([get(sHandles.WIRadio,'value'),get(sHandles.ObjRadio,'value'),get(sHandles.MastROIRadio,'value');]);
Channel_Choice=get(iHandles.ChannelMenu,'value');
Display_Choice=get(iHandles.DisplayModeMenu,'value');
MasterROI_Choice=get(iHandles.MasterROIMenu,'value');
Region_Size=str2double(get(sHandles.ExpVal,'string'));
MChan=data{10}(1).Channel_Master;
%working on implementation of the master ROI as the histagram input


 

IM=Extract_Data(data,2,Channel_Choice,Display_Choice);
if islogical(IM{1}(1,1))
    GS_Input=get(sHandles.ModImageMenu,'UserData');
    GS_Input=GS_Input(get(sHandles.ModImageMenu,'value'));
    IM=GS_Input{1};
elseif isa(IM{1}(1,1),'uint8')
    IM=IM{1,1};
else
    error('Unkown Image Type')
end



if get(sHandles.In_MasterBox,'value') ||  get(sHandles.In_MasterOis,'value')

    if get(sHandles.In_MasterOis,'value')
        Sub_Image=Extract_Data(data,2,data{10}(1).Channel_Master,2);
        Sub_Image=uint8(~Sub_Image{1,1})*255;
    else
        
        mRegions=data{9}{data{10}(1).Channel_Master}{2,9};
        Sub_Image=false(iHandles.IMSize);
        for i=1:size(mRegions,1)
            Sub_Image(mRegions{i,3}(2):mRegions{i,3}(2)+mRegions{i,4}(1)-1,...
                mRegions{i,3}(1):mRegions{i,3}(1)+mRegions{i,4}(2)-1,...
                mRegions{i,3}(3):mRegions{i,3}(3)+mRegions{i,4}(3)-1)=true(mRegions{i,4});
        end
        Sub_Image=uint8(~Sub_Image)*255;
    end
else
    Sub_Image=uint8(false(iHandles.IMSize));
end



IM={IM-Sub_Image};
%Still working here have to handle the cases when the input image is from
%some sub regions to being with 

switch Input_Image_Group
    case 1
        Image=[IM,1,{[0,0,0]}];
    case 2
        Six_Seven=Extract_Data(data,[6,7],Channel_Choice,Display_Choice);
        Six=Six_Seven{1};
        FS=Six_Seven{2};
        Image=cell(size(FS,1),3);
        for i=1:size(FS,1)
            [W,H,D]=size(Six{i,1});
            Y=FS(i,2);X=FS(i,1); Z=FS(i,3);
            [A,B,C,D]=Crop_Image(IM{1,1},X,Y,Z,H,W,D,Region_Size);
            Image(i,:)=[{A},Six{i,3},{[B-1,C-1,D-1]}];
        end
        if MasterROI_Choice~=1
            RowPull=data{9}{data{10}(1).Channel_Master}{2,9}{MasterROI_Choice-1,2};
            [Pull_Index]=Find_RowPull(data{9}{Channel_Choice}{Display_Choice,6}(:,3),RowPull);
            Image=Image(Pull_Index,:);
        end
    case 3
        if MasterROI_Choice==1
            Image=cell(size(data{9}{data{10}(1).Channel_Master}{2,9},1),3);
            for i=1:size(data{9}{data{10}(1).Channel_Master}{2,9},1)
                [Image(i,:)]=Extract_Image_Region(data,i+1,IM,iHandles.IMSize(3));
                mImage=Crop_byIndex(data{9}{MChan}{2,9},[data{9}{MChan}(2,6),data{9}{MChan}(2,7)],i);
                if get(sHandles.In_MasterOis,'value')
                    Image{i,1}=Image{i,1}-uint8(~mImage)*255;
                end
            end
        else
            [Image]=Extract_Image_Region(data,MasterROI_Choice,IM,iHandles.IMSize(3));
            mImage=Crop_byIndex(data{9}{MChan}{2,9},[data{9}{MChan}(2,6),data{9}{MChan}(2,7)],MasterROI_Choice-1);
            if get(sHandles.In_MasterOis,'value')
                Image{1,1}=Image{1,1}-uint8(~mImage)*255;
            end
        end
end

HistImage=cell(size(Image,1),1);
for i=1:size(Image,1)
    switch Input_Image_Type
        case 1
            HistImage{i,1}=max(Image{i,1},[],3);
        case 2
            HistImage{i,1}=Image{i,1};
        case 3
            HistImage{i,1}=Image{i,1}(:,:,round(size(Image{i,1},3)/2));
        case 4
            if MasterROI_Choice==1
                [SS]=Extract_Data(data,[6,7],data{10}(1).Channel_Master,2);
                HistImage{i,1}=Six_to_Image(SS{1,1}(i,:),SS{1,2}(i,:)-Image{i,3},size(Image{i,1}),'Add');
                HistImage{i,1}=Image{i,1}-uint8(~HistImage{i,1})*255;
            else
                
                
                [SS]=Extract_Data(data,[6,7],data{10}(1).Channel_Master,2);
                HistImage{i,1}=Six_to_Image(SS{1,1}(MasterROI_Choice-1,:),SS{1,2}(MasterROI_Choice-1,:)-Image{1,3},size(Image{i,1}),'Add');
                HistImage{i,1}=Image{i,1}-uint8(~HistImage{i,1})*255;
            end
    end
end


end

function [Image]=Extract_Image_Region(data,MasterROI_Choice,Image,Z_Steps)

mROIs=data{9}{data{10}(1).Channel_Master}{2,9};
mROI_IndexPull=cell2mat(mROIs(MasterROI_Choice-1,2));
mROI_RowPull=find(cell2mat(mROIs(:,2))==cell2mat(mROIs(MasterROI_Choice-1,2)));
W=mROIs{mROI_RowPull,4}(1); H=mROIs{mROI_RowPull,4}(2); D=mROIs{mROI_RowPull,4}(3);
Y=mROIs{mROI_RowPull,3}(2);X=mROIs{mROI_RowPull,3}(1); Z=mROIs{mROI_RowPull,3}(3);
RawImage=Image;
[RawImage,BB(1),BB(2),BB(3)]=Crop_Image(RawImage{:},X,Y,Z,H,W,D,0);
StackDepth=size(RawImage,3);
if ~isa(RawImage,'logical')
    RawImage=uint8(double(RawImage).*255/double(max(max(max(RawImage)))));
    BottomPad=repmat(uint8(zeros(size(max(RawImage,[],3)))),[1,1,BB(3)-1]);
    TopPad=repmat(uint8(zeros(size(max(RawImage,[],3)))),[1,1,Z_Steps-StackDepth]);
else
    BottomPad=repmat(false(size(max(RawImage,[],3))),[1,1,BB(3)-1]);
    TopPad=repmat(false(size(max(RawImage,[],3))),[1,1,Z_Steps-StackDepth]);
    
end

Image=[{cat(3,BottomPad,RawImage,TopPad)},mROI_IndexPull,{BB-1}];

end