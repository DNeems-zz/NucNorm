function [Requested_Data]=Extract_Data(data,Request_Index,Chan,Disp)

Requested_Data=cell(numel(Disp),numel(Request_Index))   ;
if Disp==0
    for i=1:numel(Request_Index)
        try
            Disp=1:numel(data{9}{Chan}(:,Request_Index(i)));
        catch
           Disp=1:sum(~cellfun(@isempty,data{Request_Index(i)}(:,Chan)));
        end
    end
end
try
    for i=1:numel(Request_Index)
        for j=1:numel(Disp)
            Requested_Data{j,i}=data{9}{Chan}{Disp(j),Request_Index(i)};
        end
    end
catch
    
    for i=1:numel(Request_Index)
        for j=1:numel(Disp)
            Requested_Data{j,i}=data{Request_Index(i)}{Disp(j),Chan};
        end
    end
    
end

end