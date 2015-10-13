function []=Iso_View(varargin)
data=guidata(varargin{1});
MChan=data{10}(1).Channel_Master;

IsoSurf=Create_InputMask(data,1);
Control_Iso=BuildGUI(varargin);
NumChan=numel(data{9});

for i=1:NumChan
    if ~isempty(data{9}{i})
    set([Control_Iso.FaceColor(i),Control_Iso.FaceAlpha(i),Control_Iso.EdgeColor(i),Control_Iso.EdgeAlpha(i)],'callback',{@Update_Iso,data,Control_Iso})
    else
    set([Control_Iso.FaceColor(i),Control_Iso.FaceAlpha(i),Control_Iso.EdgeColor(i),Control_Iso.EdgeAlpha(i)],'enable','off')        
    end
end

smallstep=1/(size(data{9}{MChan}{2,9},1)-1);                                               
largestep=smallstep*10;                                                  
set(Control_Iso.ObjNum,'callback',{@Update_ROI,data,Control_Iso})
set(Control_Iso.Slider,'call',{@Update_ROI,data,Control_Iso},...
    'min',1,'max',size(data{9}{MChan}{2,9},1),'SliderStep', [smallstep largestep])
Image_Iso.fh=figure('visible','on','tag','Iso_Image','name','Isosurface','numbertitle','off');
Image_Iso.Parent_Ax = axes('units','normalized','parent',Image_Iso.fh,...                                            
    'position',[0 0 1 1],...
    'fontsize',10,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],'visible','off');
hold on
for i=1:NumChan
    if ~isempty(data{9}{i})
        Image_Iso.Iso_Patch(i)=patch(isosurface(IsoSurf{i,1},.5),...
            'FaceColor',CallBack_Value_String(Control_Iso.FaceColor(i)),...
            'FaceAlpha',str2double(get(Control_Iso.FaceAlpha(i),'string'))/100,...
            'EdgeColor',CallBack_Value_String(Control_Iso.EdgeColor(i)),...
            'parent',Image_Iso.Parent_Ax);
        
    end
end

CalibrationData=data{10}(1);
daspect([1/CalibrationData.CaliMetaData.XCal,1/CalibrationData.CaliMetaData.YCal,1/CalibrationData.CaliMetaData.ZCal])
view(3); axis tight
camlight(-80,-10); lighting phong
axis off
set(Control_Iso.fh,'userdata',Image_Iso)
set(Control_Iso.fh,'CloseRequestFcn',{@CRF,Control_Iso.fh,Image_Iso.fh})
set(Image_Iso.fh,'CloseRequestFcn',{@CRF,Control_Iso.fh,Image_Iso.fh})

end

function Comp3D=BuildGUI(varargin)

data=guidata(varargin{1}{1});
NumChan=numel(data{9});
AllColors={'None','Blue','Green','Red','Yellow','Cyan','Magenta','Black','White'};

Comp3D.fh = figure('units','normalized',...
    'position',[.53 .5 .35 .25],...
    'menubar','none',...
    'name','Controller',...
    'numbertitle','off',...
    'resize','off','tag','Iso_Control');
Comp3D.Title(1)=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.15 .85 .87 .11],...
    'String','Face Color',...
    'fontsize',12,...
    'fontweight','bold',...
    'backgroundcolor',get(Comp3D.fh,'color'),...
    'HorizontalAlignment','left');
Comp3D.Title(2)=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.3625 .85 .87 .11],...
    'String','Face Alpha',...
    'fontsize',12,...
    'fontweight','bold',...
    'backgroundcolor',get(Comp3D.fh,'color'),...
    'HorizontalAlignment','left');
Comp3D.Title(3)=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.5750 .85 .87 .11],...
    'String','Edge Color',...
    'fontsize',12,...
    'fontweight','bold',...
    'backgroundcolor',get(Comp3D.fh,'color'),...
    'HorizontalAlignment','left');
Comp3D.Title(4)=uicontrol('style','text',...
    'unit','normalized',...
    'position',[.7872 .85 .87 .11],...
    'String','Show Edge',...
    'fontsize',12,...
    'fontweight','bold',...
    'backgroundcolor',get(Comp3D.fh,'color'),...
    'HorizontalAlignment','left');
for i=1:NumChan
    if ~isempty(data{9}{i})
        Comp3D.Channel(i)=uicontrol('style','text',...
            'unit','normalized',...
            'position',[0  .7-((i-1)*.1750) .9 .1],...
            'String',sprintf('%s:  ',data{10}(i).Channel_ID),...
            'fontsize',12,...
            'fontweight','bold',...
            'backgroundcolor',get(Comp3D.fh,'color'),...
            'HorizontalAlignment','left');
        Comp3D.FaceColor(i) = uicontrol('Style','popupmenu','String',AllColors,...
            'units','normalized','pos',[.15 .7-((i-1)*.1750) .15 .11],'parent',Comp3D.fh,...
            'backgroundcolor',[1 1 1],'fontsize',10,'HorizontalAlignment','left','Value',i+1,'UserData',i);
        Comp3D.EdgeColor(i) = uicontrol('Style','popupmenu','String',AllColors,...
            'units','normalized','pos',[.5750 .7-((i-1)*.1750) .15 .11],'parent',Comp3D.fh,...
            'backgroundcolor',[1 1 1],'fontsize',10,'HorizontalAlignment','left','Value',1,'UserData',i);
        Comp3D.FaceAlpha(i)=uicontrol('style','edit','units','normalized',...
            'position',[.3625 .7-((i-1)*.1650) .15 .10],'string',50,'backgroundcolor',[1 1 1],...
            'fontsize',10,'parent',Comp3D.fh,'value',.5,'UserData',i);
        Comp3D.EdgeAlpha(i)=uicontrol('style','edit','units','normalized',...
            'position',[.7872 .7-((i-1)*.1750) .15 .11],'string',50,'backgroundcolor',[1 1 1],...
            'fontsize',10,'parent',Comp3D.fh,'value',.5,'UserData',i);
    end
end
Comp3D.ObjTitle=uicontrol('parent',Comp3D.fh,'style','text','units','normalized','position',[.32,.1,.40,.08],'visible','on','string','ROI:','fontsize',12,'fontweight','bold',...
    'backgroundcolor',get(Comp3D.fh,'color'));
Comp3D.ObjNum=uicontrol('parent',Comp3D.fh,'style','edit','units','normalized','position',[.55,.11,.05,.08],'visible','on','string',1,'fontsize',10);
Comp3D.Slider=uicontrol('parent',Comp3D.fh,'style','slider','units','normalized','position',[.1,.025,.80,.08],'visible','on','value', 1,'min',1,'max',10);


end

function []=Update_ROI(varargin)
[h,data,Control_Iso] = varargin{[1,3,4]};
switch h
    case Control_Iso.Slider
        Current_mROI=get(Control_Iso.Slider,'value');
        set(Control_Iso.ObjNum,'string',num2str(Current_mROI))
    case Control_Iso.ObjNum
        Current_mROI=str2double(get(Control_Iso.ObjNum,'string'));
        set(Control_Iso.Slider,'value',Current_mROI);
end
 IsoSurf=Create_InputMask(data,Current_mROI);
 New_Iso(data,IsoSurf,Control_Iso,get(Control_Iso.fh,'userdata'));
end

function []=Update_Iso(varargin)
[~,data,Control_Iso] = varargin{[1,3,4]};
Image_Iso=get(Control_Iso.fh,'userdata');
NumChan=numel(data{9});

for i=1:NumChan
    if ~isempty(data{9}{i})
        set(Image_Iso.Iso_Patch(i),...
            'FaceColor',CallBack_Value_String(Control_Iso.FaceColor(i)),...
            'FaceAlpha',str2double(get(Control_Iso.FaceAlpha(i),'string'))/100,...
            'EdgeAlpha',str2double(get(Control_Iso.EdgeAlpha(i),'string'))/100,...
        'EdgeColor',CallBack_Value_String(Control_Iso.EdgeColor(i)),...
            'parent',Image_Iso.Parent_Ax);
        
    end
end

end

function Image_Iso=New_Iso(data,IsoSurf,Control_Iso,Image_Iso)
NumChan=numel(data{9});

for i=1:NumChan
    if ~isempty(data{9}{i})
        delete (Image_Iso.Iso_Patch(i))
        Image_Iso.Iso_Patch(i)=patch(isosurface(IsoSurf{i,1},.5),...
            'FaceColor',CallBack_Value_String(Control_Iso.FaceColor(i)),...
            'FaceAlpha',str2double(get(Control_Iso.FaceAlpha(i),'string'))/100,...
            'EdgeColor',CallBack_Value_String(Control_Iso.EdgeColor(i)),...
            'parent',Image_Iso.Parent_Ax);
        
    end
end
set(Image_Iso.Parent_Ax,'xlimmode','auto')
set(Image_Iso.Parent_Ax,'ylimmode','auto')
set(Image_Iso.Parent_Ax,'zlimmode','auto')
axis tight
CalibrationData=data{10}(1);
daspect([1/CalibrationData.CaliMetaData.XCal,1/CalibrationData.CaliMetaData.YCal,1/CalibrationData.CaliMetaData.ZCal])
view(3); 
camlight(-80,-10); lighting phong
axis off
set(Control_Iso.fh,'userdata',Image_Iso)

end

function IsoSurf=Create_InputMask(data,mROI_Choice)
MChan=data{10}(1).Channel_Master;
NumChan=numel(data{9});
IsoSurf=cell(NumChan,1);

for i=1:NumChan
BinaryImage=double(zeros(data{9}{MChan}{2,9}{1,4}));
    if ~isempty(data{9}{i})
        [RowPull]=Find_RowPull( data{9}{i}{2,6}(:,3),data{9}{MChan}{2,9}{mROI_Choice,2});
        for j=1:numel(RowPull)
            FS=data{9}{i}{2,7}(RowPull(j),:)-data{9}{MChan}{2,9}{mROI_Choice,3};
            IM=data{9}{i}{2,6}{RowPull(j),1};
            
            
            if (FS(1)+size(IM,2)-1)>size(BinaryImage,2)
                y_toBig=(FS(1)+size(IM,2)-1)-size(BinaryImage,2);
                IM=IM(:,1:end-y_toBig,:);
            end
            if (FS(2)+size(IM,1)-1)>size(BinaryImage,1)
                x_toBig=(FS(2)+size(IM,1)-1)-size(BinaryImage,1);
                IM=IM(1:end-x_toBig,:,:);
            end
            if FS(1)<1
                x_exclude=1-FS(1);
                FS(1)=FS(1)+x_exclude;
                IM(x_exclude+1:end,:,:);
            end
            if FS(2)<1
                y_exclude=1-FS(2);
                FS(2)=FS(2)+y_exclude;
                IM(:,y_exclude+1:end,:);
            end
            
            Planes=size(IM,3);   
            for k=1:Planes
            IM(:,:,k)=imfill(IM(:,:,k),'holes');
            end
            %IM=bwperim(IM)


            for k=1:Planes
                    BinaryImage(FS(2):FS(2)+size(IM,1)-1,...
                    FS(1):FS(1)+size(IM,2)-1,...
                     data{9}{i}{2,7}(RowPull(j),3)+k)=BinaryImage(FS(2):FS(2)+size(IM,1)-1,...
                    FS(1):FS(1)+size(IM,2)-1,...
                     data{9}{i}{2,7}(RowPull(j),3)+k)+double(IM(:,:,k));
            end
            
        end
    end
    IsoSurf{i,1}=logical(BinaryImage);
end
end

function []=CRF(varargin)
[h,Control_H,Image_H] = varargin{[1,3,4]};

        delete(Image_H)
        delete(Control_H)

end