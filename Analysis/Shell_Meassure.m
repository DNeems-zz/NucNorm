function H=Shell_Meassure(varargin)

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
H.Num_Shell=str2double(get(H.AnaMethod(4),'string'));
Relative_Shell=[{'Perimeter'},{'Centroid'}];

for i=1:2
    if get(H.AnaMethod(i),'value')==1
        H.Shell_Type=Relative_Shell{i};
        H.FuncName=str2func('Measure_Shells');
      Cali=Region_Objs{1,1}.Calibration;
      [X,Y,Z]=meshgrid(0:Cali(1):(2*Cali(1)),0:Cali(2):(2*Cali(2)),0:Cali(3):(2*Cali(3)));
      H.Cutoff=mean(pdist2([0,0,0],[X(:),Y(:),Z(:)]))*1.5;
      DS_Return{1,i}=Feeder(Region_Objs,H);
      DS_Return(2,i)=strcat(get(H.AnaMethod(i),'string'),':',{' '},get(H.AnaMethod(4),'string'));
      DS_Return{3,i}=nan;
      Result_toCSV(DS_Return(:,1),get(H.SavePathString,'string'));
      
      
    end
end
close(H.fh)


end
function [DS_Return]=Feeder(Region_Objs,H)

Shells=calc_Shells(Region_Objs,H);

Generic_Header=[{' '},{'All: Weighted Average Shell'},...
    {'Outside'},{'Edge'},repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'},...
    {'NN: Weighted Average Shell'},{'Outside'},{'Edge'},...
    repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'},...
    {'LI: Weighted Average Shell'},{'Outside'},{'Edge'},...
    repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'},...
    {'cHull: Weighted Average Shell'},{'Outside'},{'Edge'},...
    repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'}];

c_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
c_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
g_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
g_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
t_allTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
t_summaryTable=cell(size(Region_Objs,1),numel(H.Ana_Channels));
c_wGroup_summaryTable=cell(size(Region_Objs,1),1);
t_wGroup_summaryTable=cell(size(Region_Objs,1),1);

for R=1:size(Region_Objs,1)
    display(sprintf('Meassuring Shell Occupancy ROI %d/%d',R,size(Region_Objs,1)));
    for i=1:numel(H.Ana_Channels)
       
        display(sprintf('Channel %d/%d',i,numel(H.Ana_Channels)));
        Ana_ID=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ana_Channels(i));
        Ref_ID=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ref_Channel);
        if get(H.AnProp(3).AnaProp(1),'value')==1 %Calculate for Centroid
            Cents=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Centroid','Microns');
            [c_allTable{R,i},c_summaryTable{R,i}]=H.FuncName([{Cents},Ana_ID],[{Shells(R,:)},Ref_ID],Region_Objs{R,1},H);
        end
        
        if get(H.AnProp(3).AnaProp(2),'value') %Calculate for Total
            Totals=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Whole','Microns');
            [t_allTable{R,i},t_summaryTable{R,i}]=H.FuncName([{Totals},Ana_ID],[{Shells(R,:)},Ref_ID],Region_Objs{R,1},H);
        end
        
        if get(H.GrpProps(1),'value') %Calculate for Groups
            [Group_Cluster_Ids,Cluster_Centroids]=Region_Objs{R,1}.findClusters(str2double(get(H.GrpProps(6),'string')),...
                H.Ana_Channels,'crossSignal');
            Cluster_Centroids=mat2cell(Cluster_Centroids,[ones(size(Cluster_Centroids,1),1)],[size(Cluster_Centroids,2)]);
            [g_allTable{R,i},g_summaryTable{R,i}]=H.FuncName([{Cluster_Centroids},{'Group'}],[{Shells(R,:)},Ref_ID],Region_Objs{R,1},H);
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

c_Data=toSingle_Table(c_allTable,c_summaryTable,Generic_Header,{[{'Centroid'},{[{'Signal Min'},{'Signal Max'},{'Signal Mean'}]}]});
t_Data=toSingle_Table(t_allTable,t_summaryTable,Generic_Header,{[{'Centroid'},{[{'Signal Min'},{'Signal Max'},{'Signal Mean'}]}]});
g_Data=toSingle_Table(g_allTable,g_summaryTable,Generic_Header,{[{'Centroid'},{[{'Signal Min'},{'Signal Max'},{'Signal Mean'}]}]});
c_wg_Data=toSingle_Table(cell(1,1),c_wGroup_summaryTable,Generic_Header,{[{'Centroid'},{[{'Group Min'},{'Group Max'},{'Group Mean'}]}]});
t_wg_Data=toSingle_Table(cell(1,1),t_wGroup_summaryTable,Generic_Header,{[{'Centroid'},{[{'Group Min'},{'Group Max'},{'Group Mean'}]}]});
DS_Return=[[[c_Data{:}],[t_Data{:}],[g_Data{:}],[c_wg_Data{:}],[t_wg_Data{:}]]];
DS_Return=DS_Return(arrayfun(@(x) isa(x{1},'dataset'),DS_Return));
end

function Shell_Points=calc_Shells(Region_Objs,H)
Shell_Points=cell(size(Region_Objs,1),4);
Names=[{'NN_Sim'}, {'LI_Sim'},{'cHull_Sim'}];
for R=1:size(Region_Objs,1)
    display(sprintf('Calculating Shells from ROI %d/%d',R,size(Region_Objs,1)));
    Ref_Set=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),H.Shell_Type,'Microns');
    Pixel_byShell=cell(1,size(Ref_Set,1));
    Ref_Set_whole=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),'Whole','Microns');
   
    for i=1:size(Ref_Set,1)
        Dist_From_Perm=nan(size(Ref_Set_whole{i,1},1),1);
        for j=1:size(Ref_Set_whole{i,1},1)
            Dist_From_Perm(j,1)=min(min(pdist2(Ref_Set_whole{i,1}(j,:),Ref_Set{i,1})));
        end
        [~,Index_From_Perm]=sort(Dist_From_Perm,'ascend');
        End_Points=floor(numel(Index_From_Perm)/H.Num_Shell).*[1:3];
        Start_Points=[1,End_Points(1:end-1)+1];
        Pixel_byShell{i,1}=cell(1,H.Num_Shell);
        for j=1:H.Num_Shell
            Pixel_byShell{i,1}{1,j}=Ref_Set_whole{i,1}(Index_From_Perm(Start_Points(1,j):End_Points(1,j)),:);
        end
    end
    Shell_Points(R,1)=Pixel_byShell;
    for O=1:3
        if get(H.AnProp(2).AnaProp(O),'value')==1
            Ref_Set=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),H.Shell_Type,'Microns');
            Pixel_byShell=cell(1,size(Ref_Set,1));
            Ref_Set_whole=Region_Objs{R,1}.(Names{O});
            for i=1:size(Ref_Set,1)
                Dist_From_Perm=nan(size(Ref_Set_whole{i,1},1),1);
                for j=1:size(Ref_Set_whole{i,1},1)
                    Dist_From_Perm(j,1)=min(min(pdist2(Ref_Set_whole{i,1}(j,:),Ref_Set{i,1})));
                end
                [~,Index_From_Perm]=sort(Dist_From_Perm,'ascend');
                End_Points=floor(numel(Index_From_Perm)/H.Num_Shell).*[1:3];
                Start_Points=[1,End_Points(1:end-1)+1];
                Pixel_byShell{i,1}=cell(1,H.Num_Shell);
                for j=1:H.Num_Shell
                    Pixel_byShell{i,1}{1,j}=Ref_Set_whole{i,1}(Index_From_Perm(Start_Points(1,j):End_Points(1,j)),:);
                end
            end
        
        Shell_Points(R,O+1)=Pixel_byShell;    
    end
    end
end
end
