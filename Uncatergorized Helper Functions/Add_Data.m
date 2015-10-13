function [data]=Add_Data(data,Add_Index,Add_Val,Chan,Disp)


try data{9}{Chan}{1,Add_Index(1)};
    for i=1:numel(Add_Index)
        data{9}{Chan}{Disp,Add_Index(i)}=Add_Val{i};
    end
catch
    
    for i=1:numel(Add_Index)
        data{Add_Index(i)}{Disp,Chan}=Add_Val{i};
    end
    
end

end