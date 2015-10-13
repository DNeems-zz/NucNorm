function   [FSS_data,delta_ROIs]=BatchDel(mROIs,FSS_data)

Num_Master_ROIs=size(FSS_data{2},1);
Rows=ceil(Num_Master_ROIs/10);

DelPan.fh = figure('units','normalized',...
    'position',[.37 .5 .05*ceil(Num_Master_ROIs/10) .4],...
    'menubar','none',...
    'name','Check mROI to Remove',...
    'numbertitle','off',...
    'resize','off');

for i=1:Rows
    for j=1:10
        if (((i-1)*10)+j)>Num_Master_ROIs
       DelPan.CB(j,i)=uicontrol('Style','CheckBox','String',num2str(((i-1)*10)+j),...
    'units','normalized','pos',[.05+(1/Rows*(i-1)) 1-(.09*j) .5 .09],'parent',DelPan.fh,...
    'backgroundcolor',get(DelPan.fh,'color'),'fontsize',10,'HorizontalAlignment','left','visible','off');
        else
       DelPan.CB(j,i)=uicontrol('Style','CheckBox','String',num2str(((i-1)*10)+j),...
    'units','normalized','pos',[.05+(1/Rows*(i-1)) 1-(.09*j) .5 .09],'parent',DelPan.fh,...
    'backgroundcolor',get(DelPan.fh,'color'),'fontsize',10,'HorizontalAlignment','left');
            
        end
    end
end
DelPan.ApplySelection=uicontrol('style','pushbutton','units','normalized',...
    'position',[.25 .02 ,.5,.045],'string','Delete','backgroundcolor',...
    get(DelPan.fh,'Color'),'fontsize',10,'FontWeight','bold','callback',{@Choose_ROIs,DelPan});


waitfor(DelPan.fh,'UserData');
Del_Index=false(numel(DelPan.CB),1);
for i=1:numel(DelPan.CB)
    Del_Index(i,1)=get(DelPan.CB(i),'value');
end
Del_Rows=find(Del_Index);

D=nan;

if mROIs~=0
    [FSS_data,delta_ROIs,~]=Remove_Assosciation(FSS_data,Del_Rows,D,mROIs);
else
    [FSS_data,delta_ROIs,~]=Remove_Outright(FSS_data,Del_Rows,mROIs);
end

close(DelPan.fh)
end

function []=Choose_ROIs(varargin)
set(varargin{3}.fh,'Userdata',1)
end