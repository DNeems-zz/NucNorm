function [] = NucNorm(varargin)
%% Intialize feautres of the GUI
BlankImage=uint8(zeros(1024,1024));
Image.fh = figure('units','normalized',...
    'position',[.05 .2 .7 .7],...
    'menubar','none',...
    'name','NucNorm',...
    'numbertitle','off',...
    'resize','off','tag','IMMaster');
[ImR,ImC]=size(BlankImage);
Image.IMAxes=axes('units','normalized',...
    'position',[.33 .12 .52 .77],'Xlim',[0 ImC],'YLim',[0 ImR],'UserData',0);
axis off
image('Parent', Image.IMAxes, 'CData', repmat(BlankImage,[1,1,3]));
set(Image.IMAxes,'YDir','reverse')
Image.Title=uicontrol('style','text','units','normalized',...
    'position',[.33,.90,.55,.07],...
    'string','None','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','HorizontalAlignment','Center');
Image.Type=uicontrol('style','text','units','normalized',...
    'position',[.05,.85,.2,.05],...
    'string','Image Type: Gray Scale','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','HorizontalAlignment','Left');
Image.InputImage=uicontrol('style','text','units','normalized',...
    'position',[.05,.80,.2,.05],...
    'string','Input Image: None','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','HorizontalAlignment','Left');
Image.Seg=uicontrol('style','text','units','normalized',...
    'position',[.05,.75,.2,.05],...
    'string','Segmented: No','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','HorizontalAlignment','Left');

Image.OverlayTitle=uicontrol('style','text','units','normalized',...
    'position',[.05,.60,.2,.05],...
    'string','Overlay Modes','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','HorizontalAlignment','Center');
Image.OverlayMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.05,.55,.2,.05],...
    'string','None','fontsize',14,...
    'backgroundcolor',[1 1 1],...
    'fontweight','bold','callback',{@ChangeDisplay,6},'Enable','on');
Image.ObjCount=uicontrol('style','text','units','normalized',...
    'position',[.05,.48,.2,.05],...
    'string','Num ROIs: NaN','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold');

Image.ChannelTile=uicontrol('style','text','units','normalized',...
    'position',[0,.05,.15,.05],'string','Current Channel',...
    'backgroundcolor',get(Image.fh,'Color'),'fontsize',16,...
    'fontweight','bold','HorizontalAlignment','Right');
Image.ChannelMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.16,.05,.1,.05],'string','None',...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',1,'callback',{@ChangeDisplay,1});

Image.AdvancedDisplay=uicontrol('style','checkbox','units','normalized',...
    'position',[.05,.01,.2,.05],'string','Toggle Display Options','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',10,'FontWeight','bold','UserData',0,'callback',{@DisplayToggle});
Image.DisplayModeTile=uicontrol('style','text','units','normalized',...
    'position',[.3,.05,.2,.05],'string','Current Image',...
    'backgroundcolor',get(Image.fh,'Color'),'fontsize',16,...
    'fontweight','bold','HorizontalAlignment','Left');
Image.DisplayModeMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.41,.05,.3,.05],'string','Raw Image',...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',1,'callback',{@ChangeDisplay,2});
Image.DisplayTypeTile=uicontrol('style','text','units','normalized',...
    'position',[.335,.03,.2,.035],'string','Proj Type',...
    'backgroundcolor',get(Image.fh,'Color'),'fontsize',16,...
    'fontweight','bold','HorizontalAlignment','Left','visible','off');
Image.DisplayTypeMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.41,.05,.3,.01],'string',[{'Max Int'},{'Mean Int'},{'Min Int'},{'Mid Plane'},{'By Plane'}],...
    'backgroundcolor',[1 1 1],'fontsize',10,'value',1,'callback',{@ChangeDisplay,3},'visible','off');
Image.SliceSlider = uicontrol('style','slide','units','normalized','position',...
    [.86,.12,.015,.77], 'min',1,'max',2,'val',1,'SliderStep', [1 1],'visible','off','callback',{@MoveSlider});
Image.CurrentSlice=uicontrol('style','text','units','normalized',...
    'position',[.89,.25,.08,.05],'string','Current Slice: 1','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',12,'FontWeight','bold','UserData',0,'visible','off');



Image.ApplySelection=uicontrol('style','pushbutton','units','normalized',...
    'position',[.72,.06,.2,.05],'string','Apply Current','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback',{@Apply_Threshold,1,cell(1,2)},'UserData',0);

Image.MasterSet=uicontrol('style','checkbox','units','normalized',...
    'position',[.72,.01,.2,.05],'string','Use as Image Master','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',10,'FontWeight','bold','UserData',0);

Image.ZoomToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.8,.08,.05],'string','Zoom','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'zoom on');
Image.PanToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.72,.08,.05],'string','Pan','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'pan on');
Image.DataToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.64,.08,.05],'string','Info','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'datacursormode on');
Image.DataAdd=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.56,.08,.05],'string','Add','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', {@ObjRefine,1},'UserData',0);
Image.DataDelete=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.48,.08,.05],'string','Delete','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', {@ObjRefine,2},'UserData',0);
Image.DataSplit=uicontrol('style','pushbutton','units','normalized',...
    'position',[.89,.40,.08,.05],'string','Split','backgroundcolor',...
    get(Image.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', {@ObjRefine,3},'UserData',0);

Image.MasterROITitle=uicontrol('style','text','units','normalized',...
    'position',[.05,.40,.1,.05],...
    'string','Master ROI:','fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','visible','off');

Image.MasterROIMenu=uicontrol('style','popupmenu','units','normalized',...
    'position',[.14,.405,.1,.05],...
    'string',['None'],'fontsize',14,...
    'backgroundcolor',[1 1 1],...
    'fontweight','bold','value',1,'callback',{@ChangeDisplay,5},'visible','off');
for i=1:4
Image.byChanObj(1)=uicontrol('style','text','units','normalized',...
    'position',[.05,(.35-(.05*(1-1))),.25,.05],...
    'string',sprintf('Chan %s: NaN',i),'fontsize',14,...
    'backgroundcolor',get(Image.fh,'Color'),...
    'fontweight','bold','Horizontalalignment','left','visible','off');
end
%% Toolbar Menus
%File Menus
Image.FileMenu = uimenu('Label','File');
Image.FMenu.New=uimenu(Image.FileMenu,'Label','Load Images');
Image.FMenu.Seq=uimenu(Image.FMenu.New,'Label','Sequence','Callback',{@LoadImage,1});
Image.FMenu.Proj=uimenu(Image.FMenu.New,'Label','Projection','Callback',{@LoadImage,2});
Image.FMenu.ND2=uimenu(Image.FMenu.New,'Label','Nikon ND2','Callback',{@LoadImage,3});
Image.FMenu.Load=uimenu(Image.FileMenu,'Label','Load Segmentation');
Image.FMenu.LoadAll=uimenu(Image.FMenu.Load,'Label','All','Callback',{@LoadSeg,1});
Image.FMenu.LoadSeg=uimenu(Image.FMenu.Load,'Label','Segmentation Only','Callback',{@LoadSeg,2},'visible','off');
Image.FMenu.Save=uimenu(Image.FileMenu,'Label','Save Segementation');
Image.FMenu.SaveAll=uimenu(Image.FMenu.Save,'Label','Save','Callback',{@SaveSeg,1});

%Metadata Menus
Image.MetaMenu = uimenu('Label','Metadata');
Image.MMenu.Set=uimenu(Image.MetaMenu,'Label','Set');
Image.MMenu.S.ChI=uimenu(Image.MMenu.Set,'Label','Channel Info','callback',{@Set_MetaData,11});
Image.MMenu.S.AcI=uimenu(Image.MMenu.Set,'Label','Acquisition Parameters','callback',{@Set_MetaData,12});
Image.MMenu.S.OtherImage=uimenu(Image.MMenu.Set,'Label','Import Metadata','callback',{@Set_MetaData,13});
Image.MMenu.View=uimenu(Image.MetaMenu,'Label','View');
Image.MMenu.V.ChI=uimenu(Image.MMenu.View,'Label','Channel Info','callback',{@Set_MetaData,21});
Image.MMenu.V.AcI=uimenu(Image.MMenu.View,'Label','Acquisition Parameters','callback',{@Set_MetaData,22});

%Thresholding Segmentation Menus
Image.TMenu.Clear=uimenu(Image.FileMenu,'Label','Clear','Callback',@ClearWorkspace);
Image.TMenu.Quit=uimenu(Image.FileMenu,'Label','Quit','Callback','exit',...
    'Separator','on','Accelerator','Q');
Image.ThreshMenu = uimenu('Label','Thresh/Seg');
Image.ThrMenu.Segementation=uimenu(Image.ThreshMenu,'Label','Segmentation');
Image.ThrMenu.Seg.Otsu=uimenu(Image.ThrMenu.Segementation,'Label','Otsu','callback',{@ThreshPortalGUI,'Otsu'},'UserData',1);
Image.ThrMenu.Seg.Manual=uimenu(Image.ThrMenu.Segementation,'Label','Manual','callback',{@ThreshPortalGUI,'Manual'},'UserData',4);
Image.ThrMenu.Seg.Integral=uimenu(Image.ThrMenu.Segementation,'Label','Integral','callback',{@ThreshPortalGUI,'Integral'},'UserData',2);
%Image.ThrMenu.Seg.Derivitive=uimenu(Image.ThrMenu.Segementation,'Label','Derivitive','callback',{@ThreshGUI,'Derivitive'},'UserData',3);
%Image.ThrMenu.Seg.Bright=uimenu(Image.ThrMenu.Segementation,'Label','Automatic: Bright','callback',{@ThreshGUI,'Bright'},'UserData',5);
%Image.ThrMenu.Seg.Dark=uimenu(Image.ThrMenu.Segementation,'Label','Automatic: Dark','callback',{@ThreshGUI,'Dark'},'UserData',6);
Image.ThrMenu.Seg.RegGrow=uimenu(Image.ThrMenu.Segementation,'Label','Region Growing');
Image.ThrMenu.RG.Auto=uimenu(Image.ThrMenu.Seg.RegGrow,'Label','Automatic','callback',{@ThreshPortalGUI,'Growth','Auto'},'UserData',7);
Image.ThrMenu.RG.BackGround=uimenu(Image.ThrMenu.Seg.RegGrow,'Label','Background Subtraction','callback',{@ThreshPortalGUI,'Growth','BGSub'},'UserData',7);
Image.ThrMenu.RG.Pick=uimenu(Image.ThrMenu.Seg.RegGrow,'Label','Pick Seeds','callback',{@ThreshPortalGUI,'Growth','Pick'},'UserData',7);



Image.ThrMenu.Filter=uimenu(Image.ThreshMenu,'Label','Filtering');
Image.ThrMenu.Filt.In_mROI=uimenu(Image.ThrMenu.Filter,'Label','In Master Region','callback',{@SegFilter,1},'UserData',1);
Image.ThrMenu.Filt.In_Pix=uimenu(Image.ThrMenu.Filter,'Label','Shares Master Voxel','callback',{@SegFilter,2},'UserData',1);
Image.ThrMenu.Filt.Unique=uimenu(Image.ThrMenu.Filter,'Label','Unique Association','callback',{@SegFilter,3},'UserData',1);
Image.ThrMenu.Filt.mExtra=uimenu(Image.ThrMenu.Filter,'Label','Master Extra','callback',{@SegFilter,4},'UserData',1);
Image.ThrMenu.Filt.DelROIs=uimenu(Image.ThrMenu.Filter,'Label','Delete ROIs','callback',{@SegFilter,5},'UserData',1);

Image.ThrMenu.Undo=uimenu(Image.ThreshMenu,'Label','Undo','callback',{@Undo_Redo,'Undo'},'enable','off','visible','off');
Image.ThrMenu.Redo=uimenu(Image.ThreshMenu,'Label','Redo','callback',{@Undo_Redo,'Redo'},'enable','off','visible','off');



%Analysis Menus
Image.AnaMenu = uimenu('Label','Anaylsis');
Image.AMenu.Geo=uimenu(Image.AnaMenu,'Label','Geometric Methods');
%Image.AMenu.GeoDes=uimenu(Image.AMenu.Geo,'Label','Descriptors','callback',{@AnaylsisPortalGUI,'Geo',1});
Image.AMenu.Between_Among=uimenu(Image.AMenu.Geo,'Label','Between/Among','callback',{@AnaylsisPortalGUI,'Geo',1});
Image.AMenu.Shell=uimenu(Image.AMenu.Geo,'Label','Shells','callback',{@AnaylsisPortalGUI,'Geo',4});

%Image.AMenu.Int=uimenu(Image.AnaMenu,'Label','Intensity Methods');
%Image.AMenu.IntDes=uimenu(Image.AMenu.Int,'Label','Descriptors','callback',{@AnaylsisPortalGUI,'Int',1});
%Image.AMenu.Erosion=uimenu(Image.AMenu.Int,'Label','Object Erosion','callback',{@AnaylsisPortalGUI,'Int',2});

Image.AMenu.SimOc=uimenu(Image.AnaMenu,'Label','Simulate Occupany');
Image.AMenu.NN=uimenu(Image.AMenu.SimOc,'Label','Nearest Neighboor','callback',{@Occupancy,1});
Image.AMenu.LI=uimenu(Image.AMenu.SimOc,'Label','Linear Interpolation','callback',{@Occupancy,2});
Image.AMenu.cHull=uimenu(Image.AMenu.SimOc,'Label','Inside Hull (Convex)','callback',{@Occupancy,3});
Image.AMenu.cHull=uimenu(Image.AMenu.SimOc,'Label','Wiggle','callback',{@Occupancy,4});

Image.AMenu.Debug=uimenu(Image.AnaMenu,'Label','Debug','callback',@Debug);

%Visuulization Menus
Image.VisMenu = uimenu('Label','Visulization');
Image.VMenu.DataSum=uimenu(Image.VisMenu,'Label','Data Summary','callback',{@Viz_Feeder,1});
Image.VMenu.Snapshot=uimenu(Image.VisMenu,'Label','Snapshot','callback',{@Viz_Feeder,2});
Image.VMenu.CompositeViewer=uimenu(Image.VisMenu,'Label','Composite Viewer','callback',{@Viz_Feeder,3});
Image.VMenu.MultiStack=uimenu(Image.VisMenu,'Label','Multi Stack Viewer','callback',{@Viz_Feeder,4});
Image.VMenu.ImageSumIso=uimenu(Image.VisMenu,'Label','Isosurface Viewer','callback',{@Viz_Feeder,5});

%{
Image.BatchMenu = uimenu('Label','Batch Processing');
Image.BMenu.MCarlo=uimenu(Image.BatchMenu,'Label','Convert SegOnly','callback',{@Batch,1});
Image.BMenu.RadDist=uimenu(Image.BatchMenu,'Label','Calc RadDist','callback',{@Batch,2});
Image.BMenu.ShapeDes=uimenu(Image.BatchMenu,'Label','Calc Shape Des','callback',{@Batch,3});
Image.BMenu.IOD=uimenu(Image.BatchMenu,'Label','Calc Intra Obj Dist','callback',{@Batch,4});
Image.BMenu.Shell=uimenu(Image.BatchMenu,'Label','Calc Shells','callback',{@Batch,5});
Image.BMenu.Loop=uimenu(Image.BatchMenu,'Label','Calc Looping','callback',{@Batch,6});

if isempty(varargin)
else
    [R,C]=size(varargin{1});
    if (C==10 || C==11 && R==1) || (isstruct(varargin{1}{2}))
        if isempty(AppliedData{MetaData(1).Channel_Master})
        else
            set(Image.MasterSet,'visible','off')
            R=size(AppliedData{MetaData(1).Channel_Master}{2,9},1);
            set(Image.ObjCount,'string',sprintf('Num ROIs: %d',R))
            set(Image.MasterROIMenu,'string',['None',num2cell(1:1:R)]);
            set(Image.MasterROIMenu,'visible','on')
            set(Image.MasterROITitle,'visible','on')
            for i=1:numel(Image.byChanObj)
                set(Image.byChanObj(i),'visible','on')
            end
        end
    end
    
end
%}


Image.ManipulationLog=cell(1,size(Image.byChanObj,2));
Image.ManipulationLog{1,1}={sprintf('File Created: %s',datestr(now))};
Image.ManipulationNumber=1;

Image.CurrentView=max(get(findobj((get(Image.IMAxes,'Children')),'type','image'),'cData'),[],3);
Image.cLabelMatrix=cell(5,1);
Image.cLabelMatrix_Toggle=false(25,1);

Image.IMSize=[1024,1024,1];
Image.ImagePlace_Handle=findobj((get(Image.IMAxes,'Children')),'type','image');
%addlistener(Image.IMAxes,'UserData','PostGet',@OverlayListener);
%set the version number
data=ResetGUI(Image);
set(Image.fh,'userdata',1);
guidata(Image.fh,data);
end

%% Goes into Debug Mode
function []=Debug(varargin)
data = guidata(varargin{1});
handles=data{1};
keyboard
assignin('base', 'data',data)
guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)]);
end

%% Toggle On Advanced Displays
function []=DisplayToggle(varargin)
data = guidata(varargin{1});
handles=data{1};
Toggle=get(handles.AdvancedDisplay,'value');
if Toggle==1
    set(handles.DisplayTypeMenu,'visible','on')
    set(handles.DisplayTypeTile,'visible','on')
else
    set(handles.DisplayTypeMenu,'visible','off')
    set(handles.DisplayTypeTile,'visible','off')
    set(handles.DisplayTypeMenu,'value',1)
    ChangeDisplay(handles.fh,[],4)
end
end

%% Adjust Slice Slider
function []=MoveSlider(varargin)
data = guidata(varargin{1});
handles=data{1};

set(handles.CurrentSlice,'string',sprintf('Current Slice: %d',round(get(handles.SliceSlider,'value'))))
ChangeDisplay(handles.fh,[],4)
end

function []=ObjRefine(varargin)
pan off
zoom off

data=guidata(varargin{1});
handles=data{1};
Current_Chan=get(handles.ChannelMenu,'value');
Current_mROI=get(handles.MasterROIMenu,'value');
Current_Display=get(handles.DisplayModeMenu,'value');
MChan=data{10}(1).Channel_Master;

    [Mod_ROIs]=Extract_Data(data,[5,6,7],Current_Chan,Current_Display);

if Current_mROI==1
    Shift=[0 0 0];
else
    Shift=data{9}{MChan}{2,9}{Current_mROI-1,3};
end


switch varargin{3}
    case 1
        Manip_Menu.fh = uicontextmenu;
        Manip_Menu.Add=uimenu(Manip_Menu.fh, 'Label', 'Add from ROI','callback',{@Add_Refine,1,data,Mod_ROIs,Shift});
        Manip_Menu.Refine=uimenu(Manip_Menu.fh, 'Label', 'Refine Obj','callback',{@Add_Refine,2,data,Mod_ROIs,Shift});
        set(handles.ImagePlace_Handle,'UIContextMenu',Manip_Menu.fh)
        
    case 2
        
        Manip_Menu.fh = uicontextmenu;
        Manip_Menu.Delete=uimenu(Manip_Menu.fh, 'Label', 'Delete Object','callback',{@Delete_ROI,1,data,Mod_ROIs,Shift});
        Manip_Menu.Delete_mROI=uimenu(Manip_Menu.fh, 'Label', 'Delete mROI','callback',{@Delete_ROI,2,data,Mod_ROIs,Shift});
        Manip_Menu.CropZone=uimenu(Manip_Menu.fh, 'Label', 'Crop Zone','callback',{@Delete_ROI,3,data,Mod_ROIs,Shift});
        Manip_Menu.KeepZone=uimenu(Manip_Menu.fh, 'Label', 'Keep Zone','callback',{@Delete_ROI,4,data,Mod_ROIs,Shift});
       if handles.MasterSet_Toggle==0
           set(Manip_Menu.Delete_mROI,'enable','off')
       end
        set(handles.ImagePlace_Handle,'UIContextMenu',Manip_Menu.fh)
    case 3
        Manip_Menu.fh = uicontextmenu;
        Manip_Menu.Delete=uimenu(Manip_Menu.fh, 'Label', 'Manual','callback',{@Split_ROI,'Manual',data,Mod_ROIs,Shift});
        Manip_Menu.Watershed=uimenu(Manip_Menu.fh, 'Label', 'Watershed','enable','on');
        Manip_Menu.WS.Auto=uimenu(Manip_Menu.Watershed, 'Label', 'Auto','callback',{@Split_ROI,'Watershed',data,Mod_ROIs,Shift,'Auto'},'enable','on');
        Manip_Menu.WS.Pick=uimenu(Manip_Menu.Watershed, 'Label', 'Pick','callback',{@Split_ROI,'Watershed',data,Mod_ROIs,Shift,'Pick'},'enable','on');

        Manip_Menu.CropZone=uimenu(Manip_Menu.fh, 'Label','Hull Dist','callback',{@Split_ROI,'Hull Dist',Mod_ROIs,Shift},'enable','off');
        Manip_Menu.KeepZone=uimenu(Manip_Menu.fh, 'Label', 'Future','callback',{@Split_ROI,'Future',data,Mod_ROIs,Shift},'enable','off');
        set(handles.ImagePlace_Handle,'UIContextMenu',Manip_Menu.fh)
        
end

end

function []=SegFilter(varargin)
data=guidata(varargin{1});
H=data{1};
MChan=data{10}(1).Channel_Master;
Channel_Choice=get(H.ChannelMenu,'value');
Display_Choice=get(H.DisplayModeMenu,'value');
MasterROI_Choice=get(H.MasterROIMenu,'value');

[FSS_data]=Extract_Data(data,[5,6,7],Channel_Choice,Display_Choice);  

if MasterROI_Choice~=1
    RowPull=data{9}{MChan}{2,9}{MasterROI_Choice-1,2};
    rRow_Pull=Find_RowPull(FSS_data{2}(:,3),RowPull);
    Pull_Index=1:size(FSS_data{2},1);
    Other_data=cell(1,3);
    for i=1:3
        Other_data{1,i}=FSS_data{i}(~ismember(Pull_Index,rRow_Pull),:);
        FSS_data{1,i}=FSS_data{i}(ismember(Pull_Index,rRow_Pull),:);
    end
else
    Other_data=cell(1,3);
end

switch varargin{3}
    case 1
        [FSS_data,delta_ROIs]=Outside_mROI(data{9}{MChan}{2,9},FSS_data);
        %Remove Signal Outside Master ROI
    case 2
        
        [FSS_data,delta_ROIs]=Outside_Pix(data{9}{MChan}(2,6:7),FSS_data);
        %Remove Signal Outside Master Pix
    case 3
        FSS_data=Unique_association(data{9}{MChan}{2,9},FSS_data);
        delta_ROIs=cell(1,2);
        %Make a Single Unqiue Association
    case 4

        NewImage=false(H.IMSize);
        for i=1:size(FSS_data{2},1);
            FS=FSS_data{3}(i,:);
            FS=FS+1;
            [W,h,D]=size(FSS_data{2}{i,1});
            NewImage(FS(2):FS(2)+W-1,FS(1):FS(1)+h-1,FS(3):FS(3)+D-1)=FSS_data{2}{i,1};
        end
        [data]=Add_Data(data,2,...
            {NewImage},...
            Channel_Choice,Display_Choice);
             [data]=Add_Data(data,3,...
            {max(NewImage,[],3)},...
            Channel_Choice,Display_Choice);
                delta_ROIs=cell(1,2);
    case 5
        
        if MasterROI_Choice==1
            RegionNum=0;
        else
          RegionNum=data{9}{MChan}{2,9}{MasterROI_Choice-1,2}    ;
        end
        
        [FSS_data,delta_ROIs]=BatchDel(  RegionNum,FSS_data);
        
        if Channel_Choice==MChan
            rm_ROI=vertcat(delta_ROIs{:,1});
            rm_ROI=[{vertcat(rm_ROI{:,1})},{vertcat(rm_ROI{:,2})},{vertcat(rm_ROI{:,3})}];
            [FSS_data,data]=Update_mROIs(data,FSS_data,rm_ROI);
            set(H.ChannelMenu,'value',Channel_Choice)
            set(H.DisplayModeMenu,'value',Display_Choice)
            
        end
end

FSS_data=[{vertcat(Other_data{1},FSS_data{1})},...
    {vertcat(Other_data{2},FSS_data{2})},...
    {vertcat(Other_data{3},FSS_data{3})}];
Manipulation_PostProcess(FSS_data,delta_ROIs,data,'Modify')

end

function []=Viz_Feeder(varargin)
Mode=varargin{3};

switch Mode
    case 1
        h=ObjSummary(varargin{1},'1','3');
    case 2
        SnapShot_Builder(varargin{1});
    case 3
        Comp_View(varargin{1});
    case 4
        Multi_StackSlider(varargin{1})
    case 5
        Iso_View(varargin{1});

end

end

