function []=LoadImage(varargin)

data=guidata(varargin{1});
LoadMode=varargin{3};
handles=data{1};
if LoadMode~=4
data=ResetGUI(handles);
end

switch LoadMode
    case 1
        %Import Image Series
        [~, Color_Chan,Path]=ImportImageSequence;
        Images=cell(numel(Color_Chan),2);
        for k=1:numel(Color_Chan)
            Images(k,:)=[toUint8(Color_Chan(k,1)),{sprintf('Chan %d',k)}];
        end
        HasMeta=false;
    case 2
        %Import Projection
        [FileName,Path] =uigetfile('Choose Projection Files','MultiSelect','on');
        Images=cell(numel(FileName),2);
        for k=1:numel(FileName)
            A=importdata(strjoin({Path,FileName{k}},''));
            Images(k,:)=[toUint8({A(:,:,1)}),{sprintf('Chan %d',k)}];
        end
        HasMeta=false;
    case 3
        %Import ND2
        [ND2,Path]=uigetfile('*.nd2','Select ND2');
        Vol=bfopen(strcat(Path,ND2));
        f=Vol{2}.keys;
        z=1;
        while f.hasNext
            Key{z,1}=f.nextElement;
            Vol{2}.get(Key{1})
            z=z+1;
        end
        Data=cell(numel(Key),1);
        for i=1:numel(Key)
            Data{i,1}=Vol{2}.get(Key{i});
        end
        Image_Size_Info=arrayfun(@(x) x{1}(3:end),arrayfun(@(x) regexp(x,';','split'),Vol{1}(:,2)),'Uniformoutput',0);
        Image_Size_Info=vertcat(Image_Size_Info{:});
        Total_IM_Dim=arrayfun(@(x) str2double(x{1}{2}),arrayfun(@(x) regexp(x,'/','split'),Image_Size_Info(1,:)));
        Plane_Chan_List=arrayfun(@(x) str2double(x{1}{2}),arrayfun(@(x) regexp(x,'=','split'),arrayfun(@(x)(x{1}{1}),arrayfun(@(x) regexp(x,'/','split'),Image_Size_Info),'uniformoutput',0)));
        if size(Plane_Chan_List,2)==1
            Plane_Chan_List=[ones(numel(Plane_Chan_List),1),Plane_Chan_List];
        end
        if numel(Total_IM_Dim)==1
            Total_IM_Dim=[1,Total_IM_Dim];
        end
        nD_Image=cell(size(Total_IM_Dim(2),1),1);
        for i=1:size(Plane_Chan_List,1)
            nD_Image{Plane_Chan_List(i,2),1}(:,:,Plane_Chan_List(i,1))=Vol{1}{i,1};
        end
        ChanNames=cell(size(Total_IM_Dim,1),1);
        
        for k=1:Total_IM_Dim(2)
            if isempty(Data(~cellfun(@isempty,arrayfun(@(x) strfind(x,strcat('CH',num2str(k),'ChannelDyeName')),Key))))
                ChanNames{k,1}=strcat('Chan',num2str(k));
            else
                ChanNames(k,1)=Data(~cellfun(@isempty,arrayfun(@(x) strfind(x,strcat('CH',num2str(k),'ChannelDyeName')),Key)));
            end
        end
        Z_Step_Cal=mode(diff(unique(cell2mat(Data(~cellfun(@isempty,arrayfun(@(x) strfind(x,'Z position for position, plane'),Key)))))));
        XY_Cal=Data{~cellfun(@isempty,arrayfun(@(x) strfind(x,'Global dCalibration'),Key))};
        Color_Chan=nD_Image;
        Images=cell(numel(Color_Chan),2);
        for k=1:numel(Color_Chan)
            Images(k,:)=[toUint8(Color_Chan(k,1)),{Data{~cellfun(@isempty,arrayfun(@(x) strfind(x,sprintf('CH%sChannelDyeName',num2str(k))),Key))}}];
        end
        HasMeta=true;
        
    case 4
        %Import for data strucutre alone 
        
        data=guidata(varargin{1});
        Images=cell(numel(data{10}),2);
        
        for k=1:numel(data{10})
            try
                Image=data{9}{k}(1,2);
            catch
                Image=data{2}(1,k);                
            end
            Images(k,:)=[toUint8(Image),{data{10}(k).Channel_ID}];
        end
        Path=data{10}(1).FilePath;

        MetaData=data{10};
        HasMeta=true;        
end
%By passes setting metadata and images in because they already based in as
%they should be
if LoadMode~=4
    numChan=numel(Images)/2;
    Channels=cell(1,numChan);
    Signals=cell(20,numChan);
    MetaData=data{10};
    
    MetaData.FilePath=Path;
    MetaData(1).ManipNum=1;
    MetaData=repmat(MetaData,1,numChan);
    Color=[{'blue'},{'green'},{'red'},{'yellow'}];
    
    for i=1:numChan
        Channels(1,i)=Images(i,2);
        Signals(1,i)=Images(i,1);
        MetaData(i).Channel_Color=Color{i};
        MetaData(i).Channel_ID=Images{i,2};
        MetaData(i).Channel_Dye=Images{i,2};
        data{2}{1,i}=Images{i,1};
        data{3}{1,i}=max(Images{i,1},[],3);
        data{5}{1,i}=cell(1,2);
        data{6}{1,i}=cell(1,5);
        data{9}(1,i)=cell(1,1);
        data{7}{1,i}=zeros(1,3);
        data{4}{1,i}='Raw Stack';
    end
    if HasMeta
        for i=1:numChan
            MetaData(i).CaliMetaData.XCal=XY_Cal;
            MetaData(i).CaliMetaData.YCal=XY_Cal;
            MetaData(i).CaliMetaData.ZCal=Z_Step_Cal;
        end
    end
    data{10}=MetaData;    
end

data{11}=cell(20,numel(data{10}));
if handles.MasterSet_Toggle
V='on';
set(handles.MasterROIMenu,'visible','on','enable','on','value',1,'string',vertcat('None',arrayfun(@(x) num2str(x),(1:size(data{9}{data{10}(1).Channel_Master}{2,9},1)),'uniformoutput',0)'));
set(handles.MasterROITitle,'visible','on')
set(handles.MasterSet,'visible','off')
else
V='off';    
end
for i=1:numel(data{10})
    handles.byChanObj(i)=uicontrol('style','text','units','normalized',...
        'position',[.05,(.35-(.05*(i-1))),.25,.05],...
        'string',sprintf('%s: NaN',data{10}(i).Channel_ID),'fontsize',14,...
        'backgroundcolor',get(handles.fh,'Color'),...
        'fontweight','bold','Horizontalalignment','left','visible',V);
data{8}{1,i}=[{'Raw Image'},{'Raw Image'}];    
data{11}(:,i)=repmat({[{[{'Base'},{'Base'}]},1]},20,1);

end

set(handles.Title,'string', [{sprintf('Image: %s',MetaData(1).Image_ID)};{sprintf('Number: %s',MetaData(1).Image_Number)}])
handles.IMSize=size(Images{1,1});
set(handles.IMAxes,'XLim',[0 size(Images{1,1},2)])
set(handles.IMAxes,'YLim',[0 size(Images{1,1},1)])
handles.ImagePlace_Handle=get(handles.IMAxes,'Children');
smallstep=1/(size(Images{1,1},3)-1);
largestep=smallstep*5;
set(handles.SliceSlider,'sliderstep',[smallstep largestep])
set(handles.SliceSlider,'max',size(Images{1,1},3))
set(handles.ChannelMenu,'string',Images(:,2)')

handles.ImagePlace_Handle=findobj(handles.ImagePlace_Handle,'type','image');
set(handles.ImagePlace_Handle,'cData',repmat(max(Images{1,1},[],3),[1,1,3]))

handles.CurrentView=max(Images{1,1},[],3);
handles.ManipulationNumber=data{10}(1).ManipNum;
handles.cLabelMatrix=cell(5,numel(data{10}));
handles.cLabelMatrix_Toggle=false(25,numel(data{10}));

set(handles.DisplayModeMenu,'Value',1)
set(handles.OverlayMenu,'string','None','value',1)
try
set(handles.DisplayModeMenu,'string',data{9}{1}(~cellfun(@isempty,data{9}{1}(:,4)),4));    
catch
set(handles.DisplayModeMenu,'string',data{4}(~cellfun(@isempty,data{4}(:,1)),1));   
end
guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)]);


end