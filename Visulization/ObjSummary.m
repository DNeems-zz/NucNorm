function [h]=ObjSummary(varargin)

data = guidata(varargin{1});
MChan=data{10}(1).Channel_Master;
NumChan=numel(data{9});
Obj_Summary=cell(1,NumChan);
for i=1:NumChan
    if ~isempty(data{9}{i})
        Obj_Summary(1,i)=Extract_Data(data,6,i,2);
    end
end


sdata=zeros(size(Obj_Summary{MChan},1),NumChan);
mROI_Num=cell2mat(Obj_Summary{MChan}(:,3));
for i=1:size(Obj_Summary{MChan},1)
    for j=1:NumChan
            if isempty(data{9}{j})
                sdata(i,j)=nan;
            else
                sdata(i,j)=numel(Find_RowPull(Obj_Summary{1,j}(:,3),mROI_Num(i,1)));
            end
    end
end

rNames=1:1:size(data{9}{data{10}(1).Channel_Master}{2,9},1);
cnames = {data{10}.Channel_ID};

h.fh=figure;
set(0,'Units','pixels');
scnsize = get(0,'ScreenSize');
set(h.fh,'OuterPosition',[scnsize(3)*.8,...
    floor(scnsize(4)*.44),...
    scnsize(3)*.2,...
    scnsize(4)*.55],'tag','TableParent','name','Data Summary','menubar','none','numbertitle','off')
h.sp = uipanel('Parent',h.fh,...
    'Position',[0 .1 1 .9]);
str_Data = reshape(strtrim(cellstr(num2str(sdata(:)))), size(sdata));

h.Table=uitable('parent',h.sp,'units','Normalized','Position',[0 0 1 1],'ColumnName',cnames,...
    'RowName',rNames,'Data',str_Data,'tag','TabVal');

h.Bounds= uicontrol('Style','text','String','Obj # Bounds',...
    'units','normalized','pos',[0 0 .25 .07],'parent',h.fh,...
    'backgroundcolor',get(h.fh,'color'),'fontsize',10,'HorizontalAlignment','Left','visible','on');
h.LowerNumTitle= uicontrol('Style','text','String','Lower',...
    'units','normalized','pos',[.25 0 .15 .07],'parent',h.fh,...
    'backgroundcolor',get(h.fh,'color'),'fontsize',10,'HorizontalAlignment','Left','visible','on');
h.LowerNumValue=uicontrol('style','edit','units','normalized',...
    'position',[.35 .034 .07 .04],'string',varargin{2},'backgroundcolor',[1 1 1],...
    'fontsize',8,'parent',h.fh,'visible','on');
h.UpperNumTitle= uicontrol('Style','text','String','Upper',...
    'units','normalized','pos',[.45 0 .15 .07],'parent',h.fh,...
    'backgroundcolor',get(h.fh,'color'),'fontsize',10,'HorizontalAlignment','Left','visible','on');
h.UpperNumValue=uicontrol('style','edit','units','normalized',...
    'position',[.55 .034 .07 .04],'string',varargin{3},'backgroundcolor',[1 1 1],...
    'fontsize',8,'parent',h.fh,'visible','on');
h.update=uicontrol('style','pushbutton','units','normalized',...
    'position',[.65 .02 ,.3,.06],'string','Update','backgroundcolor',...
    get(h.fh,'Color'),'fontsize',10,'callback',{@update,h,MChan});
set(h.fh,'Userdata',h)
update(0,0,h,MChan)
end
function []=update(varargin)

H=varargin{3};
LL=str2double(get(H.LowerNumValue,'string'));
UL=str2double(get(H.UpperNumValue,'string'));

str_Data=get(H.Table,'Data');
htmlLess_str=cell(numel(str_Data),1);
for i=1:numel(str_Data)
htmlLess_str{i,1}=Remove_HTML_Tag(str_Data(i));

end
str_Data = reshape((htmlLess_str(:)), size(str_Data));
Data = reshape(str2double(str_Data(:)), size(str_Data));

MChan=varargin{4};

% find cells matching condition
for i=1:size(str_Data,2)
    for j=1:size(str_Data,1)
        if i~=MChan
            if Data(j,i)>=UL
                 str_Data(j,i)=strcat('<html><span style="color: red;">', ...
                    str_Data(j,i), '</span></html>');
            elseif Data(j,i)<=LL
                 str_Data(j,i)=strcat('<html><span style="color: green;">', ...
                   str_Data(j,i),'</span></html>');
            else
            end
        end
    end
end
set(H.Table,'Data',str_Data)
set(H.fh,'Userdata',H)

end

function [Trimed_Str]=Remove_HTML_Tag(Input_String)

rm_Prefix=regexp(Input_String,';">','split');
rm_Suffix=regexp(rm_Prefix{1}{end},'</span','split');
Trimed_Str=strtrim(rm_Suffix{1});
end


