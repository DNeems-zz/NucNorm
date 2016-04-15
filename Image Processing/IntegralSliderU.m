function [I]=IntegralSliderU(Image,HistImage,varargin)

if isempty(varargin)
    imSize=size(max(Image,[],3));
    SSize=get(0,'screensize');
    Scaller=((max(SSize)/(max(imSize*2))));
    if Scaller<1
        Scaller=1;
    end
    [ImR,ImC,ImD]=size(HistImage);
    BI=HistImage>=0;
    [HIST,~]=hist(double(reshape(HistImage,1,ImC*ImR*ImD)),0:1:255);
    Percent_Occupany=HIST./sum(HIST);
    Cummulative_Occupany=zeros(1,255);
    for i=1:255
    Cummulative_Occupany(1,i)=sum(Percent_Occupany(i:end));
    end
    First_Empty_Index=find(Cummulative_Occupany==0,1);
    if isempty(First_Empty_Index)
        First_Empty_Index=numel(Cummulative_Occupany);
    end
    X=Cummulative_Occupany(1:First_Empty_Index);

    
    I.fh=figure('units','Pixels','menubar','none',...
        'name','Integral Preview',...
        'numbertitle','off',...
        'position',[floor(SSize(3)/2)-floor((max(imSize)*Scaller)/2) floor(SSize(4)/2)-floor((max(imSize)*(Scaller*.75))/2) max(imSize)*Scaller max(imSize)*(Scaller*.75)]);
    I.IMAxes=axes('units','Pixels',...
        'position',[0 max(imSize)*(Scaller*.25) imSize(2)*(Scaller*.5) imSize(1)*(Scaller*.5)],'Xlim',[0 ImC],'YLim',[0 ImR]);
    axis off
    set(I.IMAxes,'YDir','reverse')
    image('Parent', I.IMAxes, 'CData', repmat(max(Image,[],3),[1,1,3]));

    I.HAxes=axes('units','Pixels',...
        'position',[max(imSize)*(Scaller*.5) max(imSize)*(Scaller*.25) max(imSize)*(Scaller*.5)-floor(max(imSize)*(Scaller*.5)*.05) max(imSize)*(Scaller*.5)],'Xlim',[0 First_Empty_Index]);
   
    plot(I.HAxes,1:1:numel(X),X);
    set(I.HAxes,'Xlim',[0 numel(X)],'YLim',[0 max(X)+(max(X)*.1)],'XTickLabel',[],'YTickLabel',[])
    I.CurrentVal=uicontrol('style','text','units','normalized',...
        'position',[ .5 .333-.05-.05  .5 .05],'string',sprintf('Perecnt Dataset:%2.0f  Gray Level:%5.0f',100,0),...
        'backgroundcolor',...
        get(I.fh,'Color'),'fontsize',12,'FontWeight','bold');
    line([0 0],[0 max(X)+(max(X)*.1)],'Parent',I.HAxes,'Color','red','Linewidth',5,'Tag','SetPoint');
    I.Opacity=uicontrol('style','Popupmenu','units','normalized','position',[ .125 .333-.05*2  .25 .05],...
        'string',{'Binary','Subtract','Add'},'fontweight','bold','fontsize',12,'callback',@Opacity);
    I.Apply=uicontrol('style','pushbutton','units','normalized',...
        'position',[.4,.1665, .2, .05],'string','Apply','backgroundcolor',...
        get(I.fh,'Color'),'fontsize',12,'FontWeight','bold','callback', @Apply);
    I.All  = uicontrol('Style','checkbox','String','All',...
        'units','normalized','pos',[.61,.1665, .2, .05],'parent',I.fh,...
        'backgroundcolor',get(I.fh,'color'),'fontsize',10,'HorizontalAlignment','right');
    I.Slider=uicontrol('style','slider','units','normalized','position',[ .5 .333-.05  .5 .05],...
        'Min',0,'Max',100,'SliderStep',[.001 .01],'callback',{@IMUpdate,I,X});
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

    guidata(I.fh,[{I},{Image},{HistImage},{X}])

end

end

function []=Opacity(varargin)
data=guidata(varargin{1});
handles=data{1};
CF=nan;
for i=1:numel(data{4})
    if i==1
        Cuml_OC=data{4}(i);
        OC(i,1)=Cuml_OC/sum(data{4});
    else
        Cuml_OC=Cuml_OC+data{4}(i);
        OC(i,1)=Cuml_OC/sum(data{4});
    end
    if OC(i,1)>=CF
        AddCutoff=i;
        break
    end
    
end

delete(findall(get(handles.HAxes,'Children'),'tag','SetPoint'))
set(handles.CurrentVal,'string',sprintf('Val:%2.0f',get(varargin{1},'value')))
method=get(handles.Opacity,'value');
switch method
    case 1
        BI=data{2}>= round(AddCutoff+data{3});
        IM=uint8(BI)*255;
        IM=max(IM,[],3);
        
        delete(findall(get(handles.IMAxes,'Children')));
        image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 2
        BI=data{2}>= round(AddCutoff+data{3});
        IM=data{2}-uint8(~BI)*255;
        IM=max(IM,[],3);
        
        delete(findall(get(handles.IMAxes,'Children')));
        image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 3
        oImage=repmat(max(data{2},[],3),[1,1,3]);
        BI=data{2}>= round(AddCutoff+data{3});
        IM=data{2}-uint8(~BI)*255;
        
        IM=max(IM,[],3);
        delete(findall(get(handles.IMAxes,'Children')));
        oImage(:,:,1)=oImage(:,:,1)-IM;
        oImage(:,:,3)=oImage(:,:,3)-IM;
        image('Parent', handles.IMAxes, 'CData', oImage);
        
        
end
guidata(handles.fh,[{handles},data{2},data{3},data{4},data{5},data{6}])

end
function []=IMUpdate(varargin)

data=guidata(varargin{1});
handles=data{1};
data{2}=max(data{2},[],3);
X=data{4};
delete(findall(get(handles.HAxes,'Children'),'tag','SetPoint'))

Current_Pos=get(handles.Slider,'value');
Percent_Include=1-Current_Pos/100;
Intensity_Cutoff=find(X>=Percent_Include,1,'last')-1;


line([Current_Pos/100*numel(X) Current_Pos/100*numel(X)],[0 max(X)+(max(X)*.1)],'Parent',handles.HAxes,'Color','red','Linewidth',2,'Tag','SetPoint');
set(handles.CurrentVal,'string',sprintf('Perecnt Dataset:%.02f  Gray Level:%2.0f',Percent_Include*100,Intensity_Cutoff))

method=get(handles.Opacity,'value');
switch method
    case 1
        
        BI=data{2}>= Intensity_Cutoff;
        IM=uint8(BI)*255;
        IM=max(IM,[],3);
        
        delete(findall(get(handles.IMAxes,'Children')));
        image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 2
        BI=data{2}>=Intensity_Cutoff;
        IM=data{2}-uint8(~BI)*255;
        IM=max(IM,[],3);
        
        delete(findall(get(handles.IMAxes,'Children')));
        image('Parent', handles.IMAxes, 'CData', repmat(IM,[1,1,3]));
    case 3
        oImage=repmat(max(data{2},[],3),[1,1,3]);
        BI=data{2}>= Intensity_Cutoff;
        IM=data{2}-uint8(~BI)*255;
        IM=max(IM,[],3);
        
        delete(findall(get(handles.IMAxes,'Children')));
        oImage(:,:,1)=oImage(:,:,1)-IM;
        oImage(:,:,3)=oImage(:,:,3)-IM;
        image('Parent', handles.IMAxes, 'CData', oImage);
        
end
guidata(handles.fh,[{handles},data{2},data{3},data{4}])
end
function []=HistZoom(varargin)
data=guidata(varargin{1});
handles=data{1};

if (max(data{4})- round(get(varargin{1},'value')))<=0
    set(handles.HAxes,'YLim',[0 1])
    
else
    set(handles.HAxes,'YLim',[0 max(data{4})- round(get(varargin{1},'value'))])
end
guidata(handles.fh,[{handles},data{2},data{3},data{4},data{6}])

end
function []=Apply(varargin)
data=guidata(varargin{1});
handles=data{1};
set(handles.fh,'userdata',1)
end
