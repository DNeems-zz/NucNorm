function [Region_Objs,H]=Region_PreProcesses(Region_Objs,H)

%Extract Region to Anaylzie from List
if ~strcmp(H.Index_forAnalysis,'All')
Region_Objs=Region_Objs(str2double(H.Index_forAnalysis),:);
end
%Make 2D if nessicary
if H.make_TwoD==1
    for i=1:size(Region_Objs,1)
        Region_Objs{i,1}=Region_Objs{i,1}.Make_2D;
    end
end

Ana_Channels=H.Analysis_Channels;
Ana_Channels=Ana_Channels(Ana_Channels~=1)-1;
if strcmp(H.Ref_Menu,'None')
Ref_Channel=Ana_Channels;
Input_Channels=numel(Ref_Channel);

else
Ref_Channel=H.Referance_Channel;
Input_Channels=numel(Ref_Channel)+numel(Ana_Channels);

end   

H.Ref_Channel=Ref_Channel;
H.Ana_Channels=Ana_Channels;
Chanel_Names=Region_Objs{1,1}.Channel_Name(ismember(Region_Objs{1,1}.Channel_Num,H.Ana_Channels));
[~,I]=sort(H.Ana_Channels);
H.Channel_Names=Chanel_Names(I);
All_Channels=[Ref_Channel,Ana_Channels];

for i=1:size(Region_Objs,1)
    rmChan=Region_Objs{i,1}.Channel_Num(~ismember(Region_Objs{i,1}.Channel_Num,[Ref_Channel,Ana_Channels]));
    for j=1:numel(rmChan)
        Region_Objs{i,1}=Region_Objs{i,1}.rmChan(rmChan(j));
    end
    
    if H.is_Pariwise==1
        for j=1:Input_Channels
            if ~isnan(H.Cluster_Numbers(j+1))
                Region_Objs{i,1}=Region_Objs{i,1}.Group_Signals(All_Channels(j+1),...
                    H.Cluster_Numbers(j+1),...
                    [H.Cluster_Under(j+1),H.Cluster_Over(j+1)]);
            end
        end
    else
        
        for j=1:Input_Channels
            if ~isnan(H.Cluster_Numbers(j))
                Region_Objs{i,1}=Region_Objs{i,1}.Group_Signals(All_Channels(j),...
                    H.Cluster_Numbers(j),...
                    [H.Cluster_Under(j),H.Cluster_Over(j)]);
            end
        end
    end
    
end


end