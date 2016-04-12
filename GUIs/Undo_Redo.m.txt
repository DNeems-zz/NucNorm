function []=Undo_Redo(varargin)
data=guidata(varargin{1});
handle=data{1};
MasterROI_Choice=get(handle.MasterROIMenu,'value');
Channel_Choice=get(handle.ChannelMenu,'value');
Projection_Choice=get(handle.DisplayTypeMenu,'value');
Display_Choice=get(handle.DisplayModeMenu,'value');
List=data{11}{Display_Choice,Channel_Choice}{1};
FlipList=[2,1];

switch varargin{3}
    case 'Undo'
        % Still Need ot make this work
        Pos=data{11}{Display_Choice,Channel_Choice}{2};
Row=data{11}{Display_Choice,Channel_Choice}{2};
        data{11}{Display_Choice,Channel_Choice}{2}=data{11}{Display_Choice,Channel_Choice}{2}-1;
        
    case 'Redo'
        Pos=data{11}{Display_Choice,Channel_Choice}{2}+1;
        Row=data{11}{Display_Choice,Channel_Choice}{2}+1;
        
        data{11}{Display_Choice,Channel_Choice}{2}=data{11}{Display_Choice,Channel_Choice}{2}+1;
        
end

Mod_ROIs=cell(1,3);
delta_ROI=cell(size(List{Pos,2},1),2);
Del_Index=zeros(size(List{Pos,2},1),1);

for i=1:size(List{Pos,2},1)
    delta_ROI{i,1}=List{Pos,2}{i,1};
    delta_ROI{i,2}=FlipList(List{Pos,2}{i,2});
    switch   delta_ROI{i,2}
        case 1
            Del_Index(i,1)=find(ismember(List{Pos,1}{3},List{Pos,2}{i,1}{3},'rows'));
            if i==size(List{Pos,2},1)
             for j=1:3
                Mod_ROIs{1,j}=List{Pos,1}{j};
                Mod_ROIs{1,j}(Del_Index,:)=[];
            end
            end
        case 2    
            if i==size(List{Pos,2},1)
                Add_Stuff=vertcat(List{Pos,2}{:,1});
                for j=1:3
                    Mod_ROIs{1,j}=vertcat(List{Pos,1}{j},vertcat(Add_Stuff{:,j}));
                end
            end
    end
end

        data{11}{Display_Choice,Channel_Choice}{1}(Row,:)=[{Mod_ROIs},{delta_ROI}];
        Manipulation_PostProcess(Mod_ROIs,delta_ROI,data,'UR')

end