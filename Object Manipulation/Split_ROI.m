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
for i=1:3
Split_ROI{1,i}=Mod_ROIs{1,i}(Split_Index,:);
Mod_ROIs{1,i}(Split_Index,:)=[];
end
switch Mode
    case 'Manual'
       [BaseImage,New_ROIs]=Manual_Split(Split_ROI,handle);
        
        
    case 'Watershed'
    case 'Hull Dist'
    case 'Future'
end
%Adding the index of the newly split objects should be universal 
delIndex=Split_ROI{2}{3};
[BaseImage,New_ROIs]=Assign_mROI(BaseImage,New_ROIs,data);
New_ROIs=ROI_to_DataStruct(New_ROIs,BaseImage);

if data{10}(1).Channel_Master==Channel_Choice
    data=Configure_mROI(New_ROIs,data,delIndex);
    set(handle.MasterROIMenu,'string',['None',arrayfun(@(x) num2str(x),1:size(data{9}{data{10}(1).Channel_Master}{2,9},1),'uniformoutput',0)])
set(handle.ChannelMenu,'value',Channel_Choice)
set(handle.DisplayModeMenu,'value',Current_Display)
ChangeDisplay(handle.fh,[],7)
end

for i=1:3
Mod_ROIs{1,i}=vertcat(Mod_ROIs{1,i},New_ROIs{1,i});
end

delta_ROIs=cell(numel(Mod_ROIs),2);
%delta ROIs column 2 == 1 flag to delete, 2 would be add
delta_ROIs{1,1}=Split_ROI;
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

[W,H,D]=size(Split_ROI{2}{1,1});
Y=Split_ROI{3}(1,2);X=Split_ROI{3}(1,1); Z=Split_ROI{3}(1,3);
[A,B,C,D]=Crop_Image(false(handle.IMSize),X,Y,Z,H,W,D,.2);

Binary_Image=logical(A);
GrayScale_Image=uint8(A);
if X<=1
    X=2;
end
if Y<=1
    Y=2;
end
if Z<=1
    Z=2;
end

Binary_Image((Y-C):(Y-C)+size(Split_ROI{2}{1,1},1)-1,...
    (X-B):(X-B)+size(Split_ROI{2}{1,1},2)-1,...
    (Z-D):(Z-D)+size(Split_ROI{2}{1,1},3)-1)=Split_ROI{2}{1,1};
GrayScale_Image((Y-C):(Y-C)+size(Split_ROI{1}{1,1},1)-1,...
    (X-B):(X-B)+size(Split_ROI{1}{1,1},2)-1,...
    (Z-D):(Z-D)+size(Split_ROI{2}{1,1},3)-1)=Split_ROI{1}{1,1};
RGB_Image=repmat(max(GrayScale_Image,[],3),[1,1,3]);
RGB_Image(:,:,2)=RGB_Image(:,:,2)-uint8(max(Binary_Image,[],3))*255;
RGB_Image(:,:,3)=RGB_Image(:,:,3)-uint8(max(Binary_Image,[],3))*255;

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
BaseImage=cell(numRegions,3);
for i=1:numRegions
    [bigimMAP,~]=roipoly(imresize(Image,4));
    imMAP=repmat(imresize(bigimMAP,.25),[1,1,size(Binary_Image,3)]);
    clear bigimMAP
    
    New_ROIs{i,1}=regionprops(logical(uint8(Binary_Image)*255-( uint8(~imMAP)*255)),'image','pixellist','boundingbox');
    BaseImage{i,1}=GrayScale_Image-( uint8(~imMAP)*255);
    BaseImage{i,3}=Split_ROI{3}-([X,Y,Z]-[B+1,C+1,D+1]);
    
end
close(h)
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
    data{1}.MasterExpansion);

data{9}{MChan}{2,9}=[data{9}{MChan}{2,9};mROI_data];

[data]=Map_New_mROI(data);

rmROI=[data{9}{data{10}(1).Channel_Master}{2,9}(cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(:,2))==delIndex,2),get(handle.ChannelMenu,'value')];
MasterROI_Removal(data,rmROI)
data=guidata(data{1}.fh);

end

