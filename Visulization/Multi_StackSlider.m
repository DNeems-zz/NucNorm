function [] = Multi_StackSlider(varargin)
data=guidata(varargin{1});
S.MChan=data{10}(1).Channel_Master;
S.data=data{9};
S.metadata=data{10};

S.ROI=1;
S.IntensityMod=[1,1,1,1];
S.Overlay_Mod=[0,0,0,0];

SCRSZ=get(0,'ScreenSize');                                                  %Get user's screen size
figheight=SCRSZ(4)-200;                                                     %A reasonable height for the GUI
figwidth=SCRSZ(4)*1.1;                                                      %A reasonable width for the GUI (the height of the screen*1.1)
pad=10;                                                                     %Inside padding in the GUI

%%%%%%Create the figure itself. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S.fh = figure('units','pixels',...                                          
    'position',[figwidth/4 50 figwidth figheight],...
    'menubar','figure',...
    'name','StackSlider',...
    'numbertitle','off',...
    'resize','off','tag','MultiStack');

S.maskoptionstr={'Off','On'};                                      %Strings with the allowed colormaps
S.maskpopup = uicontrol('style','popupmenu',...                               %Popup menu for picking                        
    'unit','pix',...
    'position',[figwidth-16.5*pad figheight-15*pad 6*pad 2*pad],...
    'String', S.maskoptionstr,'value',1);
S.masktext=uicontrol('style','text',...                                       %Textbox describing the popupmenu
    'unit','pix',...
    'position',[figwidth-18*pad figheight-13*pad+2 6*pad+35 2*pad],...
    'fontsize',10,...
    'string','Nuclear Mask', 'backgroundcolor',get(S.fh,'Color'));

S=setROI(S,1,1);

%%%%%%Create the axes for image display. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S.Parent_Ax = axes('units','pixels',...                                            
    'position',[(4*pad) (6*pad) (figwidth-20*pad) (figheight-8*pad)],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],'visible','off');

S.ax(1) = axes('units','pixels',...                                            
    'position',[(4*pad) (6*pad)+(figheight-8*pad)/2 (figwidth-20*pad)/2 (figheight-8*pad)/2],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
S.ax(2) = axes('units','pixels',...                                            
    'position',[(4*pad)+(figwidth-20*pad)/2.2  (6*pad)+(figheight-8*pad)/2 (figwidth-20*pad)/2 (figheight-8*pad)/2],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
S.ax(3) = axes('units','pixels',...                                            
    'position',[4*pad 6*pad-1 (figwidth-20*pad)/2 (figheight-8*pad)/2],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
S.ax(4) = axes('units','pixels',...                                            
    'position',[(4*pad)+(figwidth-20*pad)/2.2  (6*pad)-1 (figwidth-20*pad)/2 (figheight-8*pad)/2],...
    'fontsize',10,...
    'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);

%%%%%%Create a slider and an editbox for picking frames. %%%%%%%%%%%%%%%%%%
smallstep=1/(size(S.staticI{S.MChan},3)-1);                                                %Step the slider will take when moved using the arrow buttons: 1 frame
largestep=smallstep*10;                                                     %Step the slider will take when moved by clicking in the slider: 10 frames

S.sl1 = uicontrol('style','slide',...                                        
    'unit','pix',...                           
    'position',[figwidth-4*pad pad*9 2*pad figwidth-45*pad],...
    'min',1,'max',size(S.staticI{S.MChan},3),'val',1,...
    'SliderStep', [smallstep largestep]);
S.ed1 = uicontrol('style','edit',...                                         
    'unit','pix',...
    'position',[figwidth-11*pad 9*pad 4*pad 2*pad],...
    'fontsize',12,...
    'string','1');
S.cmtext=uicontrol('style','text',...                                       %Textbox describing the editbox
    'unit','pix',...
    'position',[figwidth-14.5*pad 11*pad 10*pad 2*pad],...
    'fontsize',10,...
    'string','Current frame:', 'backgroundcolor',get(S.fh,'Color'));

%%%%%%Create a slider and an editbox for picking ROIs. %%%%%%%%%%%%%%%%%%

smallstep=1/(size(S.data{S.MChan}{2,9},1)-1);                                                %Step the slider will take when moved using the arrow buttons: 1 frame
largestep=smallstep*10;                                                     %Step the slider will take when moved by clicking in the slider: 10 frames

S.sl2 = uicontrol('style','slide',...                                        
    'unit','pix',...                           
    'position',[2*pad pad figwidth-16*pad 2*pad],...
    'min',1,'max',size(S.data{S.MChan}{2,9},1),'val',1,...
    'SliderStep', [smallstep largestep]);
S.ed2 = uicontrol('style','edit',...                                         
    'unit','pix',...
    'position',[figwidth-10*pad pad 4*pad 2*pad],...
    'fontsize',12,...
    'string','1');
S.cmtext2=uicontrol('style','text',...                                       %Textbox describing the editbox
    'unit','pix',...
    'position',[figwidth-13.5*pad 4*pad 10*pad 2*pad],...
    'fontsize',10,...
    'string','Current mROI:', 'backgroundcolor',get(S.fh,'Color'));





%Create fields to multiple intensity of each channel
S.Inttext=uicontrol('style','text',...                                      
    'unit','pix',...
    'position',[figwidth-18*pad figheight-20*pad+2 6*pad+55 2*pad],...
    'fontsize',10,...
    'string','Intensity Multiply', 'backgroundcolor',get(S.fh,'Color'));

S.Int(1)=uicontrol('style','edit',...                                       
    'unit','pix',...
    'position',[figwidth-20*pad figheight-23*pad+2 3.5*pad 2*pad],...
    'fontsize',10,...
    'string','1');
S.Int(2)=uicontrol('style','edit',...                                       
    'unit','pix',...
    'position',[figwidth-16*pad figheight-23*pad+2 3.5*pad 2*pad],...
    'fontsize',10,...
    'string','1');
S.Int(3)=uicontrol('style','edit',...                                      
    'unit','pix',...
    'position',[figwidth-12*pad figheight-23*pad+2 3.5*pad 2*pad],...
    'fontsize',10,...
    'string','1');
S.Int(4)=uicontrol('style','edit',...                                       
    'unit','pix',...
    'position',[figwidth-8*pad figheight-23*pad+2 3.5*pad 2*pad],...
    'fontsize',10,...
    'string','1');

%Create Checkboxes to overlay Binary Masks  of each channel
S.Masktext=uicontrol('style','text',...                                      
    'unit','pix',...
    'position',[figwidth-18*pad figheight-27*pad+2 6*pad+55 3*pad],...
    'fontsize',10,...
    'string','Overlay Binary Mask', 'backgroundcolor',get(S.fh,'Color'));

S.Mask_Overlay(1)=uicontrol('style','checkbox',...                                       
    'unit','pix',...
    'position',[figwidth-19*pad figheight-30*pad+2 3*pad 2*pad],...
    'fontsize',10,...
    'backgroundcolor',get(S.fh,'Color'));
S.Mask_Overlay(2)=uicontrol('style','checkbox',...                                       
    'unit','pix',...
    'position',[figwidth-15*pad figheight-30*pad+2 3*pad 2*pad],...
    'fontsize',10,...
    'backgroundcolor',get(S.fh,'Color'));
S.Mask_Overlay(3)=uicontrol('style','checkbox',...                                      
    'unit','pix',...
    'position',[figwidth-11*pad figheight-30*pad+2 3*pad 2*pad],...
    'fontsize',10,...
    'backgroundcolor',get(S.fh,'Color'));
S.Mask_Overlay(4)=uicontrol('style','checkbox',...                                       
    'unit','pix',...
    'position',[figwidth-7*pad figheight-30*pad+2 3*pad 2*pad],...
    'fontsize',10,...
     'backgroundcolor',get(S.fh,'Color'));
 
 
S.ViewComp=uicontrol('style','checkbox',...                                       
    'unit','pix',...
    'position',[figwidth-18*pad figheight-35*pad+2 12*pad 3*pad],...
    'fontsize',10,...
     'backgroundcolor',get(S.fh,'Color'),'string',{'View Composite'});

%% Draw the first frame of the stack and set callback functions           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Draw the first frame of the stack%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numel(S.data)
axes(S.ax(i))
imshow(squeeze(S.staticI{i}(:,:,1)));                                       %Display the first frame
set([S.Mask_Overlay(i),S.Int(i)],'callback',{@Update_GUI,S,data{1}.fh});                                   %Shared callback function for fram selection slider and editbar
axis equal tight                                                            %Make sure it's to scale
end            
%%%%%%Set callback functions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set([S.ed1,S.sl1,S.ed2,S.sl2],'call',{@Update_GUI,S,data{1}.fh});                                   %Shared callback function for fram selection slider and editbar
set(S.maskpopup,'Callback',{@Update_GUI,S,data{1}.fh})
set(S.ViewComp,'Callback',{@View_Composite,S,data{1}.fh,1});
guidata(S.fh,S)
end



function []=Update_GUI(varargin)
[h,S] = varargin{[1,3]};
S=guidata(S.fh);


switch h
    case S.sl1
        slidervalue=round(get(h,'value'));                                  % Get the new slider value
        set(S.ed1,'string',slidervalue)
    case S.sl2
        slidervalue=round(get(h,'value'));                                  % Get the new slider value
        set(S.ed2,'string',slidervalue)
    case S.ed1
        sliderstate =  get(S.sl1,{'min','max','value'});                     % Get the slider's info
        enteredvalue = str2double(get(h,'string'));                         % The new frame number
        
        if enteredvalue >= sliderstate{1} && enteredvalue <= sliderstate{2} %Check if the new frame number actually exists
            slidervalue=round(enteredvalue);
            set(S.sl1,'value',slidervalue)                                   %If it does, move the slider there
        else
            set(h,'string',sliderstate{3})                                  %User tried to set slider out of range, keep value
            return
        end
    case S.ed2
        sliderstate =  get(S.sl2,{'min','max','value'});                     % Get the slider's info
        enteredvalue = str2double(get(h,'string'));                         % The new frame number
        
        if enteredvalue >= sliderstate{1} && enteredvalue <= sliderstate{2} %Check if the new frame number actually exists
            slidervalue=round(enteredvalue);
            set(S.sl2,'value',slidervalue)                                   %If it does, move the slider there
        else
            set(h,'string',sliderstate{3})                                  %User tried to set slider out of range, keep value
            return
        end
    case {S.Mask_Overlay(1),S.Mask_Overlay(2),S.Mask_Overlay(3),S.Mask_Overlay(4)}
        S.Overlay_Mod(ismember(S.Mask_Overlay,h))=(get(h,'value'));
    case {S.Int(1),S.Int(2),S.Int(3),S.Int(4)}
        S.IntensityMod(ismember(S.Int,h))=str2double(get(h,'string'));

end

imPlane=get(S.sl1,'value');
mROI=get(S.sl2,'value');
S=setROI(S,mROI,imPlane);

for i=1:numel(S.I)
    axes(S.ax(i))
    imshow(S.I{i})
end

View_Composite(1,1,S,varargin{4},2)
guidata(S.fh,S)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Change and Set ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S]=setROI(S,ROI,imPlane)
S.ROI=ROI;
S.CornerX=S.data{S.MChan}{2,9}{ROI,3}(2)+1;
S.CornerY=S.data{S.MChan}{2,9}{ROI,3}(1)+1;
S.Height=S.data{S.MChan}{2,9}{ROI,4}(2)-1;
S.Width=S.data{S.MChan}{2,9}{ROI,4}(1)-1;
for i=1:numel(S.data)
    if i==S.MChan
        Region_Obj=mROI_Obj([cell(1,8),{S.data},S.metadata],S.ROI);
        Final_Perm=Region_Obj.getmROI_Image(i,'Perimeter');
        Final_Perm=cat(3,Final_Perm,bwperim(max(Final_Perm,[],3)));
        S.Perim=Final_Perm;
    end
end

for i=1:numel(S.data)
Region_Obj=mROI_Obj([cell(1,8),{S.data},S.metadata],S.ROI);
    S.I{i}=Region_Obj.getmROI_Image(i,'Intensity')*S.IntensityMod(i);
    S.I{i}(:,:,size(S.I{i},3)+1)=max(S.I{i},[],3);
    S.Ib{i}=Region_Obj.getmROI_Image(i,'Binary');
    S.Ib{i}(:,:,size(S.Ib{i},3)+1)=max(S.Ib{i},[],3);
    S.staticI{i}=S.I{i};
    S.Ib{i}=(squeeze(S.Ib{i}(:,:,imPlane)));
    S.I{i}=(squeeze(S.I{i}(:,:,imPlane)));
    S.I{i}=repmat(S.I{i},[1,1,3]);

    if get(S.maskpopup,'value')==2
        S.I{i}(:,:,1)= S.I{i}(:,:,1)+(uint8(S.Perim(:,:,imPlane))*255);
        S.I{i}(:,:,2)= S.I{i}(:,:,2)+(uint8(S.Perim(:,:,imPlane))*255);
        S.I{i}(:,:,3)= S.I{i}(:,:,3)+(uint8(S.Perim(:,:,imPlane))*255);
    end
    if S.Overlay_Mod(i)==1
        Sub_Array=S.I{i}(:,:,1)-uint8(~S.Ib{i}*255);
        S.I{i}(:,:,2)=S.I{i}(:,:,2)-Sub_Array;
        S.I{i}(:,:,3)=S.I{i}(:,:,3)-Sub_Array;
    end
end


guidata(S.fh,S)

end

function []=View_Composite(varargin)
Mode=varargin{5};
S=guidata(varargin{3}.fh);

if get(S.ViewComp,'value')==0
    Comp_Controller=get(findobj(0,'tag','Snapshot_Control'),'userdata');
    try
        close(Comp_Controller.fh)
    catch
    end
else

    if Mode==1
        Comp_Controller=SnapShot_Builder(varargin{4},varargin{3});
    else
        Comp_Controller=get(findobj(0,'tag','Snapshot_Control'),'userdata');
    Comp_Controller=Comp_Controller{1,1};
    end

    data=guidata(varargin{4});
    set(Comp_Controller.Capture,'visible','off')
    set(Comp_Controller.SliceMenu,'enable','off')
    set(Comp_Controller.ObjMenu,'enable','off')
    if get(S.sl1,'value')==get(S.sl1,'max')
        set(Comp_Controller.SliceMenu,'value',1)
    else
        set(Comp_Controller.SliceMenu,'value',str2double(get(S.ed1,'string'))+1)
    end
    
    set(Comp_Controller.ObjMenu,'value',str2double(get(S.ed2,'string'))+1)
    
    for i=1:numel(data{9})
        set(Comp_Controller.Type(i),'enable','off')
        set(Comp_Controller.Fill(i),'enable','off')
        if S.MChan==i
            if get(S.maskpopup,'value')==2
                set(Comp_Controller.Type(i),'value',1)
                set(Comp_Controller.Fill(i),'value',2)
                set(Comp_Controller.Fill(i),'string',{'Mask','Perimeter'})
                
            elseif S.Overlay_Mod(i)==1
                set(Comp_Controller.Type(i),'value',1)
                set(Comp_Controller.Fill(i),'value',1)
                set(Comp_Controller.Fill(i),'string',{'Mask','Perimeter'})
            else
                set(Comp_Controller.Type(i),'value',2)
                set(Comp_Controller.Fill(i),'value',1)
                set(Comp_Controller.Fill(i),'string',{'All','Cut-Out'})
            end
        else
            if S.Overlay_Mod(i)==1
                set(Comp_Controller.Type(i),'value',1)
                set(Comp_Controller.Fill(i),'value',1)
                set(Comp_Controller.Fill(i),'string',{'Mask','Perimeter'})
                
            else
                set(Comp_Controller.Type(i),'value',2)
                set(Comp_Controller.Fill(i),'value',1)
                set(Comp_Controller.Fill(i),'string',{'All','Cut-Out'})
                
            end
        end
        
    end
    set(Comp_Controller.fh,'userdata',Comp_Controller)
    %}
    if Mode==1
        C.Image_Window=figure('tag','Comp_Window','visible','off');
        C.Parent_Ax = axes('units','normalized','parent',C.Image_Window,...
            'position',[0 0 1 1],...
            'fontsize',10,...
            'nextplot','replacechildren','XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],'visible','off');
        set(C.Image_Window,'CloseRequestFcn',{@CRF,C.Image_Window,Comp_Controller.fh})
        set(Comp_Controller.fh,'CloseRequestFcn',{@CRF,C.Image_Window,Comp_Controller.fh})
        set(C.Image_Window,'userdata',C)
    else
        C=get(findobj(0,'tag','Comp_Window'),'userdata')    ;
        C=C{1,1};
    end
    
    Generate_SnapShot(1,1,Comp_Controller,data,C)
end

end


function []=CRF(varargin)
[~,Image_H,Control_H] = varargin{[1,3,4]};

        delete(Image_H)
        delete(Control_H)

end