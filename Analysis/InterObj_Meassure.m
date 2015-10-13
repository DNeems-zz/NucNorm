function H=InterObj_Meassure(varargin)

[Region_Objs,H,Type]=varargin{[3,4,5]};

%Extract Region to Anaylzie from List
if ~strcmp(CallBack_Value_String(H.CProps.MenuAddParm(end)),'All')
Region_Objs=Region_Objs(str2double(CallBack_Value_String(H.CProps.MenuAddParm(end))),:);
end
%Make 2D if nessicary
if get(H.AnProp(1).AnaProp(1),'value')==1
    for i=1:size(Region_Objs,1)
        Region_Objs{i,1}=Region_Objs{i,1}.Make_2D;
    end
end
Ana_Channels=arrayfun(@(x) get(x,'value'),H.CProps.MenuAddParm(2:end-1));
Ana_Channels=Ana_Channels(Ana_Channels~=1)-1;
Ref_Channel=get(H.CProps.MenuAddParm(1),'value');
H.Ref_Channel=Ref_Channel;
H.Ana_Channels=Ana_Channels;
for i=1:size(Region_Objs,1)
    rmChan=Region_Objs{i,1}.Channel_Num(~ismember(Region_Objs{i,1}.Channel_Num,[Ref_Channel,Ana_Channels]));
    for j=1:numel(rmChan)
        Region_Objs{i,1}=Region_Objs{i,1}.rmChan(rmChan(j));
    end
end

DS_Return=cell(3,6);
Pixel_Set=[{'Perimeter'},{'Centroid'},{'Perimeter'},{'Centroid'},{'Perimeter'},{'Centroid'}];
Comp_Mode=[{'min'},{'min'},{'mean'},{'mean'},{'max'},{'max'}];
Save_Dir=pwd;
for i=1:6
    if get(H.AnaMethod(i),'value')==1
            FuncName=str2func('Measure_Distance');
            
            H.Pixel_Set=Pixel_Set{i};
            H.FuncName=FuncName;
            H.Comp_Mode=str2func(Comp_Mode{i});
            H.NormType=Type;
            DS_Return{1,i}=Feeder(Region_Objs,H);        
    DS_Return{2,i}=get(H.AnaMethod(i),'string');
    DS_Return{3,i}=Comp_Mode{i};
    Result_toCSV(DS_Return(:,1),get(H.SavePathString,'string'));
    end
    

end
display('done')
close(H.fh)


end

function [DS_Return]=Feeder(Region_Objs,H)
Distrobution_Distance=measure_SimDist(Region_Objs,H);

Generic_Header=[{' '},{'Abs Distance'},...
    {'NN_pVal'},{'NN_pVal_uCI'},{'NN_pVal_lCI'},...
    {'LI_pVal'},{'LI_pVal_uCI'},{'LI_pVal_lCI'},...
    {'cHull_pVal'},{'cHull_pVal_uCI'},{'cHull_pVal_lCI'}];
c_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
c_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));

g_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
g_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));

t_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
t_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));

c_wGroup_summaryTable=cell(size(Region_Objs,1),1);
t_wGroup_summaryTable=cell(size(Region_Objs,1),1);

for R=1:size(Region_Objs,1)
    display(sprintf('Meassuring ROI %d/%d',R,size(Region_Objs,1)));
    for i=1:numel(H.Ana_Channels)
        display(sprintf('Channel %d/%d',i,numel(H.Ana_Channels)));
        Ana_ID=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ana_Channels(i));
        Ref_ID=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ref_Channel);
        Ref_Set=Region_Objs{R,1}.getPixel_List(H.Ref_Channel,H.Pixel_Set,'Microns');
        if get(H.AnProp(3).AnaProp(1),'value')==1 %Calculate for Centroid
            Cents=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Centroid','Microns');
            [c_allTable{R,i},c_summaryTable{R,i}]=H.FuncName([{Cents},Ana_ID],[{Ref_Set},Ref_ID],Region_Objs{R,1},Distrobution_Distance(R,:),H);
        end

        if get(H.AnProp(3).AnaProp(2),'value') %Calculate for Total
            Totals=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Whole','Microns');
         [t_allTable{R,i},t_summaryTable{R,i}]=H.FuncName([{Totals},Ana_ID],[{Ref_Set},Ref_ID],Region_Objs{R,1},Distrobution_Distance(R,:),H);
        end
        
        if get(H.GrpProps(1),'value') %Calculate for Groups
            [Group_Cluster_Ids,Cluster_Centroids]=Region_Objs{R,1}.findClusters(str2double(get(H.GrpProps(6),'string')),...
                H.Ana_Channels,'crossSignal');
            Cluster_Centroids=mat2cell(Cluster_Centroids,[ones(size(Cluster_Centroids,1),1)],[size(Cluster_Centroids,2)]);
            [g_allTable{R,i},g_summaryTable{R,i}]=H.FuncName([{Cluster_Centroids},{'Group'}],[{Ref_Set},Ref_ID],Region_Objs{R,1},Distrobution_Distance(R,:),H);
        end
    end
    
    if get(H.GrpProps(2),'value')==1
        if get(H.AnProp(3).AnaProp(1),'value')==1
            c_wGroup_summaryTable{R,1}=GroupStats(c_allTable(R,:),Group_Cluster_Ids);
        end
        if get(H.AnProp(3).AnaProp(2),'value')==1
            t_wGroup_summaryTable{R,1}=GroupStats(t_allTable(R,:),Group_Cluster_Ids);
        end
    end
end

c_Data=toSingle_Table(c_allTable,c_summaryTable,Generic_Header,{[{'Centroid'},{[{'Centroid-Signal Min'},{'Centroid-Signal Max'},{'Centroid-Signal Mean'}]}]});
t_Data=toSingle_Table(t_allTable,t_summaryTable,Generic_Header,{[{'Total'},{[{'Total-Signal Min'},{'Total-Signal Max'},{'Total-Signal Mean'}]}]});
g_Data=toSingle_Table(g_allTable,g_summaryTable,Generic_Header,{[{'Group'},{[{'Group-Signal Min'},{'Group-Signal Max'},{'Group-Signal Mean'}]}]});
c_wg_Data=toSingle_Table(cell(1,1),c_wGroup_summaryTable,Generic_Header,{[{'Group Centroid'},{[{'Within Group-Centroid Min'},{'Within Group-Centroid Max'},{'Within Group-Centroid Mean'}]}]});
t_wg_Data=toSingle_Table(cell(1,1),t_wGroup_summaryTable,Generic_Header,{[{'Group Total'},{[{'Within Group-Total Min'},{'Within Group-Total Max'},{'Within Group-Total Mean'}]}]});
DS_Return=[[[c_Data{:}],[t_Data{:}],[g_Data{:}],[c_wg_Data{:}],[t_wg_Data{:}]]];
DS_Return=DS_Return(arrayfun(@(x) isa(x{1},'dataset'),DS_Return));
end

function Distrobution_Distance=measure_SimDist(Region_Objs,H)
Names=[{'NN_Sim'}, {'LI_Sim'},{'cHull_Sim'}];
Distrobution_Distance=cell(size(Region_Objs,1),3);
if sum(cell2mat(get(H.AnProp(2).AnaProp(1:3),'value')))~=0
    switch H.NormType
        case 2
            for R=1:size(Region_Objs,1)
                display(sprintf('Calculating Normlized Distances from ROI %d/%d',R,size(Region_Objs,1)));
                for i=1:3;
                    if get(H.AnProp(2).AnaProp(i),'value')==1
                        Ref_Set=Region_Objs{R,1}.getPixel_List(ismember(H.Ref_Channel,Region_Objs{R,1}.Channel_Num),H.Pixel_Set,'Microns');
                        Sim_Points=Region_Objs{R,1}.(Names{i}){1,1};
                        for k=1:size(Ref_Set,1)
                            for j=1:size(Sim_Points,1)
                                All_Dist=pdist2(Sim_Points(j,:),Ref_Set{k,1});
                                All_Dist=All_Dist(:);
                                Distrobution_Distance{R,i}{k,1}(j,1)=H.Comp_Mode(All_Dist);
                            end
                        end
                    end
                end
            end
        case 3
            for R=1:size(Region_Objs,1)
                display(sprintf('Calculating Normlized Distances from ROI %d/%d',R,size(Region_Objs,1)));
                Num_Ref_Objs=size(Region_Objs{R,1}.Binary{ismember(H.Ref_Channel,Region_Objs{R,1}.Channel_Num)},1);
                for i=1:3;
                    if get(H.AnProp(2).AnaProp(i),'value')==1
                        Sim_Points=Region_Objs{R,1}.(Names{i}){1,1};
                            All_Dist=pdist2(Sim_Points,Sim_Points);
                            All_Dist=All_Dist(:);
                            Distrobution_Distance{R,i}=All_Dist(randsample(1:size(Sim_Points,1),size(Sim_Points,1),0));
                            
                         Distrobution_Distance{R,i}=repmat( Distrobution_Distance(R,i),Num_Ref_Objs,1);
                    end
                end
            end
    end
end
end