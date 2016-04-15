function [Mod_ROIs]=Split_ROI(varargin)
data=varargin{4};
Mod_ROIs=varargin{5};
handle=data{1};
Mode=varargin{3};
%Image=handle.CurrentView;
Channel_Choice=get(handle.ChannelMenu,'value');
%Current_mROI=get(handle.MasterROIMenu,'value');
Current_Display=get(handle.DisplayModeMenu,'value');
%Current_Overlay=get(handle.OverlayMenu,'value');
%[RawImage]=Extract_Data(data,2,Channel_Choice,1);
%RawImage=RawImage{:};
Shift=varargin{6};

Split_Index=ID_Click_Obj(Mod_ROIs{2},handle.IMAxes,Shift);
Split_ROI=cell(1,3);
All_Images=Extract_Data(data,2,Channel_Choice,0);
Image_Names=Extract_Data(data,4,Channel_Choice,0);
Int_IM_Names=Image_Names(arrayfun(@(x)  isa(x{1},'uint8'),All_Images));
Int_IM=All_Images(arrayfun(@(x)  isa(x{1},'uint8'),All_Images));
H.fh = figure('units','normalized',...
    'position',[.35 .55 .2 .05],...
    'menubar','none',...
    'name',varargin{3},...
    'numbertitle','off',...
    'resize','off',...
    'Name','Choose Int Image to Split Off');
H.Pop=uicontrol('style','popupmenu',...
    'unit','normalized',...
    'position',[.1 .5 .8 .2],...
    'String',[{'None'},Int_IM_Names],...
    'fontsize',10,...
        'fontweight','bold',...
        'HorizontalAlignment','left');
waitfor(H.Pop,'value')
Int_IM=Int_IM{get(H.Pop,'value')-1};
close(H.fh)


for i=1:3
    Split_ROI{1,i}=Mod_ROIs{1,i}(Split_Index,:);
    Mod_ROIs{1,i}(Split_Index,:)=[];
end
Base_Split_ROI=Split_ROI;

for i=1:size(Split_ROI,1)
    infoLoc=[size(Split_ROI{i,2}{1,1}),Split_ROI{i,3}];
    W = infoLoc(1); H = infoLoc(2); D = infoLoc(3);
    X = infoLoc(4); Y = infoLoc(5); Z = infoLoc(6);
    [GrayScale_Image,b,c,d]=Crop_Image(Int_IM,X,Y,Z,H,W,D,.3);
    Split_ROI{i,1}{1,1}=GrayScale_Image;
    Split_ROI{i,4}=[X,Y,Z]-[b-1,c-1,d-1];
    Split_ROI{i,2}{1,1}=Six_to_Image(Split_ROI{i,2},[X,Y,Z]-[b-1,c-1,d-1],size(GrayScale_Image),'Compose');
    Split_ROI{i,1}{1,2}=max(Split_ROI{i,1}{1,1},[],3);
    Split_ROI{i,2}{1,2}=max(Split_ROI{i,2}{1,1},[],3);
    
end
switch Mode
    case 'Manual'
       [BaseImage,New_ROIs]=Manual_Split(Split_ROI,handle);        
    case 'Watershed'
       [BaseImage,New_ROIs]=Watershed_Split(Split_ROI,handle,varargin{7});        
    case 'Hull Dist'
    case 'Future'
end

%Adding the index of the newly split objects should be universal 
delIndex=Split_ROI{2}{3};
[BaseImage,New_ROIs]=Assign_mROI(BaseImage,New_ROIs,data);
New_ROIs=ROI_to_DataStruct(New_ROIs,BaseImage);
if data{1}.MasterSet_Toggle==1 
    if data{10}(1).Channel_Master==Channel_Choice 
    data=Configure_mROI(New_ROIs,data,delIndex);
    set(handle.MasterROIMenu,'string',['None',arrayfun(@(x) num2str(x),1:size(data{9}{data{10}(1).Channel_Master}{2,9},1),'uniformoutput',0)])
set(handle.ChannelMenu,'value',Channel_Choice)
set(handle.DisplayModeMenu,'value',Current_Display)
ChangeDisplay(handle.fh,[],7)
    end
end

for i=1:3
Mod_ROIs{1,i}=vertcat(Mod_ROIs{1,i},New_ROIs{1,i});
end

delta_ROIs=cell(numel(Mod_ROIs),2);
%delta ROIs column 2 == 1 flag to delete, 2 would be add
delta_ROIs{1,1}=Base_Split_ROI;
delta_ROIs{1,2}=1;

for i=1:size(New_ROIs{1},1)
    for j=1:3
    delta_ROIs{i+1,1}{1,j}=New_ROIs{1,j}(i,:);
    end
    delta_ROIs{i+1,2}=2;

end

Manipulation_PostProcess(Mod_ROIs,delta_ROIs,data,'Modify')

end

function [BaseImage,New_ROIs]=Manual_Split(Split_ROI,handle)
RGB_Image=repmat(max(Split_ROI{1,1}{1,2},[],3),[1,1,3]);
RGB_Image(:,:,2)=RGB_Image(:,:,2)-uint8(max(Split_ROI{1,2}{1,1},[],3))*255;
RGB_Image(:,:,3)=RGB_Image(:,:,3)-uint8(max(Split_ROI{1,2}{1,1},[],3))*255;

Image=uint8(double(RGB_Image).*255/double(max(max(max(RGB_Image)))));
h=figure;
imshow(imresize(Image,4));

prompt={'How Many Regions Do you Wish to Define'};
name='Regions';
numlines=1;
defaultanswer={'2'};
numRegions=inputdlg(prompt,name,numlines,defaultanswer);
numRegions=str2double(numRegions{1});

New_ROIs=cell(numRegions,1);
BaseImage=cell(numRegions,4);

for i=1:numRegions
    [bigimMAP,~]=roipoly(imresize(Image,4));
    imMAP=repmat(imresize(bigimMAP,.25),[1,1,size(Split_ROI{1,2}{1,2},3)]);
    clear bigimMAP
    imMAP=repmat(imMAP,[1,1,size(Split_ROI{1,1}{1,1},3)]);
    New_ROIs{i,1}=regionprops(logical(uint8(Split_ROI{1,2}{1,1})*255-( uint8(~imMAP)*255)),'image','pixellist','boundingbox');
    BaseImage{i,1}=Split_ROI{1,1}{1,1}-( uint8(~imMAP)*255);
    BaseImage{i,3}=Split_ROI{3}-Split_ROI{1,4};
      BaseImage{i,4}=Split_ROI{2}{3};
end
close(h)
end

function [BaseImage,New_ROIs]=Watershed_Split(Split_ROI,handle,Mode)
RGB_Image=repmat(max(Split_ROI{1,1}{1,2},[],3),[1,1,3]);
RGB_Image(:,:,2)=RGB_Image(:,:,2)-uint8(max(Split_ROI{1,2}{1,1},[],3))*255;
RGB_Image(:,:,3)=RGB_Image(:,:,3)-uint8(max(Split_ROI{1,2}{1,1},[],3))*255;
CutOut_IM=max(Split_ROI{1,1}{1,1}-(uint8(~Split_ROI{1,2}{1,1})*255),[],3);
Image=uint8(double(RGB_Image).*255/double(max(max(max(RGB_Image)))));
h=figure;
imshow(imresize(Image,4));

prompt={'How Many Regions Do you Wish to Define'};
name='Regions';
numlines=1;
defaultanswer={'2'};
numRegions=inputdlg(prompt,name,numlines,defaultanswer);
numRegions=str2double(numRegions{1});
close(h)
bw=Split_ROI{1,2}{2};
D = bwdist(~bw);
MaxD=max(max(D));
Int_Image=single(CutOut_IM).*MaxD/max(max(single(CutOut_IM)));
D=D+Int_Image;
D=-D;
D(~bw) = -Inf;
L = watershed(D);
Watershed_Regions=regionprops(L,'image','Area','Centroid','pixellist');
[~,I]=max([Watershed_Regions.Area]);
Watershed_Regions(I)=[];
Binary_Image=Split_ROI{1,2}{1,1};
GrayScale_Image=Split_ROI{1,1}{1};

switch Mode
    case 'Auto'
[Empty_Image]=Auto_Merge(Watershed_Regions,numRegions,Binary_Image);
    case 'Pick'
[Empty_Image]=Pick_Merge(Watershed_Regions,numRegions,Binary_Image,GrayScale_Image);
end

Image_Merge=Empty_Image-double(~Binary_Image)*(-numel(Watershed_Regions)+1);
Image_Merge(Image_Merge==0)=numel(Watershed_Regions)+2;
Image_Merge(Image_Merge~=numel(Watershed_Regions)+2)=0;
Add_BackPix=regionprops(logical(Image_Merge),'pixellist');
Add_BackPix=vertcat(Add_BackPix.PixelList);    
Label_Image=labelmatrix(bwconncomp(Empty_Image));
Num_Regions=max(max(max(Label_Image)));
Indvl_Regions=regionprops(logical(Empty_Image),Label_Image,'centroid','pixellist');

for i=1:Num_Regions
    Group_Num=Empty_Image(Indvl_Regions(i).PixelList(1,2),Indvl_Regions(i).PixelList(1,1),Indvl_Regions(i).PixelList(1,3));
Indvl_Regions(i).Group=Group_Num;
end

for i=1:Num_Regions
Label_Image(Label_Image==i)=Indvl_Regions(i).Group;
end
Pix_Group=zeros(size(Add_BackPix,1),1);
Indvl_Cent=vertcat(Indvl_Regions.Centroid);
Indvl_Group_ID=vertcat(Indvl_Regions.Group);

for i=1:size(Add_BackPix,1)
    [~,I]=(sort(pdist2(Indvl_Cent,Add_BackPix(i,:)),'ascend'));
    Pix_Group(i,1)=round(mode(Indvl_Group_ID(I(1:5),1)));
end

for i=1:size(Pix_Group,1)
    Empty_Image(Add_BackPix(i,2),Add_BackPix(i,1),Add_BackPix(i,3))=Pix_Group(i,1);
end

New_ROIs=cell(numRegions,1);
BaseImage=cell(numRegions,3);
for i=1:numRegions
tImage=Empty_Image;
tImage(tImage~=i)=0;
    ROI_Struct=regionprops(logical(tImage),'image','pixellist','boundingbox','area');
    [~,I]=max([ROI_Struct.Area]);
    ROI_Struct=ROI_Struct(I,:);
 
    New_ROIs{i,1}=ROI_Struct;
    tImage=false(size(GrayScale_Image));
    
    for j=1:size(ROI_Struct.PixelList,1)
    tImage(ROI_Struct.PixelList(j,2),ROI_Struct.PixelList(j,1),ROI_Struct.PixelList(j,3))=1;
    end
    BaseImage{i,1}=GrayScale_Image-(uint8(~tImage)*255);
    
    BaseImage{i,3}=Split_ROI{3}-(Split_ROI{1,4});
end  
end

function  [BaseImage,New_ROIs]=Assign_mROI(BaseImage,New_ROIs,data)
data=guidata(data{1}.fh);
handle=data{1};
Channel_Choice=get(handle.ChannelMenu,'value');
Current_mROI=get(handle.MasterROIMenu,'value');
MChan=data{10}(1).Channel_Master;
Current_Display=get(handle.DisplayModeMenu,'value');
Six=Extract_Data(data,6,Channel_Choice,Current_Display);
NewIndex=max(cell2mat(Six{1}(:,3)));
if isempty(NewIndex)
    NewIndex=0;
end

if handle.MasterSet_Toggle==0
    for i=1:size(New_ROIs,1)
        [~,I]=max(arrayfun(@(x) numel(x.Image),New_ROIs{i,1}));
        New_ROIs{i,1}=New_ROIs{i,1}(I);
        New_ROIs{i,1}.RegionNum=NewIndex+i;
        BaseImage{i,2}=NewIndex+i;
    end
else
    if MChan==Channel_Choice
        %Make a new master and map everything into it

        for i=1:size(New_ROIs,1)
            New_ROIs{i,1}.RegionNum=NewIndex+i;
            BaseImage{i,2}=NewIndex+i;
        end
    else
        %Map New split objects into the appoperaite master
       for i=1:size(New_ROIs,1)
            for j=1:size(New_ROIs{i,1})
                New_ROIs{i,1}(j).RegionNum=BaseImage{i,4};
            end
        BaseImage{i,2}=BaseImage{i,4};
        end
        %{
        PolyGons=data{9}{data{10}(1).Channel_Master}{2,9}(:,1);
        Cetroids=BaseImage(:,3);
        Match_Region=cell(size(Cetroids,1),1);
        for j=1:size(Cetroids,1)
            Match=false(size(PolyGons,1),1);
            for ii=1:size(PolyGons,1)
                Match(ii,1)=inpolygon(Cetroids{j,1}(1),Cetroids{j,1}(2),PolyGons{ii}(:,1),PolyGons{ii}(:,2));
            end
            Match_Region{j,1}=cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(Match,2));
        end
        for i=1:size(New_ROIs,1)
            for j=1:size(New_ROIs{i,1})
                New_ROIs{i,1}(j).RegionNum=Match_Region{i,1};
            end
        BaseImage{i,2}=Match_Region{i,1};
        end
        %}
    end
end
end



function [data]=Configure_mROI(New_ROIs,data,delIndex)
handle=data{1};
NumChan=numel(data{9});
MChan=data{10}(1).Channel_Master;
Channel_Choice=get(handle.ChannelMenu,'value');
Current_Display=get(handle.DisplayModeMenu,'value');
 RawImage=Extract_Data(data,2,get(data{1}.ChannelMenu,'value'),1);
 [mROI_data]=Create_MasterROI_Desc(New_ROIs{2},...
    New_ROIs{3},...
    RawImage,...
    repmat(data{1}.MasterExpansion,size(New_ROIs{2},1),1));
if data{1}.MasterSet_Toggle==1
data{9}{MChan}{2,9}=[data{9}{MChan}{2,9};mROI_data];

[data]=Map_New_mROI(data);

rmROI=[data{9}{data{10}(1).Channel_Master}{2,9}(cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(:,2))==delIndex,2),get(handle.ChannelMenu,'value')];
MasterROI_Removal(data,rmROI)
end
data=guidata(data{1}.fh);

end

function [Empty_Image]=Auto_Merge(Watershed_Regions,numRegions,Binary_Image)
[GroupIndex,~]=kmeans(vertcat(Watershed_Regions.Centroid),numRegions);

Empty_Image=zeros(size(Binary_Image));
for i=1:numRegions
    Match=find(GroupIndex==i);
    for j=1:sum(GroupIndex==i)
        PL=Watershed_Regions(Match(j)).PixelList;
        for k=1:size(PL,1)
            Pos_Z=find(squeeze(Binary_Image(PL(k,2),PL(k,1),:)));
            Add_Pix=[repmat([PL(k,2),PL(k,1)],size(Pos_Z,1),1),Pos_Z];
            for m=1:size(Add_Pix,1)
                Empty_Image(Add_Pix(m,1),Add_Pix(m,2),Add_Pix(m,3))=i;
            end
        end
    
    end
end

end


function [Empty_Image]=Pick_Merge(Watershed_Regions,numRegions,Binary_Image,Intensity_Image)
[GroupIndex,~]=kmeans(vertcat(Watershed_Regions.Centroid),numRegions);

Empty_Image=zeros(size(Binary_Image));
for i=1:numRegions
    Match=find(GroupIndex==i);
    for j=1:sum(GroupIndex==i)
        PL=Watershed_Regions(Match(j)).PixelList;
        for k=1:size(PL,1)
            Pos_Z=find(squeeze(Binary_Image(PL(k,2),PL(k,1),:)));
            Add_Pix=[repmat([PL(k,2),PL(k,1)],size(Pos_Z,1),1),Pos_Z];
            for m=1:size(Add_Pix,1)
                Empty_Image(Add_Pix(m,1),Add_Pix(m,2),Add_Pix(m,3))=i;
            end
        end
    
    end
end
H=Merge_GUI(numRegions,Intensity_Image,Empty_Image);
waitfor(H.Done,'userdata') 
H=get(H.fh,'userdata');
Empty_Image=H.WS;
close(H.fh)


end

function H=Merge_GUI(numRegions,GrayScale_Image,Watershed_Image)
H.WS=Watershed_Image;
H.GS=GrayScale_Image;

H.fh = figure('units','normalized',...
    'position',[.30 .35 .4 .45],...
    'menubar','none',...
    'name','ROI Merge',...
    'numbertitle','off',...
    'resize','off');
H.IM_Axes = axes('parent',H.fh,'units','normalized',...
    'position',[.0 .3 .66 .7],'tag','axes');
imshow(label2rgb(max(Watershed_Image,[],3)),'parent',H.IM_Axes)
H.GS_Axes = axes('parent',H.fh,'units','normalized',...
    'position',[.66 .6 .34 .4]);
imshow(max(GrayScale_Image,[],3),'parent',H.GS_Axes)
H.Done = uicontrol('parent',H.fh,'style','pushbutton','units','normalized',...
    'position',[.75 .45 .2 .1],'string','Done','Userdata',1,'fontsize',12);
set(H.Done,'callback',{@Done})
j=0;
k=1;
for i=1:numRegions
    if i==6
        j=.07;
        k=1;
    elseif i==11
        j=.14;
        k=1;
    end
    H.Region_Select(i)= uicontrol('Style','radio','String',i,...
        'units','normalized','pos',[.08*(k) .21-j .18 .07],'parent',H.fh,...
        'backgroundcolor',get(H.fh,'color'),'fontsize',12,'HorizontalAlignment','left',...
        'tag','RegionCheck');
    k=k+1;
end
for i=1:numRegions
set(H.Region_Select(i),'callback',{@Update_GUI,H})
end
set(get(H.IM_Axes,'children'),'ButtonDownFcn',{@Update_GUI,H},'tag','Image')
set(H.fh,'userdata',H)

end
function Update_GUI(varargin)

H=varargin{3};
H=get(H.fh,'userdata');
Current_ROI=find(cell2mat(get(H.Region_Select,'value'))==1);

if isempty(Current_ROI)
    GS_Handle=get(H.GS_Axes,'children');
    RGB_I=repmat(max(H.GS,[],3),[1,1,3]);
    set(GS_Handle,'cData',RGB_I)
else
    switch get(varargin{1},'tag')
        case 'RegionCheck'
            Current_Selection=str2double(get(varargin{1},'string'));
            set(H.Region_Select(~ismember(1:numel(H.Region_Select),Current_Selection)),'value',0)
            Current_ROI=Current_Selection;
        case 'Image'
            
            Click_Point=get(get(varargin{1},'parent'),'currentpoint');
            Click_Point=round(Click_Point(1,1:2));
            mWS=max(H.WS,[],3);
            if mWS(Click_Point(2),Click_Point(1))==0
            elseif mWS(Click_Point(2),Click_Point(1))~=Current_ROI
                All_Regions=regionprops(logical(H.WS),'pixellist');
                for i=1:numel(All_Regions)
                    if sum(ismember(unique(All_Regions(i).PixelList(:,1:2),'rows'),[Click_Point(1),Click_Point(2)],'rows'))==1
                        Match_Region=i ;
                        break
                    end
                end
                
                for i=1:size(All_Regions(Match_Region).PixelList,1)
                H.WS(All_Regions(Match_Region).PixelList(i,2),...
                All_Regions(Match_Region).PixelList(i,1),...
                All_Regions(Match_Region).PixelList(i,3))=Current_ROI;
                end
                
                set(get(H.IM_Axes,'children'),'cdata',label2rgb(max(H.WS,[],3)))
                
            end
    end
     GS_Handle=get(H.GS_Axes,'children');
            tWS=H.WS;
            tWS(tWS~=Current_ROI)=0;
            RGB_I=repmat(max(H.GS,[],3),[1,1,3]);
            RGB_I(:,:,2)=RGB_I(:,:,2)-uint8(max(tWS,[],3))*255;
            RGB_I(:,:,3)=RGB_I(:,:,3)-uint8(max(tWS,[],3))*255;
            set(GS_Handle,'cData',RGB_I)
            set(H.fh,'userdata',H)
      
end
end
function []=Done(varargin)
set(varargin{1},'userdata',2)
end