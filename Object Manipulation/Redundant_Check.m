function [Indv_Objs,RM_Obj]=Redundant_Check(Indv_Objs,Prcnt_Overlap,data)
MChan=data{10}(1).Channel_Master;
Current_Chan=get(data{1}.ChannelMenu,'value');

    Groups_ROIs=Indv_Objs{2};
    Groups_FS=Indv_Objs{3};

Pixels=cell(size(Groups_ROIs,1),1);

    for i=1:size(Groups_ROIs,1)
        tPL=regionprops(Groups_ROIs{i,1},'pixellist','area');
        [~,I]=max([tPL.Area]);
        tPL=tPL(I);
        if size(tPL.PixelList,2)<3
        tPL.PixelList=[tPL.PixelList,zeros(size(tPL.PixelList,1),1)];
        end
        Pixels{i,1}=tPL.PixelList+repmat(Groups_FS(i,:),size(tPL.PixelList,1),1);
        Pixels{i,2}=repmat(i,size(tPL.PixelList,1),1);

    end
    
    Total_pix=vertcat(Pixels{:,1});
    Total_Index=vertcat(Pixels{:,2});
    [~,uIndex,~]=unique(Total_pix,'rows');
    Non_Unique_Pos=true(size(Total_pix,1),1);
    Non_Unique_Pos(uIndex,:)=0;
    Redundant_Index=unique(Total_Index(Non_Unique_Pos,:));
    uRC=cell(numel(Redundant_Index),1);
    pRC=cell(numel(Redundant_Index),1);
    Redundant_Pos=Total_Index(ismember(Total_pix,Total_pix(Non_Unique_Pos,:),'rows'),:);
    for i=1:numel(Redundant_Index)
        display(sprintf('Checking Obj %d/%d for redundancy',i,numel(Redundant_Index)))
        uRC{i,1}=unique(Total_Index(ismember(Total_pix,Pixels{Redundant_Index(i),1},'rows'),1));
        for j=1:numel(uRC{i,1})
            pRC{i,1}(j,1)=sum(Redundant_Pos==uRC{i,1}(j,1))/sum(Total_Index==uRC{i,1}(j,1));
        end
        
    end
    
    RM_Row=cell(size(uRC,1),1);
    for i=1:size(uRC,1)
        for j=1:numel(uRC{i,1})
            if pRC{i,1}(j,1)>Prcnt_Overlap
                RM_Row{i,1}(j,1)=uRC{i,1}(j,1);
            else
                RM_Row{i,1}(j,1)=nan;
            end
        end
        if sum(~isnan(RM_Row{i,1}))>1
            RM_Row{i,1}=RM_Row{i,1}(~isnan(RM_Row{i,1}));
            [~,I]=max(arrayfun(@(x) numel(x{1,1}),Indv_Objs{2}(RM_Row{i,1},2)));
            rm_Index=true(numel(RM_Row{i,1}),1);
            rm_Index(I,1)=false;
            if data{1}.MasterSet_Toggle==0 || Current_Chan==MChan
                RM_Row{i,1}=RM_Row{i,1}(rm_Index,:);
            else
                %Assosciation_Regions=cell2mat(Indv_Objs{2}(RM_Row{i,1}(rm_Index,:),3));
%                Indv_Objs{2}{RM_Row{i,1}(~rm_Index,:),3}=unique(vertcat(cell2mat(Indv_Objs{2}(RM_Row{i,1}(~rm_Index,:),3)),Assosciation_Regions));
                RM_Row{i,1}=RM_Row{i,1}(rm_Index,:);                
            end
        end
    end
    
    RM_Rows=unique(vertcat(RM_Row{:}));
    RM_Rows=RM_Rows(~isnan(RM_Rows));
    for j=1:numel(RM_Rows)
        for k=1:numel(uRC)
            if sum(ismember(uRC{k},RM_Rows(j)))>0
                Patch_Index=unique(vertcat(Indv_Objs{2}{uRC{k}(ismember(uRC{k},RM_Rows(j))),3}));
                Match_Row=uRC{k}(~ismember(uRC{k},RM_Rows(j)));
                for p=1:numel(Match_Row)
                Indv_Objs{2}{Match_Row(p),3}=vertcat(Indv_Objs{2}{Match_Row(p),3},Patch_Index);
                end
                
            end
        end
    end
    
    for j=1:3
        RM_Obj{j}=Indv_Objs{j}(RM_Rows,:);
        Indv_Objs{j}(RM_Rows,:)=[];
    end
    
end