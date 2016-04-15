function [data]=Remove_Data(data,Remove_Index,Chan,Disp,rmRow)


try
    for i=1:numel(Remove_Index)
        if rmRow==0
            data{9}{Chan}{Disp,Remove_Index(i)}=[];
        else
            data{9}{Chan}{Disp,Remove_Index(i)}(rmRow,:)=[];
        end
    end
catch
    for i=1:numel(Remove_Index)
        if rmRow==0
            data{Remove_Index(i)}{Disp,Chan}=[];
        else
            data{Remove_Index(i)}{Disp,Chan}(rmRow,:)=[];
        end
    end
    
end

end