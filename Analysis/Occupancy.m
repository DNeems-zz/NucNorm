function data=Occupancy(varargin)

Mode=varargin{3};
data=guidata(varargin{1});
MChan=data{10}(1).Channel_Master;
Region_Objs=cell(size(data{9}{MChan}{2,9},1),1);
Num_mROI=size(data{9}{MChan}{2,9},1);
for i=1:Num_mROI
    Region_Objs{i,1}=mROI_Obj(data,i);
end
Shifted_PixelList=cell(Num_mROI,1);
Shifted_permPixelList=cell(Num_mROI,1);
Cali.X=data{10}(MChan).CaliMetaData.XCal;
Cali.Y=data{10}(MChan).CaliMetaData.YCal;
Cali.Z=data{10}(MChan).CaliMetaData.ZCal;

for i=1:Num_mROI
    Shifted_PixelList(i,1)=Region_Objs{i,1}.getPixel_List(MChan,'Whole','Microns');
    Shifted_permPixelList(i,1)=Region_Objs{i,1}.getPixel_List(MChan,'Perimeter','Microns');
end




set(data{1}.fh,'visible','off')

Control.fh = figure('units','normalized',...
'position',[.35 .55 .3 .1],...
'menubar','none',...
'name','Simulation Settings',...
'numbertitle','off',...
'resize','off','visible','on');
Control.Text_SimPoints=uicontrol('Style','text','String','Number of Points',...
    'units','normalized','pos',[.05 .3 .2 .5],'backgroundcolor',get(Control.fh,'color'),'fontsize',10);

Control.SimPoints = uicontrol('Style','edit','String','7500',...
    'units','normalized','pos',[.25 .6 .2 .2],...
    'fontsize',10);
Control.Simulate = uicontrol('Style','pushbutton','String','Simulate',...
    'units','normalized','pos',[.43 .05 .2 .3],...
    'fontsize',12);



switch Mode
    case 1
        %'Nearest Neighboor'
        
        Control.Text_Distance=uicontrol('Style','text','String','Percent of Max Distance:',...
            'units','normalized','pos',[.45 .5 .2 .3],'backgroundcolor',get(Control.fh,'color'),'fontsize',10);
        
        Control.Distance = uicontrol('Style','edit','String','.9',...
            'units','normalized','pos',[.65 .6 .2 .2],...
            'fontsize',12);
        Control.Emprical = uicontrol('Style','Checkbox','String',{'Empirically derived'},...
            'units','normalized','pos',[.66 .3 .3 .2],...
            'fontsize',10,'backgroundcolor',get(Control.fh,'color'),'callback',{@greyout,Control.Distance});
        Control.Emprical2 = uicontrol('Style','text','String',{'minimum distance'},...
            'units','normalized','pos',[.64 .13 .3 .2],...
            'fontsize',10,'backgroundcolor',get(Control.fh,'color'));
     
        set(Control.Simulate,'callback',{@NN,Shifted_PixelList,Shifted_permPixelList,Cali,data},'userdata',Control)
    case 2
        %'Linear Interpolation'
                set(Control.Simulate,'callback',{@LI,Shifted_PixelList,data,Cali})


    case 3
        %'Inside Hull (Convex)'
        set(Control.Simulate,'callback',{@cHull,Shifted_PixelList,Shifted_permPixelList,Cali,data})

        
end

%set(data{1}.fh,'visible','on')
%guidata(data{1}.fh,data);


end

function []=NN(varargin)


[Shifted_PixelList,Shifted_permPixelList,Cali,data]=varargin{[3,4,5,6]};
MChan=data{10}(1).Channel_Master;
Control=get(varargin{1},'userdata');
numPoints=str2double(get(Control.SimPoints,'string'));
Dist_Percent=str2double(get(Control.Distance,'string'));
if get(Control.Emprical,'value')==1
Mean_permDist=cell(size(Shifted_PixelList,1),1);
for i=1:size(Shifted_PixelList,1)
    Mean_permDist{i,1}=zeros(size(Shifted_permPixelList{i,1},1),1);
    for j=1:size(Shifted_permPixelList{i,1},1)
        nnIndex=knnsearch(Shifted_permPixelList{i,1}(j,:), Shifted_PixelList{i,1},26);
        Mean_permDist{i,1}(j,1)=mean(pdist2(Shifted_permPixelList{i,1}(j,:),Shifted_PixelList{i,1}(nnIndex,:)));
    end
    
end
Cutoff=mean(cellfun(@mean,Mean_permDist));
else
Cutoff=pdist2([0,0,0],[Cali.X,Cali.Y,Cali.Z])*Dist_Percent;
end
Internal_Points=cell(size(Shifted_PixelList,1),1);
Start_Time=clock;

for i=1:size(Shifted_PixelList,1)
    Loop_Start_Time=clock;
    display(sprintf('Commuting Nearest Neighbor Occupancy for mROI: %d of %d',i,size(Shifted_PixelList,1)))
    [Lower_Bounds,Upper_Bounds]=findBounds(Shifted_PixelList{i,1},Cali,10);
    z=1;
    Internal_Points{i,1}=zeros(1,3);
    tic
    while z<numPoints+1
        randPoint=zeros(1,3);
        for j=1:3
            randPoint(1,j)=Rand_inRange(Lower_Bounds(j),Upper_Bounds(j),1,.01);
        end
        
        nnIndex=knnsearch(randPoint, Shifted_PixelList{i,1},26);
        if mean(pdist2(randPoint,Shifted_PixelList{i,1}(nnIndex,:)))<=Cutoff
            z=z+1;
            Internal_Points{i,1}(end+1,:)=randPoint;
            if mod(z,1000)==0
                display(sprintf('Found %d/%d Points  Computation Time (min): %0.2f',z,numPoints,toc/60))
            end
        end
    end
        Internal_Points{i,1}(1,:)=[];

    display(sprintf('Found %d/%d Points',z,numPoints))
      Loop_End_Time=clock;
    display(sprintf('Loop Computation time(min): %0.2f' ,etime(Loop_End_Time,Loop_Start_Time)/60))
    display(sprintf('Total Computation time(min): %0.2f' ,etime(Loop_End_Time,Start_Time)/60))
  
end
data{9}{MChan}{2,9}(:,5)=Internal_Points;
close(Control.fh)
set(data{1}.fh,'visible','on')
guidata(data{1}.fh,data);

end

function  []=LI(varargin)
[Shifted_PixelList,data,Cali]=varargin{[3,4,5]};

MChan=data{10}(1).Channel_Master;
Six=data{9}{MChan}{2,6};
FS=data{9}{MChan}{2,7};
mRegions=data{9}{MChan}{2,9};
Control=get(varargin{1},'userdata');
numPoints=str2double(get(Control.SimPoints,'string'));
Start_Time=clock;
Internal_Points=cell(size(Shifted_PixelList,1),1);
for i=1:size(Shifted_PixelList,1)
Loop_Start_Time=clock;
display(sprintf('Commuting Linear Interpolation Occupancy for mROI: %d of %d',i,size(Shifted_PixelList,1)))
    ROI_Num=mRegions{i,2};
    [RowPull]=Find_RowPull(Six(:,3),ROI_Num);
    imRegion=false(mRegions{i,4});
    iFS=FS(RowPull,:)-mRegions{i,3};
    [W,H,D]=size(Six{RowPull,1});
if iFS(3)<1
    iFS(3)=1;
end
    imRegion(iFS(2):iFS(2)+W-1,...
        iFS(1):iFS(1)+H-1,...
        iFS(3):iFS(3)+D-1)=Six{RowPull,1};
    for j=1:size(imRegion,3)
    imRegion(:,:,j)=imfill(imRegion(:,:,j),'holes');
    end
    PL=regionprops(imRegion,'pixellist');
    tPL=(PL.PixelList).*repmat([Cali.X,Cali.Y,Cali.Z],size(PL.PixelList,1),1);
    Lower_Bounds=1.*[Cali.X,Cali.Y,Cali.Z];
    Upper_Bounds=size(imRegion).*[Cali.X,Cali.Y,Cali.Z];
    
    X_Range=Lower_Bounds(2):Cali.X:Upper_Bounds(2);
    Y_Range=Lower_Bounds(1):Cali.Y:Upper_Bounds(1);
    Z_Range=Lower_Bounds(3):Cali.Z:Upper_Bounds(3);
    [X,Y,Z]=meshgrid(X_Range,Y_Range,Z_Range);
    Expansion_Factor=(numPoints*10)/size(tPL,1);
    exp_X_Range=Lower_Bounds(2):Cali.X/Expansion_Factor:Upper_Bounds(2);
    exp_Y_Range= Lower_Bounds(1):Cali.Y/Expansion_Factor:Upper_Bounds(1);
    exp_Z_Range=Lower_Bounds(3):Cali.Z/Expansion_Factor:Upper_Bounds(3);
    [Xq,Yq,Zq]=meshgrid(exp_X_Range,exp_Y_Range,exp_Z_Range);
    R=griddata(X,Y,Z,double(imRegion),Xq,Yq,Zq);
    R(R>=1)=1;
    R(R<1)=0;
    R(isnan(R))=0;

    R=logical(R);
    a=regionprops(R,'pixellist');
    a=vertcat(a(:).PixelList);
    InsidePix=zeros(size(a,1),3);
    for j=1:size(a,1)
    InsidePix(j,:)=[exp_X_Range(a(j,1)),...
        exp_Y_Range(a(j,2)),...
        exp_Z_Range(a(j,3))];    
    end
Internal_Points{i,1}=InsidePix(randsample(size(InsidePix,1),numPoints,0),:);
  Loop_End_Time=clock;
    display(sprintf('Loop Computation time(min): %0.2f' ,etime(Loop_End_Time,Loop_Start_Time)/60))
    display(sprintf('Total Computation time(min): %0.2f' ,etime(Loop_End_Time,Start_Time)/60))
  
    
end
close(Control.fh)

data{9}{MChan}{2,9}(:,6)=Internal_Points;
set(data{1}.fh,'visible','on')
guidata(data{1}.fh,data);
end

function []=cHull(varargin)
[Shifted_PixelList,Shifted_permPixelList,Cali,data]=varargin{[3,4,5,6]};
Control=get(varargin{1},'userdata');
MChan=data{10}(1).Channel_Master;
numPoints=str2double(get(Control.SimPoints,'string'));
%Remove Planes with very low number of pixels in them
Plane_Occupancy_Min=.01;
Internal_Points=cell(size(Shifted_PixelList,1),1);
Start_Time=clock;
for i=1:size(Shifted_PixelList,1)
Loop_Start_Time=clock;
    display(sprintf('Commuting Convex Hull Occupancy for mROI: %d of %d' ,i,size(Shifted_PixelList,1)))

    uPlane=unique(Shifted_PixelList{i,1}(:,3));
    tPlane_Res=zeros(numel(uPlane),1);
    for j=1:numel(uPlane)
        tPlane_Res(j,1)=sum(Shifted_PixelList{i,1}(:,3)==uPlane(j,1))/size(Shifted_PixelList{i,1},1);   
    end
    PerimTrim=Shifted_permPixelList{i,1}(~ismember(Shifted_permPixelList{i,1}(:,3),uPlane(tPlane_Res<=Plane_Occupancy_Min,:)),:);
    [Lower_Bounds,Upper_Bounds]=findBounds(Shifted_PixelList{i,1},Cali,0);
    z=1;
    Internal_Points{i,1}=zeros(1,3);
    tic
    while z<numPoints+1
        randPoint=zeros(1,3);
        for j=1:3
            randPoint(1,j)=Rand_inRange(Lower_Bounds(j),Upper_Bounds(j),1,.01);
        end
        P=inhull(randPoint,PerimTrim);
        if P==1
            z=z+1;
            Internal_Points{i,1}(end+1,:)=randPoint;
            if mod(z,1000)==0
                display(sprintf('Found %d/%d Points  Computation Time (min): %0.2f',z,numPoints,toc/60))
            end
        end
        
    end
    Internal_Points{i,1}(1,:)=[];
    display(sprintf('Found %d/%d Points',z,numPoints))
    Loop_End_Time=clock;
    display(sprintf('Loop Computation time(min): %0.2f' ,etime(Loop_End_Time,Loop_Start_Time)/60))
    display(sprintf('Total Computation time(min): %0.2f' ,etime(Loop_End_Time,Start_Time)/60))
    
    
end
data{9}{MChan}{2,9}(:,7)=Internal_Points;
set(data{1}.fh,'visible','on')
close(Control.fh)
guidata(data{1}.fh,data);
end

function Random_Point=Rand_inRange(min_Val,max_Val,NumPoints,Decimal_Place)
min_Val=double(min_Val)/Decimal_Place;
max_Val=double(max_Val)/Decimal_Place;
Random_Point = (max_Val-min_Val).*rand(NumPoints,1) + min_Val;
Random_Point=round(Random_Point)*Decimal_Place;
end

function [Lower_Bounds,Upper_Bounds]=findBounds(PL,Cali,Multi)
Lower_Bounds=(min(PL))-(Multi*[Cali.X,Cali.Y,Cali.Z]);
    Upper_Bounds=(max(PL))+(Multi*[Cali.X,Cali.Y,Cali.Z]);
    for j=1:numel(Lower_Bounds)
        if Lower_Bounds(j)<0
            Lower_Bounds(j)=0;
        end
    end
end

function []=greyout(varargin)
switch get(varargin{1},'value')
    case 1
        set(varargin{3},'enable','off')
    case 0
        set(varargin{3},'enable','on')
end

end