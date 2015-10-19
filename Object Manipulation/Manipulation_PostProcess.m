function []=Manipulation_PostProcess(Mod_ROIs,delta_ROIs,data,source)
handles=data{1};
Current_Chan=get(handles.ChannelMenu,'value');
Current_mROI=get(handles.MasterROIMenu,'value');
Current_Display=get(handles.DisplayModeMenu,'value');


switch source
    case 'New'        
        %Add New Segementation layer
        data{10}(1).ManipNum=data{10}(1).ManipNum+1;
        handles.ManipulationNumber=data{10}(1).ManipNum;
        data{2}{Current_Display,Current_Chan}=false(handles.IMSize);

    case 'Modify'
        %Modify an object in an exsiting segementation layer
    data{10}(1).ManipNum=data{10}(1).ManipNum+1;
        handles.ManipulationNumber=data{10}(1).ManipNum;
        %data{2}{Current_Display,Current_Chan}=false(handles.IMSize);
        
        data{11}{Current_Display,Current_Chan}{1}=data{11}{Current_Display,Current_Chan}{1}(1:data{11}{Current_Display,Current_Chan}{2},:);
        data{11}{Current_Display,Current_Chan}{2}=data{11}{Current_Display,Current_Chan}{2}+1;
        data{11}{Current_Display,Current_Chan}{1}=vertcat(data{11}{Current_Display,Current_Chan}{1},[{Mod_ROIs},{delta_ROIs}]);
    
    case 'UR'
        
        %Undo/Redo Something
        
end

%Adds new data back in
if ~isempty(Mod_ROIs{1,1})
[Mod_ROIs,delta_ROIs]=ROI_Filter(Mod_ROIs,delta_ROIs,.9,3,data);
end

[data]=Add_Data(data,[5,6,7],...
    Mod_ROIs,...
    Current_Chan,Current_Display);


[Image]=Extract_Data(data,2,Current_Chan,Current_Display);
Image=Image{:};
if isempty(Image)
    Image=false(handles.IMSize);
end

[~,I]=sort(cell2mat(delta_ROIs(:,2)));
delta_ROIs=delta_ROIs(I,:);

for i=1:size(delta_ROIs,1)
    if delta_ROIs{i,2}==1
        rmImage=Six_to_Image(delta_ROIs{i,1}{1,2},delta_ROIs{i,1}{1,3},handles.IMSize,'Remove');
        Image=logical(Image-rmImage);
    elseif delta_ROIs{i,2}==2
        addImage=Six_to_Image(delta_ROIs{i,1}{1,2},delta_ROIs{i,1}{1,3},handles.IMSize,'Add');
        Image=logical(Image+addImage);
    end
end




[data]=Add_Data(data,2,...
    {Image},...
    Current_Chan,Current_Display);
[data]=Add_Data(data,3,...
    {max(Image,[],3)},...
    Current_Chan,Current_Display);




Image=repmat(max(Image,[],3),[1,1,3]);
set(handles.ImagePlace_Handle,'cData',Image)
handles.cLabelMatrix_Toggle(Current_Display,Current_Chan)=false;

handles.CurrentView=max(get(handles.ImagePlace_Handle,'cData'),[],3);
guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)])
get(handles.IMAxes,'UserData');

if ~isempty(findobj('tag','TableParent'))
    Table_H=findobj('tag','TableParent');
    H=get(Table_H,'Userdata');
    ObjSummary(data{1}.fh,get(H.LowerNumValue,'string'),get(H.UpperNumValue,'string'))
    close (Table_H)
end
ChangeDisplay(handles.fh,[],7)


end


function [Mod_ROIs,delta_ROIs]=ROI_Filter(Mod_ROIs,delta_ROIs,Prcnt_Overlap,Excl_Size,data)

[Mod_ROIs,Red_Row]=Redundant_Check(Mod_ROIs,Prcnt_Overlap,data);
Mod_Del=false(size(Mod_ROIs{2},1),1);
for i=1:size(Mod_ROIs{2},1)
    if sum(sum(sum(Mod_ROIs{2}{i,1})))<=Excl_Size
        Mod_Del(i,1)=true;
    end
end
Red_FS=Mod_ROIs{3}(Mod_Del,:);
Red_Cent=vertcat(Mod_ROIs{2}{Mod_Del,4});

for i=1:3
    Mod_ROIs{i}(Mod_Del,:)=[];
end
Red_FS=vertcat(Red_FS,Red_Row{3});
Red_Cent=vertcat(Red_Cent,vertcat(Red_Row{2}{:,4}));

if ~(isempty(delta_ROIs{1,1}))

    rm_delta_ROIs=false(size(delta_ROIs,1),1);
for i=1:size(delta_ROIs,1)
    for j=1:size(Red_FS,1)
        if ismember(Red_FS(j,:),delta_ROIs{i,1}{1,3},'rows')==1  && ismember(Red_Cent(j,:),delta_ROIs{i,1}{2}{1,4},'rows')==1;
            rm_delta_ROIs(i,1)=true;
        end
    end
    
end

if sum(rm_delta_ROIs)~=0
Potential_delta=delta_ROIs(rm_delta_ROIs,1);
Potential_delta=vertcat(Potential_delta{:});
[~,uIndex]=unique(vertcat(Potential_delta{:,3}),'rows');
rmIndex_Index=true(size(Potential_delta,1),1);
rmIndex_Index(uIndex,:)=false;
rm_delta_ROIs=find(rm_delta_ROIs);
delta_ROIs(rm_delta_ROIs(~rmIndex_Index),:)=[];
end
end
end