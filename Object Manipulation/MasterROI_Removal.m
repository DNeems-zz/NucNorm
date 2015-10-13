function []=MasterROI_Removal(data,rmROI)

handle=data{1};
    NumChan=numel(data{9});
    
    for i=1:NumChan
        if  i==data{10}(1).Channel_Master || isempty(data{9}{i})
        else
            
            set(handle.ChannelMenu,'value',i);
            set(handle.DisplayModeMenu,'value',2);
            
            Mod_ROIs=data{9}{i}(2,5:7);
            [dRow]=Find_RowPull(Mod_ROIs{2}(:,3),rmROI{1});
            Working_Region=rmROI{1};
            [Mod_ROIs,delta_ROIs,data]=Remove_Assosciation(Mod_ROIs,dRow,data,Working_Region);
            Manipulation_PostProcess(Mod_ROIs,delta_ROIs,data,'Modify')
            data=guidata(data{1}.fh);

        end
    end
    [Del_Index]=Find_RowPull(data{9}{data{10}(1).Channel_Master}{2,9}(:,2),rmROI{1});
    data{9}{data{10}(1).Channel_Master}{2,9}(Del_Index,:)=[];
    set(handle.MasterROIMenu,'string',['None',arrayfun(@(x) num2str(x),1:size(data{9}{data{10}(1).Channel_Master}{2,9},1),'uniformoutput',0)])
    guidata(handle.fh,[{handle},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)])

end
