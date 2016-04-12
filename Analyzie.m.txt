
function [DS_Return]=Analyzie(Region_Objs,H,Norm_Vals)

c_allTable=cell(size(Region_Objs,1),1);
c_summaryTable=cell(size(Region_Objs,1),1);

g_allTable=cell(size(Region_Objs,1),1);
g_summaryTable=cell(size(Region_Objs,1),1);

t_allTable=cell(size(Region_Objs,1),1);
t_summaryTable=cell(size(Region_Objs,1),1);

c_wGroup_summaryTable=cell(size(Region_Objs,1),1);
c_wGroup_allTable=cell(size(Region_Objs,1),1);

t_wGroup_summaryTable=cell(size(Region_Objs,1),1);
t_wGroup_allTable=cell(size(Region_Objs,1),1);


for R=1:size(Region_Objs,1)
    display(sprintf('Meassuring ROI %d/%d',R,size(Region_Objs,1)));
   
    for j=1:numel(H.Ref_Channel)
        for i=1:numel(H.Ana_Channels)
            display(sprintf('Channel %d/%d',i,numel(H.Ana_Channels)));
            Ana_ID=H.Ana_ID{R,i};
            Ref_ID=H.Ref_ID{R,j};
            Ref_Set=H.Ref_Set{R,j};
            if H.useCentroid==1 %Calculate for Centroid
                Cents=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Centroid','Microns');

                [c_allTable{R,1}{j,i},c_summaryTable{R,1}{j,i}]=H.FuncName([{Cents},Ana_ID],...
                    [{Ref_Set},Ref_ID],...
                    Region_Objs{R,1},...
                    Norm_Vals(R,:),...
                    H);
            end
            
            if H.useTotal==1%Calculate for Total
                Totals=Region_Objs{R,1}.getPixel_List(H.Ana_Channels(i),'Whole','Microns');
                [t_allTable{R,1}{j,i},t_summaryTable{R,1}{j,i}]=H.FuncName([{Totals},Ana_ID],...
                    [{Ref_Set},Ref_ID],...
                    Region_Objs{R,1},...
                    Norm_Vals(R,:),...
                    H);
            end
            
        end
    end
    if sum(H.Usage.Among)>0 %Calculate for Groups
        
        try
            [Group_Cluster_Ids,Cluster_Centroids]=Region_Objs{R,1}.findClusters(H.Among_ClusterNum,...
                H.Ana_Channels,'crossSignal');
            Cluster_Centroids=mat2cell(Cluster_Centroids,[ones(size(Cluster_Centroids,1),1)],[size(Cluster_Centroids,2)]);
            for j=1:numel(H.Ref_Channel)
                Ref_Set=H.Ref_Set{R,j};
                Ref_ID=H.Ref_ID{R,j};
                [g_allTable{R,1}{j,1},g_summaryTable{R,1}{j,1}]=H.FuncName([{Cluster_Centroids},{'Group'}],[{Ref_Set},Ref_ID],Region_Objs{R,1},Norm_Vals(R,:),H);
            end
                if  H.useCentroid==1==1
                    [c_wGroup_allTable{R,1},c_wGroup_summaryTable{R,1}]=GroupStats(c_allTable{R,:},Group_Cluster_Ids,H);
                c_wGroup_summaryTable{R,1}={c_wGroup_summaryTable{R,1}};
                end
                if  H.useTotal==1
                    [t_wGroup_allTable{R,1},t_wGroup_summaryTable{R,1}]=GroupStats(t_allTable{R,:},Group_Cluster_Ids,H);
                t_wGroup_summaryTable{R,1}={t_wGroup_summaryTable{R,1}};

                end
        catch
        end
    end
    
end

c_Data=toSingle_Table(c_allTable,c_summaryTable,H.Generic_Header,{[{'Centroid'},{[{'Centroid-Signal Min'},{'Centroid-Signal Max'},{'Centroid-Signal Mean'}]}]});
t_Data=toSingle_Table(t_allTable,t_summaryTable,H.Generic_Header,{[{'Total'},{[{'Total-Signal Min'},{'Total-Signal Max'},{'Total-Signal Mean'}]}]});
g_Data=toSingle_Table(g_allTable,g_summaryTable,H.Generic_Header,{[{'Group'},{[{'Group-Signal Min'},{'Group-Signal Max'},{'Group-Signal Mean'}]}]});

c_wg_Data=toSingle_Table(c_wGroup_allTable,c_wGroup_summaryTable,H.Generic_Header,{[{'Group Centroid'},{[{'Within Group-Centroid Min'},{'Within Group-Centroid Max'},{'Within Group-Centroid Mean'}]}]});

t_wg_Data=toSingle_Table(t_wGroup_allTable,t_wGroup_summaryTable,H.Generic_Header,{[{'Group Total'},{[{'Within Group-Total Min'},{'Within Group-Total Max'},{'Within Group-Total Mean'}]}]});

DS_Return=[c_Data,t_Data,g_Data,c_wg_Data,t_wg_Data];

DS_Return=DS_Return(arrayfun(@(x) isa(x{1},'dataset'),DS_Return));
end
