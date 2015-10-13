function []=Set_MetaData(varargin)
data = guidata(varargin{1});
handles=data{1};
metaData=data{10}(get(handles.ChannelMenu,'value'));
Choice=varargin{3};
Channels=get(handles.ChannelMenu,'string');

try metaData.SimSet;
catch
    
metaData.SimSet=cell(1,numel(data{10}));    
end
switch Choice
    case 11
        prompt={'Enter Image ID',...
            'Enter Image Number',...
            sprintf('Enter %s Channel ID',Channels{get(handles.ChannelMenu,'value')}),...
            sprintf('Enter %s Channel Dye',Channels{get(handles.ChannelMenu,'value')}),...
            sprintf('Enter %s Channel Color',Channels{get(handles.ChannelMenu,'value')}),...
            'Enter Other'};
        name='Set Channel Data';
        numlines=1;
       
        defaultanswer={metaData.Image_ID,...
            metaData.Image_Number,...
            metaData.Channel_ID,...
            metaData.Channel_Dye,...
            metaData.Channel_Color,...
            metaData.Other};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        metaData.Image_ID=answer{1};
        metaData.Image_Number=answer{2};
        metaData.Channel_ID=answer{3};
        metaData.Channel_Dye=answer{4};
        metaData.Channel_Color=answer{5};
        metaData.Other=answer{6};
        Chan=get(handles.ChannelMenu,'String');
        Chan{get(handles.ChannelMenu,'Value')}=metaData.Channel_ID;
        set(handles.ChannelMenu,'String',Chan);
    case 12
        prompt={'Enter X Calibration',...
            'Enter Y Calibration',...
            'Enter Z Calibration',...
            'Enter Wavelength',...
            'Enter Magnification',...
            'Enter Numerical Apeture',...
            'Enter Refractive Index',...
            'Enter Immersion Media'};
        name='Set Channel Data';
        numlines=1;
       
        defaultanswer={num2str(metaData.CaliMetaData.XCal),...
            num2str(metaData.CaliMetaData.YCal),...
            num2str(metaData.CaliMetaData.ZCal),...
            num2str(metaData.CaliMetaData.Dye_Wavelength),...
            num2str(metaData.CaliMetaData.Mag),...
            num2str(metaData.CaliMetaData.Numerical_Aperture),...
            num2str(metaData.CaliMetaData.Refractive_Index),...
            metaData.CaliMetaData.Immersion_Media};
        
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        
        if ~isempty(metaData.SimSet{1,2})
        oCali=[metaData.CaliMetaData.XCal,metaData.CaliMetaData.YCal,metaData.CaliMetaData.ZCal];
        nCali=[str2double(answer{1}),str2double(answer{2}),str2double(answer{3})];
        SS=metaData.SimSet(:,2);
            for i=1:size(SS,1)
            RP=SS{i}./repmat(oCali,size(SS{i},1),1);
            metaData.SimSet{i,2}=RP.*repmat(nCali,size(SS{i},1),1);
            
            end
        end
        metaData.CaliMetaData.XCal=str2double(answer{1});
        metaData.CaliMetaData.YCal=str2double(answer{2});
        metaData.CaliMetaData.ZCal=str2double(answer{3});
        metaData.CaliMetaData.Dye_Wavelength=str2double(answer{4});
        metaData.CaliMetaData.Mag=str2double(answer{5});
        metaData.CaliMetaData.Numerical_Aperture=str2double(answer{6});
        metaData.CaliMetaData.Refractive_Index=str2double(answer{7});
        metaData.CaliMetaData.Immersion_Media=answer{8};
    case 13
        [filename,pathName,~]=uigetfile;
        addpath(pathName)
        L=load(strcat(pathName,filename));
        loaddata=L.data;
        mData=loaddata(arrayfun(@(x) isstruct(x{1}),loaddata));
        metaData=mData{1};
        data = guidata(varargin{1});
        handles=data{1};
    case 21
        MetaDataViewer(Channels,get(handles.ChannelMenu,'value'),data{10},1) ;
    case 22
        MetaDataViewer(Channels,get(handles.ChannelMenu,'value'),data{10},2) ;
end
setFN=fieldnames(data{10}(get(handles.ChannelMenu,'value')));
nFN=fieldnames(metaData);

if numel(metaData)>1
    
    metaData=rmfield(metaData,{nFN{~ismember(nFN,setFN)}});
    
    S=get(handles.ChannelMenu,'string');
    for i=1:numel(metaData)
        metaData(i).Channel_Master='None';
        data{10}(i)=metaData(i);
        S{i}=metaData(i).Channel_ID;
    end
    set(handles.ChannelMenu,'string',S);
    
else
    fn_Meta=fieldnames(metaData);
    Extra_Field=fn_Meta(~ismember(fn_Meta,fieldnames(data{10}(get(handles.ChannelMenu,'value')))));
    metaData=rmfield(metaData,Extra_Field);
    data{10}(get(handles.ChannelMenu,'value'))=metaData;
end

[~,C]=size(data{3});
for i=1:C
    if i==(get(handles.ChannelMenu,'value'));
    else
        data{10}(i).Image_ID=data{10}(get(handles.ChannelMenu,'value')).Image_ID;
        data{10}(i).Image_Number=data{10}(get(handles.ChannelMenu,'value')).Image_Number;
        data{10}(i).CaliMetaData.XCal=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.XCal;
        data{10}(i).CaliMetaData.YCal=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.YCal;
        data{10}(i).CaliMetaData.ZCal=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.ZCal;
        data{10}(i).CaliMetaData.Mag=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.Mag;
        data{10}(i).CaliMetaData.Numerical_Aperture=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.Numerical_Aperture;
        data{10}(i).CaliMetaData.Refractive_Index=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.Refractive_Index;
        data{10}(i).CaliMetaData.Immersion_Media=data{10}(get(handles.ChannelMenu,'value')).CaliMetaData.Immersion_Media;
    end
end

ID=unique({metaData.Image_ID});
Num=unique({metaData.Image_Number});
set(handles.Title,'string',sprintf('Image: %s \n Number: %s',ID{1},Num{1}));
set(handles.Title,'HorizontalAlignment','Center')

if  metaData(1).CaliMetaData.XCal ~= metaData(1).CaliMetaData.YCal
    error('Your Voxels are not Square in XY')
    
end
if strcmp(get(handles.MasterSet,'visible'),'off')
    Chan_Handles=handles.byChanObj;
    for i=1:numel(Chan_Handles)
        A=get(Chan_Handles(i),'string');
        B=regexp(A,':','split');
        set(Chan_Handles(i),'string',sprintf('%s: %d',data{10}(i).Channel_ID,str2double(B{2})))
    end
end

guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)]);

end

%% Meta Data Viewer Functions

function [ ] = MetaDataViewer(Channels,InputChan,MetaData,InputRequest)
MD.fh = figure('units','normalized',...
    'position',[.05 .55 .2 .4],...
    'menubar','none',...
    'name','Meta Data',...
    'numbertitle','off',...
    'resize','off');
MD.ChannelTitle=uicontrol('style','text','units','normalized',...
    'position',[.0,.04,.20,.05],'string','Chan:',...
    'backgroundcolor',get(MD.fh,'color'),'fontsize',10);
MD.ChannelMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.16,.05,.25,.05],'string',Channels,...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',1,'callback',{@ChannelChoice,MetaData});
MD.DisplayTitle=uicontrol('style','text','units','normalized',...
    'position',[.45,.04,.20,.05],'string','Data Type:',...
    'backgroundcolor',get(MD.fh,'color'),'fontsize',10);
MD.DisplayMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.66,.05,.25,.05],'string',{'Channel Info','Acqusition Info'},...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',InputRequest);
MD.DisplayMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.66,.05,.25,.05],'string',{'Channel Info','Acqusition Info'},...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',InputRequest,'callback',{@DisplayChoice,InputChan,[],MetaData});
MD.CVal=uicontrol('style','text','string',' ','visible','off','tag','CVal', 'backgroundcolor',get(MD.fh,'color'), 'position',[.01,.01,.01,.01]);
MD.HVal=uicontrol('style','text','string',' ','visible','off','tag','AVal', 'backgroundcolor',get(MD.fh,'color'), 'position',[.01,.01,.01,.01]);

switch InputRequest
    case 1
        DisplayChoice(MD,InputChan,MetaData,1)
        
    case 2
     DisplayChoice(MD,InputChan,MetaData,2)
end
guidata(MD.fh,{MD});
end

function []=ChannelChoice(varargin)
data=guidata(varargin{1});
H=data{1};

DisplayChoice(H,get(H.ChannelMenu,'value'),varargin{3},get(H.DisplayMenu,'Value'))

end
function []=DisplayChoice(varargin)

if isstruct(varargin{1})
    Chan=varargin{2};
    MetaData=varargin{3};
    mData=MetaData(Chan);
    H=varargin{1};
else
    handles=guidata(varargin{1});
    H=handles{1};
    Chan=get(H.ChannelMenu,'Value');
    mData=varargin{5}(Chan);
    varargin{4}=get(H.DisplayMenu,'Value');
end
set(findall(0,'tag','CVal'),'Visible','off')
set(findall(0,'tag','AVal'),'Visible','off')
if varargin{4}==1
    set(findall(0,'tag','CVal'),'Visible','on')
    
    H.CVal.IID=uicontrol('style','text','units','normalized',...
        'position',[.0,.90,1,.06],'string',sprintf('Image ID: %s',mData.Image_ID),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
    H.CVal.INum=uicontrol('style','text','units','normalized',...
        'position',[.0,.80,1,.06],'string',sprintf('Image Number: %s',mData.Image_Number),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
    H.CVal.CID=uicontrol('style','text','units','normalized',...
        'position',[.0,.7,1,.06],'string',sprintf('Channel ID: %s',mData.Channel_ID),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
    H.CVal.CD=uicontrol('style','text','units','normalized',...
        'position',[.0,.6,1,.06],'string',sprintf('Channel Dye: %s',mData.Channel_Dye),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
    H.CVal.CC=uicontrol('style','text','units','normalized',...
        'position',[.0,.5,1,.06],'string',sprintf('Channel Color: %s',mData.Channel_Color),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
    H.CVal.O=uicontrol('style','text','units','normalized',...
        'position',[.0,.4,1,.06],'string',sprintf('Other: %s',mData.Other),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','CVal');
else
    set(findall(0,'tag','AVal'),'Visible','off')
    H.AVal.XC=uicontrol('style','text','units','normalized',...
        'position',[.0,.90,1,.06],'string',sprintf('XCal: %d',mData.CaliMetaData.XCal),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.YC=uicontrol('style','text','units','normalized',...
        'position',[.0,.8,1,.06],'string',sprintf('YCal: %d',mData.CaliMetaData.YCal),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.ZC=uicontrol('style','text','units','normalized',...
        'position',[.0,.7,1,.06],'string',sprintf('ZCal: %d',mData.CaliMetaData.ZCal),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.DW=uicontrol('style','text','units','normalized',...
        'position',[.0,.6,1,.06],'string',sprintf('Dye Wavelength: %d',mData.CaliMetaData.Dye_Wavelength),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.M=uicontrol('style','text','units','normalized',...
        'position',[.0,.5,1,.06],'string',sprintf('Magnification: %d',mData.CaliMetaData.Mag),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.NA=uicontrol('style','text','units','normalized',...
        'position',[.0,.4,1,.06],'string',sprintf('Numerical Aperture: %d',mData.CaliMetaData.Numerical_Aperture),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.RI=uicontrol('style','text','units','normalized',...
        'position',[.0,.3,1,.06],'string',sprintf('Refractive Index: %d',mData.CaliMetaData.Refractive_Index),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    H.AVal.IM=uicontrol('style','text','units','normalized',...
        'position',[.0,.2,1,.06],'string',sprintf('Immersion Media: %s',mData.CaliMetaData.Immersion_Media),...
        'backgroundcolor',get(H.fh,'color'),'fontsize',14,'fontweight','bold','tag','AVal');
    
end

end

