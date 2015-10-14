function []= ThreshPortalGUI(varargin)
ImportData=varargin{1};
data=guidata(varargin{1});
handles=data{1};
MasterROI_Choice=get(handles.MasterROIMenu,'value');
Channel_Choice=get(handles.ChannelMenu,'value');
Display_Choice=get(handles.DisplayModeMenu,'value');
MChan=data{10}(1).Channel_Master;
Channels=get(handles.ChannelMenu,'string');
DisplayModes=get(handles.DisplayModeMenu,'string');
if ~iscell(DisplayModes)
    DisplayModes={DisplayModes};
end
% Extract the Image to apply the Segmentation Method to

        [RawImage]=Extract_Data(data,[2],Channel_Choice,Display_Choice);  




if islogical(RawImage{1,1})
    IMType='Binary';   
else
    IMType='Gray Scale';
end

ThreshDialog.fh = figure('units','normalized',...
    'position',[.77 .5 .2 .4],...
    'menubar','none',...
    'name',varargin{3},...
    'numbertitle','off',...
    'resize','off');

ThreshDialog.Channel=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.05 .9 .8 .05],...
    'String',sprintf('Channel: %s',Channels{Channel_Choice}),...
    'fontsize',10,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),...
    'HorizontalAlignment','left','UserData',Channel_Choice);

ThreshDialog.InputImage=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.05 .85 .9 .05],...
    'String',sprintf('Input Image: %s',DisplayModes{Display_Choice}),...
    'fontsize',10,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),...
    'HorizontalAlignment','left','UserData',Display_Choice);
ThreshDialog.InputImageType=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.05 .80 .8 .05],...
    'String',sprintf('Input Type: %s',IMType),...
    'fontsize',10,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),...
    'HorizontalAlignment','left');
if strcmp(IMType,'Binary')
    set(ThreshDialog.InputImage,'string',sprintf('Obj Source: %s',DisplayModes{Display_Choice}))
    ThreshDialog.ModImageTitle=uicontrol('style','text',...
        'unit','normalized',...
        'position',[.45 .85 .9 .05],...
        'String',sprintf('Image:'),...
        'fontsize',10,...
        'fontweight','bold',...
        'backgroundcolor',get(ThreshDialog.fh,'color'),...
        'HorizontalAlignment','left','UserData',Display_Choice);

    [GS_Images]=Extract_Data(data,[2],Channel_Choice,...
        find(arrayfun(@(x) isa(x{1},'uint8'),data{2}(:,Channel_Choice))));
    [GS_Names]=Extract_Data(data,[4],Channel_Choice,...
        find(arrayfun(@(x) isa(x{1},'uint8'),data{2}(:,Channel_Choice))));
ThreshDialog.ModImageMenu=uicontrol('style','popupmenu',...
    'unit','normalized',...
    'position',[.6 .85 .35 .05],...
    'String',GS_Names,...
    'fontsize',10,...
        'fontweight','bold',...
        'HorizontalAlignment','left','UserData',GS_Images);
end



ThreshDialog.HistSourse=uibuttongroup('unit','normalized',...
    'position',[.05 .625 .90 .15],...
    'title','Histogram Source',...
    'fontsize',11,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'parent',ThreshDialog.fh);
ThreshDialog.MaxPRadio  = uicontrol('Style','radio','String','Max',...
    'units','normalized','pos',[.0 .3 .45 .5],'parent',ThreshDialog.HistSourse,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',9,'HorizontalAlignment','left');
ThreshDialog.StackRadio  = uicontrol('Style','radio','String','Stack',...
    'units','normalized','pos',[.25 .3 .45 .5],'parent',ThreshDialog.HistSourse,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',9,'HorizontalAlignment','left');
ThreshDialog.MPRadio  = uicontrol('Style','radio','String','Mid',...
    'units','normalized','pos',[.5 .3 .25 .5],'parent',ThreshDialog.HistSourse,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',9,'HorizontalAlignment','left');
ThreshDialog.InMaster  = uicontrol('Style','radio','String','In Master',...
    'units','normalized','pos',[.7 .3 .25 .5],'parent',ThreshDialog.HistSourse,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',9,'HorizontalAlignment','left');
ThreshDialog.ThreshBasis=uibuttongroup('unit','normalized',...
    'position',[.05 .475 .90 .15],...
    'title','Thresholding Basis',...
    'fontsize',11,'SelectionChangeFcn',{@Option_Toggle,ThreshDialog},...
    'fontweight','bold','backgroundcolor',get(ThreshDialog.fh,'color'));
    
ThreshDialog.WIRadio  = uicontrol('Style','radio','String','Whole Image',...
    'units','normalized','pos',[0 .3 .35 .5],'parent',ThreshDialog.ThreshBasis,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left','enable','on','tag','Whole_Image');
ThreshDialog.ObjRadio  = uicontrol('Style','radio','String','By Object',...
    'units','normalized','pos',[.38 .3 .25 .5],'parent',ThreshDialog.ThreshBasis,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left','enable','on','tag','byObj');
ThreshDialog.MastROIRadio  = uicontrol('Style','radio','String','By mROI',...
    'units','normalized','pos',[.68 .3 .25 .5],'parent',ThreshDialog.ThreshBasis,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left','enable','on','tag','Master_ROI');
ThreshDialog.Exclusion=uibuttongroup('unit','normalized',...
    'position',[.05 .325 .90 .15],...
    'title','Exclusion',...
    'fontsize',11,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'parent',ThreshDialog.fh);
ThreshDialog.ExluMenu = uicontrol('Style','popupmenu','String','Size',...
    'units','normalized','pos',[.05 .3 .3 .5],'parent',ThreshDialog.Exclusion,...
    'backgroundcolor',[1 1 1],'fontsize',10,'HorizontalAlignment','left');
ThreshDialog.ExluVal=uicontrol('style','edit','units','normalized',...
    'position',[.35 .20 .1 .6],'string',1,'backgroundcolor',[1 1 1],...
    'fontsize',10,'parent',ThreshDialog.Exclusion);
ThreshDialog.EdgeRadio  = uicontrol('Style','checkbox','String','Edge',...
    'units','normalized','pos',[.45 .3 .2 .5],'parent',ThreshDialog.Exclusion,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left');
ThreshDialog.In_MasterBox  = uicontrol('Style','checkbox','String','mROI',...
    'units','normalized','pos',[.62 .3 .2 .5],'parent',ThreshDialog.Exclusion,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left');
ThreshDialog.In_MasterOis  = uicontrol('Style','checkbox','String','mPix',...
    'units','normalized','pos',[.82 .3 .15 .5],'parent',ThreshDialog.Exclusion,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left');

ThreshDialog.ConcGroup=uibuttongroup('unit','normalized',...
    'position',[.05 .20 .90 .15],...
    'title','Connectivity',...
    'fontsize',11,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'parent',ThreshDialog.fh);
ThreshDialog.FillRadio  = uicontrol('Style','checkbox','String','Fill Holes',...
    'units','normalized','pos',[.35 .3 .4 .3],'parent',ThreshDialog.ConcGroup,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','left');
ThreshDialog.ExpMenu = uicontrol('Style','text','String','ObjExp',...
    'units','normalized','pos',[.6 .3 .2 .4],'parent',ThreshDialog.ConcGroup,...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',10,'HorizontalAlignment','Left','visible','off');
ThreshDialog.ExpVal=uicontrol('style','edit','units','normalized',...
    'position',[.75 .20 .1 .6],'string',.2,'backgroundcolor',[1 1 1],...
    'fontsize',10,'parent',ThreshDialog.ConcGroup,'visible','off');


if strcmp(IMType,'Gray Scale')
    set(ThreshDialog.ObjRadio,'enable','off')
set(ThreshDialog.WIRadio,'value',1);

else  
set(ThreshDialog.WIRadio,'enable','off')
set(ThreshDialog.ObjRadio,'value',1);
set(ThreshDialog.ExpMenu,'visible','on');
set(ThreshDialog.ExpVal,'visible','on');
set(ThreshDialog.EdgeRadio,'value',1)
end
if MasterROI_Choice~=1
    set(ThreshDialog.WIRadio,'enable','off')    
set(ThreshDialog.MastROIRadio,'value',1);

end


if ~handles.MasterSet_Toggle
    set(ThreshDialog.InMaster,'enable','off')
    set(ThreshDialog.MastROIRadio,'enable','off')
    set(ThreshDialog.In_MasterOis,'enable','off')
    set(ThreshDialog.In_MasterBox,'enable','off')

end

if size(RawImage{1,1},3)~=1
    Dims=3;
else
    Dims=2;
end
ThreshDialog.Conc = uicontrol('Style','popupmenu','String','',...
    'units','normalized','pos',[.1 .20 .2 .6],'parent',ThreshDialog.ConcGroup,...
    'backgroundcolor',[1 1 1],'fontsize',10,'HorizontalAlignment','left');
ThreshDialog.ConcTitle = uicontrol('Style','text','String','',...
    'units','normalized','pos',[.0 .3 .1 .4],'parent',ThreshDialog.ConcGroup,'FontWeight','Bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),'fontsize',12,'HorizontalAlignment','Right');

if Dims==2
    set(ThreshDialog.Conc,'string',{4,8})
    set(ThreshDialog.ConcTitle,'string','2D')
else
    set(ThreshDialog.Conc,'string',{6,18,26})
    set(ThreshDialog.ConcTitle,'string','3D')
end



ThreshDialog.OutputImage=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.05 .15 .8 .05],...
    'String','Output Type: Binary',...
    'fontsize',12,...
    'fontweight','bold',...
    'backgroundcolor',get(ThreshDialog.fh,'color'),...
    'HorizontalAlignment','left');
ThreshDialog.OutPut_Type='Binary';
ThreshDialog.ApplySelection=uicontrol('style','pushbutton','units','normalized',...
    'position',[.05 .02 ,.4,.1],'string','Preview','backgroundcolor',...
    get(ThreshDialog.fh,'Color'),'fontsize',14,'FontWeight','bold','callback',{@Apply,ImportData});

%Modify options based on input type
switch get(ThreshDialog.fh,'Name')
    case 'Growth'
        set(ThreshDialog.StackRadio,'enable','off')
        set(ThreshDialog.MPRadio,'enable','off')
        set(ThreshDialog.InMaster,'enable','off')
        set(ThreshDialog.MaxPRadio,'enable','off')
        set(ThreshDialog.In_MasterOis,'value',1)
        
        set(ThreshDialog.MastROIRadio,'value',1)
        set(ThreshDialog.WIRadio,'enable','off')
end
Q=[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)];
guidata(handles.fh,Q)

guidata(ThreshDialog.fh,[{ThreshDialog},{RawImage},{handles},{0},get(varargin{1},'Userdata'),])
end


%Apply Function That simply guides the code into the seperate files that
%run the segementation and return the results
function []=Apply(varargin)
SelectionData=guidata(varargin{1});
sHandles=SelectionData{1};
iHandles=SelectionData{3};
Process_Type=get(sHandles.fh,'Name');
data=guidata(SelectionData{3}.fh);
[Image,HistImage]=Create_Input_Images(data,iHandles,sHandles);
Current_Chan=get(iHandles.ChannelMenu,'value');
Current_Display=get(iHandles.DisplayModeMenu,'value');
MasterROI_Choice=get(iHandles.MasterROIMenu,'value');

%Image Processing

switch Process_Type
    case 'Otsu'
        %Otsu
        [ROI]=Otsu_Filter(Image,HistImage,sHandles);
    case 'Manual'
        [ROI]=Manual_Filter(Image,sHandles);
    case'Integral'
        [ROI]=Integral_Filter(Image,HistImage,sHandles);
    case 'Growth'
        
        [ROI]=RegionGrowing_Filter(Image,sHandles); 
        
        
end

%Processingre Data to go back into the commit sructure

Image(cellfun(@isempty,ROI),:)=[];
ROI(cellfun(@isempty,ROI),:)=[];



if strcmp(sHandles.OutPut_Type,'Binary')
    FSS_data=cell(size(ROI,1),1);
    
    for i=1:size(ROI,1)
        
        %ROI_toDataStruct has been updated must change the way the input
        %goes in
        
        [FSS_data{i,1}]=ROI_to_DataStruct(ROI(i),Image(i,:));
    end
    
    FSS_data=vertcat(FSS_data{:});
    if ~isempty(FSS_data)
        if MasterROI_Choice==1
            FSS_data=[{vertcat(FSS_data{:,1})},{vertcat(FSS_data{:,2})},{vertcat(FSS_data{:,3})}];
            MChan=nan;
            if iHandles.MasterSet_Toggle
                MChan=data{10}(1).Channel_Master;
                PolyGons=data{9}{data{10}(1).Channel_Master}{2,9}(:,1);
                for j=1:size(FSS_data{2},1)
                    Match=false(size(PolyGons,1),1);
                    for ii=1:size(PolyGons,1)
                        Match(ii,1)=inpolygon(FSS_data{2}{j,4}(1),FSS_data{2}{j,4}(2),PolyGons{ii}(:,1),PolyGons{ii}(:,2));
                    end
                    FSS_data{2}{j,3}=cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(Match,2));
                end
                
                
            end
        end
        delta_ROIs=cell(size(FSS_data{1},1),2);
        
        for i=1:size(FSS_data{1},1)
            delta_ROIs{i,1}=[{FSS_data{1}(i,:)},{FSS_data{2}(i,:)},{FSS_data{3}(i,:)}];
            delta_ROIs{i,2}=2;
        end
    else
        FSS_data=cell(1,3);
        delta_ROIs=cell(1,2);
    end
    
    New_Pos=numel(get(iHandles.DisplayModeMenu,'string'))+1;
    
    if ~iscell(get(iHandles.DisplayModeMenu,'string'))
        Menu=vertcat({get(iHandles.DisplayModeMenu,'string')},{sprintf('Manip: %d',iHandles.ManipulationNumber)});
    else
        Menu=vertcat(get(iHandles.DisplayModeMenu,'string'),{sprintf('Manip: %d',iHandles.ManipulationNumber)});
    end
    
    [data]=Add_Data(data,[4,8],...
        [{Menu{end}},{[{CallBack_Value_String(iHandles.DisplayModeMenu)},{sprintf('Manip: %d',iHandles.ManipulationNumber)}]}],...
        Current_Chan,New_Pos);
    set(iHandles.InputImage,'string',sprintf('Input Image: %s',CallBack_Value_String(iHandles.DisplayModeMenu)))
    set(iHandles.InputImage,'string',sprintf('Input Image: %s',CallBack_Value_String(iHandles.DisplayModeMenu)))
    set(iHandles.Type,'string','Image Type: Binary')
    set(iHandles.Seg,'string','Segmented: Yes')
    set(iHandles.OverlayMenu,'string',[{'None'},{'Composite'},{'Color'},{'Numbered'}])
    set(iHandles.OverlayMenu,'enable','on')
    
    set(iHandles.DisplayModeMenu,'string',Menu)
    set(iHandles.DisplayModeMenu,'value',numel(Menu))
  
    
    if data{1}.MasterSet_Toggle~=1
        data{1}.MasterExpansion(numel(Menu),1)=str2double(get(sHandles.ExpVal,'string'));
    end
    
    if MasterROI_Choice==1
        if  data{1}.MasterSet_Toggle==1
            if size(data{9}{Current_Chan},1)>2
                Current_Disp=get(iHandles.DisplayModeMenu,'value');
                for i=2:8
                    data{i}{2,Current_Chan}=data{9}{Current_Chan}{2,i};
                    data{i}{1,Current_Chan}=data{9}{Current_Chan}{1,i};
                end
                data{4}{Current_Disp,Current_Chan}=data{9}{Current_Chan}{Current_Disp,4};
                data{8}{Current_Disp,Current_Chan}=data{9}{Current_Chan}{Current_Disp,8};
                data{9}{Current_Chan}=[];
            end
            
            if MChan==Current_Chan
                set(data{1}.MasterROIMenu,'value',1,'visible','off')
                set(data{1}.MasterROITitle,'visible','off')
                data{1}.MasterSet_Toggle=0;
                set(data{1}.MasterSet,'value',0,'visible','on')
                NumChan=numel(data{9});
                FSS_data{2}(:,3)=arrayfun(@(x) {x},1:numel(FSS_data{2}(:,3)))';
                for i=1:NumChan
                    set(data{1}.byChanObj(i),'visible','off')
                    if ~isempty(data{9}{i})
                        data{9}{i}{2,6}(:,3)=repmat({0},size(data{9}{i}{2,6}(:,3),1),1);
                    end
                end
                set(data{1}.ApplySelection,'callback',{@Apply_Threshold,1,cell(1,2)})
            end
            
            data{1}.MasterExpansion(numel(Menu),1)=str2double(get(sHandles.ExpVal,'string'));
        end

        %set(iHandles.ApplySelection,'callback',{@Apply_Threshold,1,cell(1,2)})
        Manipulation_PostProcess(FSS_data,delta_ROIs,data,'New')
        
    else
        
        set(iHandles.ApplySelection,'callback',{@Apply_Threshold,3,cell(1,2)})
        Manipulation_PostProcess(FSS_data,delta_ROIs,data,'Modify')
    end
else
    
end
            close(sHandles.fh)

end

function []=Option_Toggle(varargin)
handles=guidata(varargin{1});
handles=handles{1};
if strcmp(get(varargin{2}.NewValue,'tag'),'byObj')
Mode='on';
value=1;
else
Mode='off';
value=0;
end
set(handles.EdgeRadio,'value',value)

set(handles.ExpMenu,'visible',Mode)
set(handles.ExpVal,'visible',Mode)
end