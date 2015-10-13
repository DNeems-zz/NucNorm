function []=Comp_View(varargin)

data=guidata(varargin{1});
Comp_Controller=SnapShot_Builder(varargin{1});
set(Comp_Controller.Capture,'visible','off')
set(Comp_Controller.ObjMenu,'enable','off')
set(Comp_Controller.ObjMenu,'value',2)
for i=1:numel(Comp_Controller.Channel)
    set(Comp_Controller.Type(i),'callback',{@EC,Comp_Controller.Type(i),Comp_Controller.Fill(i),Comp_Controller,data})
    set(Comp_Controller.Fill(i),'callback',{@IM_Update,Comp_Controller,data})
    
end
set(Comp_Controller.SliceMenu,'callback',{@IM_Update,Comp_Controller,data})
smallstep=1/(size(data{9}{data{10}(1).Channel_Master}{2,9},1)-1); 
largestep=smallstep*10;                                                     
C.Image_Window=figure('tag','Comp_Window','visible','off','name','Composite','numbertitle','off');
C.sl1 = uicontrol('style','slide',...                                        
    'unit','normalized',...                           
    'position',[0.05 .02 .9 .06],...
    'min',1,'max',size(data{9}{data{10}(1).Channel_Master}{2,9},1),'val',1,...
    'SliderStep', [smallstep largestep],'callback',{@IM_Update,Comp_Controller,data});

C.ed1 = uicontrol('style','text',...                                         
    'unit','normalized',...
    'position',[.92 .1 .05 .05],...
    'fontsize',12,...
    'string','1', 'backgroundcolor',get(C.Image_Window,'Color'));
C.cmtext=uicontrol('style','text',...                                       
    'unit','normalized',...
    'position',[.92 .15 .15 .05],...
    'fontsize',10,'HorizontalAlignment','Left',...
    'string','mROI:', 'backgroundcolor',get(C.Image_Window,'Color'));


C.Parent_Ax = axes('units','normalized','parent',C.Image_Window,...
    'position',[0 .1 1 .9],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],'visible','off');

set(Comp_Controller.fh,'userdata',[{Comp_Controller},{C}])

Generate_SnapShot(1,1,Comp_Controller,data,C)
set(C.Image_Window,'CloseRequestFcn',{@CRF,C.Image_Window,Comp_Controller.fh})
set(Comp_Controller.fh,'CloseRequestFcn',{@CRF,C.Image_Window,Comp_Controller.fh})

end
function []=EC(varargin)
switch CallBack_Value_String(varargin{3})
    case 'Intensity'
        set(varargin{4},'string',{'All','Cut-Out'},'value',1,'enable','on')
    case 'Binary'
        set(varargin{4},'string',{'Mask','Perimeter'},'value',1,'enable','on')
    case 'None'
        set(varargin{4},'enable','off','string','None','value',1)
        
end

IM_Update(1,1,varargin{5},varargin{6})
end

function []=IM_Update(varargin)

data=varargin{4};
Comp_Controller=varargin{3};
Comp_Controller=get(Comp_Controller.fh,'userdata');
C=Comp_Controller{2};
Comp_Controller=Comp_Controller{1};
set(C.ed1,'string',num2str(get(C.sl1,'value')));
set(Comp_Controller.ObjMenu,'value',get(C.sl1,'value')+1)
Generate_SnapShot(1,1,Comp_Controller,data,C)
end

function []=CRF(varargin)
[~,Image_H,Control_H] = varargin{[1,3,4]};

        delete(Image_H)
        delete(Control_H)

end