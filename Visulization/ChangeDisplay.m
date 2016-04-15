function []=ChangeDisplay(varargin)

%% Intial Import Statments
data = guidata(varargin{1});
handles=data{1};
Close_H=~ismember(get(handles.IMAxes,'Children'),handles.ImagePlace_Handle);
All_H=get(handles.IMAxes,'Children');
Close_H=All_H(Close_H);
delete(Close_H)
set(handles.ImagePlace_Handle,'cData',[]);
% Imports Current Setting from all the display menus
Choice.MasterROI=get(handles.MasterROIMenu,'value');
Choice.Channel=get(handles.ChannelMenu,'value');
Choice.Projection=get(handles.DisplayTypeMenu,'value');
Choice.Display=get(handles.DisplayModeMenu,'value');
Choice.Entry=varargin{3};

Choice.Overlay=CallBack_Value_String(handles.OverlayMenu);


%% Update all handles from the various display menus once a setting is changed 
if varargin{1}==handles.MasterROIMenu
    handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)=false;

end

[Choice]=Change_Chan(data,handles,Choice);
GrayScale_Image=arrayfun(@(x) isa(x{1,1},'uint8'),Extract_Data(data,2,Choice.Channel,Choice.Display),'uniformoutput',0);
GrayScale_Image=GrayScale_Image{:};
[Choice,handles,RawImage,Image,Centroids]=Extract_IM(data,handles,GrayScale_Image,Choice);

%% Figure out the type of image is going to be displayed

[Choice]=Change_UdRd(data,handles,Choice);
[Choice]=Update_GUI_Disp(data,handles,GrayScale_Image,Choice);

[Choice,handles,Image]=Change_mROI(data,handles,Image,Choice);

[Choice,handles,RawImage,Image]=Change_Proj(data,handles,RawImage,Image,Choice);

[Choice,handles,Image]=Add_Overlay(data,handles,RawImage,Image,Choice,Centroids);

Menu_Permissions(data,handles,Choice)
Thresh_Permissions(data,handles,Choice)
Apply_Permissions(data,handles,Choice,GrayScale_Image)


%% Set the Images and Store the changes in the data Sctucture 

set(handles.ImagePlace_Handle,'cData',Image)

set(handles.IMAxes,'XLim',[0 size(Image,2)],'YLim',[0 size(Image,1)])
handles.CurrentView=get(handles.ImagePlace_Handle,'cData');
guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)])
get(handles.IMAxes,'UserData');

end




function [Choice]=Change_Chan(data,handles,Choice)
if Choice.Entry==1
    set(handles.DisplayModeMenu,'value',1);
    [Requested_Data]=Extract_Data(data,4,Choice.Channel,0);
    set(handles.DisplayModeMenu,'string',Requested_Data)
    Choice.Display=1;
end

end

function [Choice]=Update_GUI_Disp(data,handles,GrayScale_Image,Choice)

if GrayScale_Image
    set(handles.OverlayMenu,'string','None','value',1)
    set(handles.Type,'string','Image Type: Gray Scale')
    set(handles.Seg,'string','Segmented: No')
    Choice.Overlay='None';
else
    set(handles.OverlayMenu,'string',[{'None'},{'Composite'},{'Color'},{'Numbered'}])
    set(handles.Type,'string','Image Type: Binary')
    set(handles.Seg,'string','Segmented: Yes')
end
[Requested_Data]=Extract_Data(data,8,Choice.Channel,Choice.Display);

set(handles.InputImage,'string',sprintf('Input Image: %s',Requested_Data{1}{1}))

if handles.MasterSet_Toggle
    Chans=numel(data{10});
    for i=1:Chans
        if Choice.MasterROI==1
        N='NaN';
        else
            mIndex=cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(Choice.MasterROI-1,2));
            try
                [RowPull]=Find_RowPull(data{9}{i}{end,6}(:,3),mIndex);
                N=num2str(numel(RowPull));
            catch
                N='NaN';
            end
        end
        set(handles.byChanObj(i),'string',sprintf('%s: %s',data{10}(i).Channel_ID,N))
    end
    
end


end

function [Choice,handles,RawImage,Image]=Change_Proj(data,handles,RawImage,Image,Choice)
%Turns of slice-slider when appoperaite
if Choice.Projection~=5
    set(handles.SliceSlider,'visible','off')
    set(handles.CurrentSlice,'visible','off')
    set(handles.SliceSlider,'value',1)
    set(handles.CurrentSlice,'string','Current Slice: 1')
else
    set(handles.SliceSlider,'visible','on')
    set(handles.CurrentSlice,'visible','on')
end
%Creates a consisten label matrix

%Converts to correct image stack
switch Choice.Projection
    case 1
        %Max Projection
        Image=max(Image,[],3);
        RawImage=max(RawImage,[],3);
    case 2
        %Mean Intensity
        Image=uint8(mean(Image,3));
        RawImage=uint8(mean(RawImage,3));
    case 3
        %Min Projection
        Image=min(Image,[],3);
        RawImage=min(RawImage,[],3);
    case 4
        %Mid Plane
        Image=Image(:,:,round(size(Image,3)/2));
        RawImage=RawImage(:,:,round(size(RawImage,3)/2));
    case 5

        Image=Image(:,:,floor(get(handles.SliceSlider,'value')));
        RawImage=RawImage(:,:,floor(get(handles.SliceSlider,'value')));
end

end

function [Choice,handles,Image]=Change_mROI(data,handles,Image,Choice)
%Turns of slice-slider when appoperaite

if Choice.Entry==5
    handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)=false;
    if strcmp(Choice.Overlay,'Color')
        if ~handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)
        handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)=true;
        ROI=regionprops(Image,'pixellist');
        Color_LabelMatrix=zeros(size(Image));
        Color_Assign=randsample(numel(ROI),numel(ROI),0);
        for i=1:numel(ROI)
            PL=ROI(i).PixelList;
            for k=1:size(PL,1)
                Color_LabelMatrix(PL(k,2),PL(k,1),PL(k,3))=Color_Assign(i);
            end
        end
        handles.cLabelMatrix{Choice.Display,Choice.Channel}=Color_LabelMatrix;
        Image=handles.cLabelMatrix{Choice.Display,Choice.Channel};
    else
        Image=handles.cLabelMatrix{Choice.Display,Choice.Channel};
        end
    else
    end
end
end

function [Choice,handles,RawImage,Image,Centroids]=Extract_IM(data,handles,GrayScale_Image,Choice)

if Choice.MasterROI==1
    RawImage=Extract_Data(data,2,Choice.Channel,1);
    RawImage=RawImage{:};
    RawImage=uint8(double(RawImage).*255/double(max(max(max(RawImage)))));
    Image=Extract_Data(data,2,Choice.Channel,Choice.Display);
    
    Image=Image{:};
    if ~isa(Image,'uint8')
    Image=logical(Image);
    end
  
    Six=Extract_Data(data,6,Choice.Channel,Choice.Display);
    if isempty(Six{1,1})
        Centroids=[];
    else
        Centroids=Six{1}(:,4);
    end
    
    if  strcmp(Choice.Overlay,'Color')
        if ~handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)
            handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)=true;
            Five_Six_Seven=Extract_Data(data,[5,6,7],Choice.Channel,Choice.Display);
            Image=zeros(size(RawImage));
            for i=1:size(Five_Six_Seven{1},1)
                display(sprintf('Adding Obj %d of %d to Color Code Image',i,size(Five_Six_Seven{1},1)))
                tImage=zeros(size(RawImage));
                Shift=Five_Six_Seven{3}(i,:);
                for j=1:numel(Shift)
                    if Shift(j)==0
                        Shift(j)=1;
                    end
                end
                IM=Five_Six_Seven{2}{i,1};
                imS=size(IM);
                if numel(imS)<numel(size(Image))
                    imS(3)=1;
                end
                
                tImage(Shift(2):Shift(2)+imS(1)-1,...
                    Shift(1):Shift(1)+imS(2)-1,...
                    Shift(3):Shift(3)+imS(3)-1)=IM;
                tImage=tImage(1:size(RawImage,1),1:size(RawImage,2),1:size(RawImage,3));
                Image=Image+tImage*i;
                
            end
            handles.cLabelMatrix{Choice.Display,Choice.Channel}=Image;
            Image=handles.cLabelMatrix{Choice.Display,Choice.Channel};
        else
            Image=handles.cLabelMatrix{Choice.Display,Choice.Channel};
        end
    end
else
    mROIs=data{9}{data{10}(1).Channel_Master}{2,9};
    mROI_IndexPull=cell2mat(mROIs(Choice.MasterROI-1,2));
    [mROI_RowPull]=Find_RowPull(mROIs(:,2),mROI_IndexPull);
   
    W=mROIs{mROI_RowPull,4}(1); H=mROIs{mROI_RowPull,4}(2); D=mROIs{mROI_RowPull,4}(3);
    Y=mROIs{mROI_RowPull,3}(2);X=mROIs{mROI_RowPull,3}(1); Z=mROIs{mROI_RowPull,3}(3);
    RawImage=Extract_Data(data,2,Choice.Channel,1);
    [RawImage,BB(1),BB(2),BB(3)]=Crop_Image(RawImage{:},X,Y,Z,H,W,D,0);
    RawImage=uint8(double(RawImage).*255/double(max(max(max(RawImage)))));
    StackDepth=size(RawImage,3);
    
    BottomPad=repmat(uint8(zeros(size(max(RawImage,[],3)))),[1,1,BB(3)-1]);
    TopPad=repmat(uint8(zeros(size(max(RawImage,[],3)))),[1,1,handles.IMSize(3)-StackDepth-(BB(3)-1)]);
    RawImage=cat(3,BottomPad,RawImage,TopPad);
    Centroids=[];
    
    if GrayScale_Image
        Image=RawImage;
    else
        Five_Six_Seven=Extract_Data(data,[5,6,7],Choice.Channel,Choice.Display);
        Image=zeros(size(RawImage));
 
        if ~isempty(Five_Six_Seven{1,1})
            Six_RowPull=Find_RowPull(Five_Six_Seven{2}(:,3),mROI_IndexPull);
            Centroids=cell(numel(Six_RowPull),1);
            for i=1:numel(Six_RowPull)
                tImage=zeros(size(RawImage)*4);
                Expand_Size=size(tImage);
                Shift=[Five_Six_Seven{3}(Six_RowPull(i),1:2)-(BB(1:2)-1),Five_Six_Seven{3}(Six_RowPull(i),3)];
                
                IM=Five_Six_Seven{2}{Six_RowPull(i),1};
                imS=size(IM);
                if numel(imS)<numel(size(Image))
                    imS(3)=1;
                end
                tShift=floor(Expand_Size/6);
                Shift=Shift+tShift;
                tImage(Shift(2)+1:Shift(2)+imS(1),...
                    Shift(1)+1:Shift(1)+imS(2),...
                    Shift(3)+1:Shift(3)+imS(3))=IM;
                tImage=tImage(tShift(2)+1:size(RawImage,1)+tShift(2),...
                    tShift(1)+1:size(RawImage,2)+tShift(1),...
                    tShift(3)+1:size(RawImage,3)+tShift(3));
                if  strcmp(Choice.Overlay,'Color')
                    Image=Image+tImage*i;
                else
                    Image=Image+tImage;
                end
                Centroids{i,1}=Five_Six_Seven{2}{Six_RowPull(i),4}-Five_Six_Seven{3}(Six_RowPull(i),:)+Shift-tShift;
                
            end
                
                if  strcmp(Choice.Overlay,'Color')
                    if ~handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)
                        
                        Image=(Image(1:size(RawImage,1),1:size(RawImage,2),1:size(RawImage,3)));
                        handles.cLabelMatrix{Choice.Display,Choice.Channel}=Image;
                        handles.cLabelMatrix_Toggle(Choice.Display,Choice.Channel)=true;
                    else
                    Image= handles.cLabelMatrix{Choice.Display,Choice.Channel};
                    end

                else
                    Image=logical(Image(1:size(RawImage,1),1:size(RawImage,2),1:size(RawImage,3)));
                end
            end
        
    end
    
end

if isempty(Centroids)
    set(handles.ObjCount,'string','Num ROIs: NaN')
else
    set(handles.ObjCount,'string',sprintf('Num ROIs: %d',size(Centroids,1)))
end
end

function [Choice,handles,Image]=Add_Overlay(data,handles,RawImage,Image,Choice,Centroids)

if strcmp(Choice.Overlay,'None')
    Image=repmat(Image,[1,1,3]);
elseif strcmp(Choice.Overlay,'Composite')
    RGB_Image=repmat(RawImage,[1,1,3]);
    RGB_Image(:,:,1)=RGB_Image(:,:,1)-uint8(Image)*255;
    RGB_Image(:,:,3)=RGB_Image(:,:,3)-uint8(Image)*255;
    Image=RGB_Image;
elseif  strcmp(Choice.Overlay,'Color')
    Max_Label=max(handles.cLabelMatrix{Choice.Display,Choice.Channel}(:));

    cmap=jet(Max_Label);
    Image = label2rgb(Image, cmap, 'black');
elseif  strcmp(Choice.Overlay,'Numbered')
    Image=repmat(Image,[1,1,3]);

    for i=1:numel(Centroids);
        text(Centroids{i,1}(1,1),Centroids{i,1}(1,2),sprintf('%d',i),'color','red','HorizontalAlignment','center','VerticalAlignment','middle');
    end
    
end
handles.ImagePlace_Handle=findobj(get(handles.IMAxes,'children'),'type','image');
end

function [Choice]=Change_UdRd(data,handles,Choice)
UdRd_Position=data{11}{Choice.Display,Choice.Channel}{2};
UdRd_List=data{11}{Choice.Display,Choice.Channel}{1};
if UdRd_Position==size(UdRd_List,1)
    set(handles.ThrMenu.Redo,'enable','off')
else
    set(handles.ThrMenu.Redo,'enable','on')
end
if UdRd_Position==1
    set(handles.ThrMenu.Undo,'enable','off')
else
    set(handles.ThrMenu.Undo,'enable','on')
end
end

function []=Menu_Permissions(data,handles,Choice)

Chan=numel(data{10});
Disable_mROI=false;
for i=1:Chan
    try
        if data{9}{i}{2,1}==1
            if size(data{9}{i},1)~=2
                Disable_mROI=true;
                break
            end
        end
    catch
    end
    
end

if Disable_mROI
    set(handles.MasterROIMenu,'enable','off')

else
        set(handles.MasterROIMenu,'enable','on')
    set(handles.MasterROIMenu,'visible','on')

end
if handles.MasterSet_Toggle == 0
       set(handles.MasterROIMenu,'visible','off')

end
end

function []=Thresh_Permissions(data,handles,Choice)
Allow_Modification=false;
try
    Allow_Modification=data{9}{Choice.Channel}{2,1};
    if isempty(Allow_Modification)
        Allow_Modification=false;
    end
catch
end
sFN=fieldnames(handles.ThrMenu.Seg);
fFN=fieldnames(handles.ThrMenu.Filt);

if Allow_Modification==0 && Choice.MasterROI>1
   Mode='off'; 
else
    Mode='on';
end

for i=1:numel(sFN)
    set(handles.ThrMenu.Seg.(sFN{i}),'enable',Mode)
end
for i=1:numel(fFN)
    set(handles.ThrMenu.Filt.(fFN{i}),'enable',Mode)
end
end

function []=Apply_Permissions(data,handles,Choice,GrayScale_Image)
if GrayScale_Image
    Mode='off';
else
    Mode='on';
end

try
    if data{9}{Choice.Channel}{2,1}==1 && (Choice.MasterROI==1 || size(data{9}{Choice.Channel},1)==2 )
        Mode='off';
    end
catch
end




set(handles.ApplySelection,'enable',Mode)
end