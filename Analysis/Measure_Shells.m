function [allTable,summaryTable]=Measure_Shells(varargin)

[Query_PL,Shell_PL,Region_Objs,H]=varargin{[1,2,3,5]};
Ana_ID=Query_PL{2};
Query_PL=Query_PL{1};
Ref_ID=Shell_PL{2};
Ref_PL=[Shell_PL{1}{:}];
Obj_Region_Chan=Region_Objs.mROI_Name;
allTable=cell(size(Query_PL,1),1+((H.Num_Shell+2)*3));
summaryTable=cell(size(Ref_PL,1),3);
z=1;

for k=1:size(Query_PL,1)
        Group_Start=z;
    
    for p=1:size(Ref_PL,1)
        if strcmp(Ref_ID,Ana_ID) && p==k
        else
            allTable{z,1}=sprintf('%s:%s_%d to %s_%d',Obj_Region_Chan,Ref_ID,p,Ana_ID,k);
            
            
            
            Current_Shell=PixelList_toShells(Ref_PL{p,1},H.Num_Shell);
            
            [Mean_Shell_Res_Percent]=Calculate_Residency(H.Num_Shell,Query_PL{k,1},Current_Shell,H.Cutoff);

    

            
            if H.Calc_SimError
                Error_Sim_Num=H.Simulation_Num;
                Error_Estimates=nan(Error_Sim_Num,H.Num_Shell+2);
                for E=1:Error_Sim_Num
                    Rand_Index=randsample(1:size(Ref_PL{p,1}{1,1},1),size(Ref_PL{p,1}{1,1},1),1);
                    Rand_Dist=Ref_PL{p,1}{1,1}(Rand_Index,:);
                    Rand_Pix=Ref_PL{p,1}{1,2}(Rand_Index,:);
                    [Rand_Sort_Dist,Rand_Sort_Index]=sort(Rand_Dist,'ascend');
                    Current_Shell=PixelList_toShells([{Rand_Sort_Dist},{Rand_Pix(Rand_Sort_Index,:)}],H.Num_Shell);
                    [Shell_Res_Percent]=Calculate_Residency(H.Num_Shell,Query_PL{k,1},Current_Shell,H.Cutoff);
                    Error_Estimates(E,:)=Shell_Res_Percent;
                end
                [~,I]=sort(Error_Estimates(:,1));
                Error_Estimates=Error_Estimates(I,:);
                lCI_Index=floor((Error_Sim_Num-(Error_Sim_Num*H.CI))/2);
                lCI_Index(lCI_Index<1)=1;
                uCI_Index=ceil(Error_Sim_Num-(Error_Sim_Num-(Error_Sim_Num*H.CI))/2);
                uCI_Error=Error_Estimates(uCI_Index,:);
                lCI_Error=Error_Estimates(lCI_Index,:);
            else
                uCI_Error=nan(1,H.Num_Shell+2);
                lCI_Error=nan(1,H.Num_Shell+2);
            end
            allTable(z,2:end)=arrayfun(@(x) {x},[Mean_Shell_Res_Percent,uCI_Error,lCI_Error]);
            z=z+1;
        end
    end
    
    Name=sprintf('%s:%s_%d to %s Summary',Obj_Region_Chan,Ana_ID,k,Ref_ID);
    [summaryTable{k,1},summaryTable{k,2},summaryTable{k,3}]=toSignal_Summary(allTable(Group_Start:z-1,2:end),...
        Name,size(allTable,2),H,'Within');
    
    
end
if H.Global_Within==1
    summaryTable=[];
    [summaryTable{1,1},summaryTable{1,2},summaryTable{1,3}]=toSignal_Summary(allTable(:,2:end),...
        Name,size(allTable,2),H,'Within');
end
summaryTable=[{vertcat(summaryTable{:,1})},{vertcat(summaryTable{:,2})},{vertcat(summaryTable{:,3})}];
allTable=allTable(~cellfun(@isempty,allTable(:,1)),:);
end

function [shellPL]=PixelList_toShells(PL,NumShells)
End_Points=floor(size(PL{1,2},1)/NumShells).*[1:NumShells];
Start_Points=[1,End_Points(1:end-1)+1];
shellPL=cell(1,NumShells);
for j=1:NumShells
    shellPL{1,j}=PL{1,2}(Start_Points(1,j):End_Points(1,j),:);
end

end

function [Shell_Res_Percent]=Calculate_Residency(NumShells,Query_PL,Current_Shell,Cutoff)
if numel(unique(Current_Shell{1,1}(:,3)))==1
    nSize=9;
else
    nSize=27;
end

Shell_Res_Count=zeros(1,NumShells+1);
Shell_Res_Percent=zeros(1,NumShells+2);
try
    
for i=1:size(Query_PL,1)
    toHull_Dist=nan(NumShells,1);
    for S=1:NumShells
        nnIndex=knnsearch(Query_PL(i,:),Current_Shell{1,S},nSize);
        toHull_Dist(S,1)=min(min(pdist2(Query_PL(i,:),Current_Shell{1,S}(nnIndex,:))));
    end
    if sum(toHull_Dist<=Cutoff)>0
        [~,I]=min(toHull_Dist);
        Shell_Res_Count(1,I+1)=Shell_Res_Count(1,I+1)+1;
    else
        Shell_Res_Count(1,1)=Shell_Res_Count(1,1)+1;
    end
end
catch
    keyboard
end
     Shell_Res_Percent(1,:)=[sum(Shell_Res_Count(1,:).*[0:NumShells])/sum(Shell_Res_Count(1,:)),...
                    Shell_Res_Count(1,:)./sum(Shell_Res_Count(1,:))];
        
end