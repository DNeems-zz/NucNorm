function [I]=ManualSlider(Image)

imSize=size(Image);
SSize=get(0,'screensize');
ImC=imSize(1);
ImR=imSize(2);
Scaller=((max(SSize)/(max(imSize*2))));
    if Scaller<1
        Scaller=1;
    end
    
I.fh=figure('units','Pixels','menubar','none',...
'name','Manual Preview',...
'numbertitle','off',...
'position',[floor(SSize(3)/2)-floor((max(imSize)*Scaller)/2) floor(SSize(4)/2)-floor((max(imSize)*(Scaller*.75))/2) max(imSize)*Scaller max(imSize)*(Scaller*.75)]);
I.IMAxes=axes('units','Pixels',...
'position',[0 max(imSize)*(Scaller*.25) imSize(2)*(Scaller*.5) imSize(1)*(Scaller*.5)],'Xlim',[0 ImR],'YLim',[0 ImC]);
axis off
set(I.IMAxes,'YDir','reverse')
image('Parent', I.IMAxes, 'CData', repmat(max(Image,[],3),[1,1,3]));
I.HAxes=axes('units','Pixels',...
'position',[max(imSize)*(Scaller*.5) max(imSize)*(Scaller*.25) max(imSize)*(Scaller*.5)-floor(max(imSize)*(Scaller*.5)*.05) max(imSize)*(Scaller*.5)],'Xlim',[0 255]);
[X,~]=hist(double(reshape(Image,1,ImC*ImR)),0:1:255);
hist(I.HAxes,(double(reshape(Image,1,ImC*ImR))),0:1:255);
set(I.HAxes,'Xlim',[0 255],'YLim',[0 max(X)+(max(X)*.1)],'XTickLabel',[],'YTickLabel',[])

   I.CurrentVal=uicontrol('style','text','units','normalized',...
       'position',[ .5 .333-.05-.05  .5 .05],'string','Val: 0','backgroundcolor',...
        get(I.fh,'Color'),'fontsize',12,'FontWeight','bold');
line([0 0],[0 max(X)+(max(X)*.1)],'Parent',I.HAxes,'Color','red','Linewidth',5);
 I.Opacity=uicontrol('style','Popupmenu','units','normalized','position',[ .125 .333-.05*2  .25 .05],...
     'string',{'Binary','Subtract','Add'},'fontweight','bold','fontsize',12,'callback',@Opacity);
   I.Apply=uicontrol('style','pushbutton','units','normalized',...
        'position',[.4,.1665, .2, .05],'string','Apply','backgroundcolor',...
        get(I.fh,'Color'),'fontsize',12,'FontWeight','bold','callback', @Apply);
    I.All  = uicontrol('Style','checkbox','String','All',...
        'units','normalized','pos',[.61,.1665, .2, .05],'parent',I.fh,...
        'backgroundcolor',get(I.fh,'color'),'fontsize',10,'HorizontalAlignment','right');
 I.Slider=uicontrol('style','slider','units','normalized','position',[ .5 .333-.05  .5 .05],...
        'Min',0,'Max',255,'SliderStep',[1/(255-1) 1/(255-1)],'callback',{@IMUpdate,I,X});
 I.ZoomSlider=uicontrol('style','slider','units','pixels','position',[max(imSize)*(Scaller)-floor(max(imSize)*(Scaller*.5)*.05) max(imSize)*(Scaller*.25) floor(max(imSize)*(Scaller*.5)*.05) max(imSize)*(Scaller*.5)],...
        'Min',0,'Max',max(X),'SliderStep',[.01 .1],'callback',{@HistZoom,X});
I.ZoomToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.05,.1665,.035,.05],'string','Z','backgroundcolor',...
    get(I.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'zoom on');
I.PanToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.1,.1665,.035,.05],'string','P','backgroundcolor',...
    get(I.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'pan on');
I.DataToggle=uicontrol('style','pushbutton','units','normalized',...
    'position',[.15,.1665,.035,.05],'string','D','backgroundcolor',...
    get(I.fh,'Color'),'fontsize',14,'FontWeight','bold','callback', 'datacursormode on');

guidata(I.fh,[{I},{Image}]) 

end

 function []=Opacity(varargin)
data=guidata(varargin{1});
handles=data{1};
method=get(handles.Opacity,'value');

switch method
    case 1
BI=data{2}>= floor(get(handles.Slider,'value'));
IM=uint8(BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 2
BI=data{2}>= floor(get(handles.Slider,'value'));
IM=data{2}-uint8(~BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 3
     oImage=repmat(max(data{2},[],3),[1,1,3]);
BI=data{2}>= floor(get(handles.Slider,'value'));
IM=data{2}-uint8(~BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
oImage(:,:,1)=oImage(:,:,1)-IM;
oImage(:,:,3)=oImage(:,:,3)-IM;
image('Parent', handles.IMAxes, 'CData', oImage);
     
end
guidata(handles.fh,[{handles},{data{2}}]) 

 end
 function []=IMUpdate(varargin)
X=varargin{4};  
data=guidata(varargin{1});
handles=data{1};
delete(findall(get(handles.HAxes,'Children'),'type','line'))
line([ get(varargin{1},'value') get(varargin{1},'value')],[0 max(X)+(max(X)*.1)],'Parent',handles.HAxes,'Color','red','Linewidth',5);
set(handles.CurrentVal,'string',sprintf('Val:%2.0f',get(varargin{1},'value')))
method=get(handles.Opacity,'value');
switch method
    case 1
BI=data{2}>= round(get(varargin{1},'value'));
IM=uint8(BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 2
BI=data{2}>= round(get(varargin{1},'value'));
IM=data{2}-uint8(~BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 3
     oImage=repmat(max(data{2},[],3),[1,1,3]);
BI=data{2}>= round(get(varargin{1},'value'));
IM=data{2}-uint8(~BI)*255;
IM=max(IM,[],3);

delete(findall(get(handles.IMAxes,'Children')));
oImage(:,:,1)=oImage(:,:,1)-IM;
oImage(:,:,3)=oImage(:,:,3)-IM;
image('Parent', handles.IMAxes, 'CData', oImage);
     
end
guidata(handles.fh,[{handles},{data{2}}]) 

 end
 function []=HistZoom(varargin)
 data=guidata(varargin{1});
handles=data{1};
set(handles.HAxes,'YLim',[0 max(varargin{3})- round(get(varargin{1},'value'))])
 guidata(handles.fh,[{handles},{data{2}}]) 

 end
 function []=Apply(varargin)
 data=guidata(varargin{1});
 handles=data{1};
set(handles.fh,'userdata',1) 
 end
