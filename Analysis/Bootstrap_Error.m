
function [Mean,uCI,lCI]=Bootstrap_Error(Dist,Simulation_Points,Simulation_Num,CI)
Num_SimPoints=numel(Simulation_Points);

Mean=sum(Simulation_Points<=Dist)/Num_SimPoints;
Error_Compute_pVal=nan(Simulation_Num,1);
for i=1:Simulation_Num
Boot_Dist=Simulation_Points(randsample(1:Num_SimPoints,Num_SimPoints,1),:);
    Error_Compute_pVal(i,1)=sum(Boot_Dist<=Dist)/Num_SimPoints;

end
Error_Compute_pVal=sort(Error_Compute_pVal,'ascend');

lCI_Index=floor((Simulation_Num-(Simulation_Num*CI))/2);
lCI_Index(lCI_Index<1)=1;
uCI_Index=ceil(Simulation_Num-(Simulation_Num-(Simulation_Num*CI))/2);
lCI=Error_Compute_pVal(lCI_Index);
uCI=Error_Compute_pVal(uCI_Index);
end