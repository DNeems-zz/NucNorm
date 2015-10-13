function [Mod_ROIs,delta_ROIs,data]=Remove_Outright(Mod_ROIs,dRow,data)
delete_ROIs=cell(1,3);
for i=1:3
    delete_ROIs{1,i}= Mod_ROIs{1,i}(dRow,:);
    Mod_ROIs{i}(dRow,:)=[];
end
delta_ROIs=cell(size(delete_ROIs{1},1),2);
%delta ROIs column 2 == 1 flag to delete, 2 would be add
for i=1:size(delete_ROIs{1},1)
    for j=1:3
        delta_ROIs{i,1}{1,j}=delete_ROIs{1,j}(i,:);
    end
    delta_ROIs{i,2}=1;

end
end
