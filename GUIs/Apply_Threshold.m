function []=Apply_Threshold(varargin)
Mode=varargin{3};
data=guidata(varargin{1});
H=data{1};
Current_Chan=get(H.ChannelMenu,'value');
Current_Display=get(H.DisplayModeMenu,'value');
Current_Display=get(H.DisplayModeMenu,'value');
MChan=data{10}(1).Channel_Master;

switch Mode
    case 1
        %Applying New Base Case
         [data]=Apply_Base(Current_Chan,Current_Display,data);
         
        [data,H]=SetMaster(data,H);
        
        set(H.DisplayModeMenu,'string',[{'Raw Stack'},CallBack_Value_String(H.DisplayModeMenu)]);
        set(H.DisplayModeMenu,'value',2)
        set(H.OverlayMenu,'value',1)
        
        H.CurrentView=max(data{9}{Current_Chan}{2,3},[],3);
        data{11}(:,Current_Chan)=repmat({[{[{'Base'},{'Base'}]},{1}]},size(data{11}(:,Current_Chan),1),1);
        H.cLabelMatrix_Toggle(:,Current_Chan)=0;
try
        H.cLabelMatrix(:,Current_Chan)=[];
catch
end
        guidata(H.fh,[{H},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)])
        get(H.IMAxes,'UserData');
        ChangeDisplay(H.fh,[],5)
        
    case 2
        %Applying to Base Case
        Base_Data=varargin{4}{2};
        New_Data=guidata(varargin{4}{1});
        MChan=Base_Data{10}(1).Channel_Master;
        
        [Final_ROIs,New_ROIs]=Apply_toBase(New_Data,Base_Data);
     
        delta_ROIs=cell(size(New_ROIs{1},1),2);
        for i=1:size(New_ROIs{1},1)
            for j=1:3
                delta_ROIs{i,1}{1,j}=New_ROIs{1,j}(i,:);
            end
            delta_ROIs{i,2}=2;
        end
        data=ResetGUI(New_Data{1});
        guidata(data{1}.fh,Base_Data)
        LoadImage(data{1}.fh,[],4)
        data=guidata(data{1}.fh);
        Sub_H=data{1};
        if New_Data{10}(1).Other(1)==MChan
            %Merge the old and New Data
            for i=1:size(New_ROIs{2},1)
                New_ROIs{2}{i,3}=[];
            end
            cROIs=[data{9}{MChan}(2,5:7);New_ROIs];
            nROIs=cell(1,3);
            for i=1:3
                nROIs{1,i}=vertcat(cROIs{:,i});
            end
            %Remove mROIs that are are being added but are already present
            [Final_ROIs,RM_Obj]=Redundant_Check(nROIs,.9,data);
            rm_delta=false(size(delta_ROIs{1}{2},1),1);
            for i=1:size(RM_Obj{3},1)
                for j=1:size(delta_ROIs{1}{2},1)
                    if sum(ismember(RM_Obj{3}(i,:),delta_ROIs{j,1}{3},'rows'))==1
                        rm_delta(j,1)=true;
                    end
                end
            end
            delta_ROIs(rm_delta,:)=[];
            if sum(cellfun(@isempty,Final_ROIs{2}(:,3)))~=0
              [Final_ROIs,data]=Update_mROIs(data,Final_ROIs,RM_Obj);
              
            end
        end
    
    set(Sub_H.FileMenu,'enable','on')
        set(Sub_H.AnaMenu,'enable','on')
        set(Sub_H.MMenu.Set,'enable','on')
        set(Sub_H.MasterSet,'enable','on')
        set(Sub_H.ChannelMenu,'enable','on')
        set(Sub_H.MasterROIMenu,'enable','on')
        set(Sub_H.ApplySelection,'callback',{@Apply_Threshold,1,[cell(1,3)]})
        set(Sub_H.DisplayModeMenu,'value',New_Data{10}(1).Other(3));
        set(Sub_H.ChannelMenu,'value',New_Data{10}(1).Other(1));
        set(Sub_H.DisplayModeMenu,'value',New_Data{10}(1).Other(3));
        set(Sub_H.MasterROIMenu,'value',New_Data{10}(1).Other(2));
        
        set(Sub_H.OverlayMenu,'value',1);
        %I may have screwed up something here but I think you only want to
        %add to new ROIs
        
        Manipulation_PostProcess(Final_ROIs,vertcat(delta_ROIs,varargin{4}{3}),data,'Modify')
    case 3
        
        Current_mROI=get(H.MasterROIMenu,'value');
        RowPull=data{9}{MChan}{2,9}{Current_mROI-1,2};
        [Pull_Index]=Find_RowPull(data{9}{Current_Chan}{2,6}(:,3),RowPull);
        FSS_data=data{9}{Current_Chan}(2,5:7);
        [FSS_data,delta_ROIs,data]=Remove_Assosciation(FSS_data,Pull_Index,data,RowPull);
        Add_ROIs=data{9}{Current_Chan}(Current_Display,5:7);
        Add=cell(size(Add_ROIs{1},1),2);
        for i=1:size(Add_ROIs{1},1)
            Add{i,1}=[{Add_ROIs{1}(i,:)},{Add_ROIs{2}(i,:)},{Add_ROIs{3}(i,:)}];
            Add{i,2}=2;
            FSS_data{1}=vertcat(FSS_data{1},Add{i,1}{1});
            FSS_data{2}=vertcat(FSS_data{2},Add{i,1}{2});
            FSS_data{3}=vertcat(FSS_data{3},Add{i,1}{3});
        end

        
        
        set(H.DisplayModeMenu,'value',2)
        data{9}{Current_Chan}=data{9}{Current_Chan}(1:2,:);

        Manipulation_PostProcess(FSS_data,vertcat(delta_ROIs,Add),data,'Modify')
        Temp_Menu=get(H.DisplayModeMenu,'String');
        Temp_Menu{2}=strcat(Temp_Menu{2},'*');
        set(H.DisplayModeMenu,'String',Temp_Menu(1:2));
        set(H.ApplySelection,'callback',{@Apply_Threshold,1,cell(1,2)})

end


end

function [Final_ROIs,New_ROIs]=Apply_toBase(NewData,BaseData)

Current_Chan=NewData{10}.Other(1);
Current_mROI=NewData{10}.Other(2);
bCurrent_Display=NewData{10}.Other(3);
nCurrent_Display=get(NewData{1}.DisplayModeMenu,'value');
BB=NewData{10}.Other(5:end);
[Base_ROIs]=Extract_Data(BaseData,[5,6,7],Current_Chan,bCurrent_Display);
[New_ROIs]=Extract_Data(NewData,[5,6,7],1,nCurrent_Display);
for i=1:size(New_ROIs{1},1)
    New_ROIs{3}(i,:)=New_ROIs{3}(i,:)+BB(1:3);
    New_ROIs{2}{i,4}=New_ROIs{2}{i,4}+BB(1:3);
end
if Current_mROI~=1
    RowPull=BaseData{9}{BaseData{10}(1).Channel_Master}{2,9}{Current_mROI-1,2};
    
    for i=1:size(New_ROIs{1},1)
        New_ROIs{3}(i,:)=New_ROIs{3}(i,:)+BB(4:6);
    end
    ROI_Index=repmat({RowPull},1,size(New_ROIs{1},1));
elseif BaseData{1}.MasterSet_Toggle==1
    PolyGons=BaseData{9}{BaseData{10}(1).Channel_Master}{2,9}(:,1);
    ROI_Index=cell(1,size(New_ROIs{1},1));
    for j=1:size(New_ROIs{1},1)
        Match=false(size(PolyGons,1),1);
        for i=1:size(PolyGons,1)
            Match(i,1)=inpolygon(New_ROIs{2}{j,4}(1),New_ROIs{2}{j,4}(2),PolyGons{i}(:,1),PolyGons{i}(:,2));
        end
     ROI_Index{1,j}=transpose([BaseData{9}{BaseData{10}(1).Channel_Master}{2,9}{Match,2}]);   
    end
else
    RowPull=max(cell2mat(Base_ROIs{2}(:,3)));
    ROI_Index=cell(1,size(New_ROIs{1},1));
    
    for i=1:size(New_ROIs{1},1)
        ROI_Index{1,i}=RowPull+i;
    end
end

for i=1:size(New_ROIs{1},1)
    New_ROIs{2}{i,3}=ROI_Index{i};
end

Final_ROIs=cell(1,3);
for i=1:3
    Final_ROIs{1,i}=[Base_ROIs{i};New_ROIs{i}];
end

end

function [BaseData]=Apply_Base(Chan,Disp,BaseData)

if isempty(BaseData{9}{Chan})
    BaseData{9}{Chan}=cell(2,8);
    for i=2:8
        BaseData{9}{Chan}(1,i)=BaseData{i}(1,Chan);
        BaseData{9}{Chan}(2,i)=BaseData{i}(Disp,Chan);
        BaseData{i}(2:end,Chan)=cell(19,1);
    end
    BaseData{9}{Chan}{2,1}=1;
else
    
end
if BaseData{1}.MasterSet_Toggle==1
    [BaseData]=Map_New_mROI(BaseData);
end


end

function [data,H]=SetMaster(data,H)

if get(H.MasterSet,'value')==1
    set(H.MasterSet,'visible','off')
    set(H.MasterSet,'value',0)
    H.MasterSet_Toggle=true;
    
    for i=1:numel(data{10})
        data{10}(i).Channel_Master=get(H.ChannelMenu,'value');
    end
    set(H.MasterROIMenu,'Enable','on','visible','on','value',1)
    set(H.MasterROITitle,'visible','on')
    Objs=cellfun('size',Extract_Data(data,6,get(H.ChannelMenu,'value'),2),1);
    ROI_Num=cell(Objs+1,1);
    ROI_Num{1,1}='None';
    for i=1:Objs
        ROI_Num{i+1,1}=num2str(i);
    end
    set(H.MasterROIMenu,'Enable','on','visible','on','value',1,'string',ROI_Num)
    for i=1:numel(H.byChanObj)
        set(H.byChanObj(i),'visible','on')
    end

    if numel(unique(cell2mat(data{9}{1,get(H.ChannelMenu,'value')}{2,6}(:,3))))~=size(data{9}{1,get(H.ChannelMenu,'value')}{2,6},1)
        for i=1:size(data{9}{1,get(H.ChannelMenu,'value')}{2,6},1)
            data{9}{1,get(H.ChannelMenu,'value')}{2,6}{i,3}=i;
        end
    end
    
    
    mRegions=data{9}{1,get(H.ChannelMenu,'value')}{2,6};
    FS=data{9}{1,get(H.ChannelMenu,'value')}{2,7};
    RawImage=Extract_Data(data,2,get(data{1}.ChannelMenu,'value'),1);

    Expand_Rate=data{1}.MasterExpansion(get(data{1}.DisplayModeMenu,'value'),1);
    [mROI_data]=Create_MasterROI_Desc(mRegions,FS,RawImage,repmat(Expand_Rate,size(mRegions,1),1));
    H.MasterExpansion=Expand_Rate;
    data{9}{get(data{1}.ChannelMenu,'value')}{2,9}=mROI_data;
    [data]=Map_New_mROI(data);
    
elseif H.MasterSet_Toggle==1
    
else
    
end
end

