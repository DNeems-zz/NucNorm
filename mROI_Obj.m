classdef mROI_Obj < handle
    properties (GetAccess = 'public', SetAccess = 'public')
        MetaData
        Binary
        Intensity
        MChan
        NumChan
        Calibration
        mROI_Size
        NN_Sim
        LI_Sim
        cHull_Sim
        mROI_Name
        Channel_Name

    end
    properties (GetAccess = 'public', SetAccess = 'private', Hidden = true)
        mROI_Code  %Number of the region within the stored data strucutres.  Can be non-seqequential and non linear
        FrameShift
        whole_Intensity
        whole_Binary
        mROI_FS
        Channel_Num
    end
    methods %Class Constructor
        function obj=mROI_Obj(data,mROI_Number)
            %mROI_Number: Row number of the region as see on the GUI
            %(Always linear and sequential.
            obj.MetaData=data{10};
            obj.MChan=obj.MetaData(1).Channel_Master;
            obj.Calibration=[obj.MetaData(1).CaliMetaData.XCal,...
                obj.MetaData(1).CaliMetaData.YCal,...
                obj.MetaData(1).CaliMetaData.ZCal];
            
            RegionDef=data{9}{obj.MChan}{2,9}(mROI_Number,:);
            obj.mROI_Code=RegionDef{2};
            obj.mROI_Size=RegionDef{4}+[1,1,1];
            obj.mROI_FS=RegionDef{3};
            
            for i=1:numel(data{9})
                if size(data{9}{i},1)==2
                    [RowPull]=Find_RowPull(data{9}{i}{2,6}(:,3),obj.mROI_Code);
                    obj.Intensity{1,i}=data{9}{i}{2,5}(RowPull,:);
                    obj.Binary{1,i}=data{9}{i}{2,6}(RowPull,:);
                    
                    for j=1:numel(RowPull);
                        iFS=data{9}{i}{2,7}(RowPull(j),:);
                        tFS=iFS-obj.mROI_FS+[1,1,1];
                        tFS(tFS<1)=1;
                        obj.FrameShift{1,i}(j,1:3)=tFS;
                    end
                    obj.whole_Intensity{1,i}=data{9}{i}{1,2};
                    obj.whole_Binary{1,i}=data{9}{i}{2,2};
                else
                    obj.Intensity{1,i}=nan;
                    obj.Binary{1,i}=nan;
                    obj.FrameShift{1,i}=nan;
                    obj.whole_Intensity{1,i}=nan;
                    obj.whole_Binary{1,i}=nan;
                    obj.FrameShift{1,i}=nan;
                    
                end
            end
            obj.mROI_FS(obj.mROI_FS<=0)=1;
            
            Del_Index=isnan(arrayfun(@(x) sum(sum(x{1})),obj.FrameShift));
            obj.Intensity(Del_Index)=[];
            obj.Binary(Del_Index)=[];
            obj.FrameShift(Del_Index)=[];
            obj.whole_Intensity(Del_Index)=[];
            obj.whole_Binary(Del_Index)=[];
            obj.FrameShift(Del_Index)=[];
            obj.NumChan=sum(~Del_Index);
            obj.Channel_Num=1:numel(data{9});
            Channel_ID=cell(1,numel(data{9}));
            for i=1:numel(data{9})
                  Channel_ID{1,i}=data{10}(i).Channel_ID;
            end
            obj.Channel_Name=Channel_ID(~Del_Index);
            obj.Channel_Num=obj.Channel_Num(~Del_Index);
            
            Names=[{'NN_Sim'},...
                {'LI_Sim'},...
                {'cHull_Sim'}];
            for i=1:3
                try
                    obj.(Names{i})=data{9}{obj.MChan}{2,9}(mROI_Number,4+i);
                catch
                    obj.(Names{i})=false;
                end
            end
            obj.mROI_Name=sprintf('%s %s:mROI %d:',data{10}(1).Image_ID,data{10}(1).Image_Number,mROI_Number);
            
        end
    end
    methods %Data Extraction Functions
        function Perimeter_Image=getPerm_Image(obj,Chan,Type)
            %Type:  'ByObj', Return Each Object as its own Perimeter Image
            %Type:  'Whole', Make a whole image and return a single perimter
            %                images containing as all objects
            switch Type
                case 'ByObj'
                    Binnary_Images=obj.Binary{obj.Channel_Num==Chan}(:,1);
                    Perimeter_Image=cell(size(Binnary_Images,1),1);
                    for i=1:size(Binnary_Images,1)
                        Perimeter_Image{i,1}=obj.makePerm_Image(Binnary_Images{i,1});
                    end
                case 'Whole'
                    Images =obj.getPerm_Image(Chan,'ByObj');
                    FS=obj.FrameShift{obj.Channel_Num==Chan};
                    Perimeter_Image=obj.makemROI_Image(Images,FS);
                otherwise
                    error('Invalid Type:  See Docs')
            end
            
        end
        function mROI_Image=getmROI_Image(obj,Chan,Type,varargin)
            %Type:  'Intensity', Returns a Intensity Based Image of the
            %                    entire region
            %Type:  'Binary', Returns a Binary Based Image of the entire Region
            %Type:  'Label', Returns a Binary Image with on the object
            %        number specfified in varargin(1) drawn in
            switch Type
                case 'Intensity'
                    Int_Images=obj.whole_Intensity(obj.Channel_Num==Chan);
                    FS=obj.mROI_FS;
                    mROI_Image=makemROI_Image(obj,Int_Images,FS);
                case 'Binary'
                    Int_Images=obj.Binary{obj.Channel_Num==Chan}(:,1);
                    FS=obj.FrameShift{obj.Channel_Num==Chan};
                    mROI_Image=makemROI_Image(obj,Int_Images,FS);
                case 'Label'
                    Int_Images=obj.Binary{obj.Channel_Num==Chan}(:,1);
                    Obj_Num=varargin{1};
                    Int_Images=Int_Images(Obj_Num);
                    FS=obj.FrameShift{obj.Channel_Num==Chan};
                    FS=FS(Obj_Num,:);
                    mROI_Image=makemROI_Image(obj,Int_Images,FS);
                otherwise
                    error('Invalid Type:  See Docs')
            end
            
        end
        function PixelList=getPixel_List(obj,Chan,Type,Units)
            %Units:  'Micron', Returns Coordinants in Microns
            %Units:  'Voxel', Returns Coordinants in Voxels
            %Type:  'Perimeter', Return Perimeter Pixels
            %Type:  'Whole', Returns all Pixels
            %Type:  'Centroid', Returns Intensity Weighted Centroid Pixel
            switch Type
                case 'Perimeter'
                    Images=obj.getPerm_Image(Chan,'ByObj');
                case {'Whole','Centroid'}
                    Images=obj.Binary{obj.Channel_Num==Chan}(:,1);
                    for i=1:size(Images,1)
                        Images{i,1}=obj.makeFilled_Image(Images{i,1});
                    end
                otherwise
                    display('Input Order: Chan,Type,Units')
                    error('Invalid Type:  See Docs')
            end
            FS=obj.FrameShift{obj.Channel_Num==Chan};
            PixelList=cell(size(Images,1),1);
            if strcmp(Type,'Centroid')
                All_Pix=arrayfun(@(x) mean(x{1},1),obj.getPixel_List(Chan,'Whole','Voxel'),'uniformoutput',0);
                All_Pix=vertcat(All_Pix{:});
                for i=1:size(All_Pix,1)
                    PL(i,1) = regionprops(obj.getmROI_Image(Chan,'Label',i), obj.getmROI_Image(Chan,'Intensity'), {'Centroid','WeightedCentroid','pixellist'});
                    
                end
                for i=1:numel(PL)
                    [~,I]=min(pdist2(PL(i).WeightedCentroid,All_Pix));
                    PL(I).PixelList=PL(i).WeightedCentroid;
                end
                if size(PL,1)~=size(vertcat(PL.PixelList),1)
                    error('Inproper Centroid Assignment')
                end
                
            else
                PL=struct('PixelList',[]);
                repmat(PL,size(Images,1),1);
                for i=1:size(Images,1)
                    PL(i,1)=regionprops(Images{i,1},'pixellist');
                    if size(PL(i,1).PixelList,2)~=size(FS,2)
                        PL(i,1).PixelList=[PL(i,1).PixelList,ones(size(PL(i,1).PixelList,1),1)];
                    end
                    PL(i).PixelList=PL(i).PixelList+repmat(FS(i,:),size(PL(i).PixelList,1),1);
                end
                
            end
            for i=1:numel(PL)
                tPL=PL(i).PixelList;
                switch Units
                    case 'Microns'
                        PixelList{i,1}=tPL.*repmat(obj.Calibration,size(tPL,1),1);
                    case 'Voxel'
                        PixelList{i,1}=tPL;
                    otherwise
                        error('Invalid Units:  See Docs')
                end
            end
            
            
        end
        function obj=Make_2D(obj)
            for i=1:obj.NumChan
                for j=1:size(obj.Binary{obj.Channel_Num(i)},1)
                    obj.Binary{obj.Channel_Num(i)}{j,1}=max(obj.Binary{obj.Channel_Num(i)}{j,1},[],3);
                    obj.Intensity{obj.Channel_Num(i)}{j,1}=max(obj.Intensity{obj.Channel_Num(i)}{j,1},[],3);
                    obj.Binary{obj.Channel_Num(i)}{j,4}(:,3)=0;
                    obj.FrameShift{obj.Channel_Num(i)}(:,3)=0;
                end
                obj.whole_Intensity{1,i}=max(obj.whole_Intensity{1,i},[],3);
                obj.whole_Binary{1,i}=max(obj.whole_Binary{1,i},[],3);
                
            end
            obj.mROI_FS(3)=0;
            obj.mROI_Size(3)=1;
            obj.Calibration(3)=1;
            Names=[{'NN_Sim'},...
                {'LI_Sim'},...
                {'cHull_Sim'}];

            for i=1:3
                if  obj.(Names{i})==0;
                else
                    obj.(Names{i}){1,1}=[unique(obj.(Names{i}){1,1}(:,1:2),'rows'),ones(size(unique(obj.(Names{i}){1,1}(:,1:2),'rows'),1),1)];
                end
            end
            
            
        end
        function obj=rmChan(obj,Chan)
            obj.Binary=obj.Binary(~ismember(obj.Channel_Num,Chan));
            obj.Intensity=obj.Intensity(~ismember(obj.Channel_Num,Chan));
            obj.FrameShift=obj.FrameShift(~ismember(obj.Channel_Num,Chan));
            obj.Channel_Name=obj.Channel_Name(~ismember(obj.Channel_Num,Chan));
            obj.whole_Intensity=obj.whole_Intensity(~ismember(obj.Channel_Num,Chan));
            obj.whole_Binary=obj.whole_Binary(~ismember(obj.Channel_Num,Chan));
            obj.Channel_Num=obj.Channel_Num(~ismember(obj.Channel_Num,Chan));
            obj.NumChan=obj.NumChan-1;
        end
        function [Group_Cluster_Ids,Cluster_Centroids]=findClusters(obj,Seed_Number,Cluster_Chans,Type)
            %Type:  'kMeans', performs kMeans Clustering
            %Type:  'crossSignal', Finds clusters but requires each cluster
            %        to contain at least one value from each channel
            %Group_Cluster_Ids:  Rows: Are the clusters themselves
            %                    Columns: Are the index of the centroids
            %                    from that channel beloning to a given
            %                    cluster
            %Exampled of Group_Cluster_Ids:
            %  [1,3] [1] [2]
            %   [2]  [2] [1]
            %Cluster #1 is composed of the 1st and 3rd Centroid from
            %channel #1 the first centroid from channel #2 and the second
            %centroid from channel # 3
            

Cluster_Chans=obj.Channel_Num(ismember(obj.Channel_Num,Cluster_Chans));
          
            Centroids=cell(numel(Cluster_Chans),1);
            Num_Signals=cell(1,numel(Cluster_Chans));
            for i=1:numel(Cluster_Chans)
                tCent=obj.getPixel_List(Cluster_Chans(i),'Centroid','Microns');
                Centroids{i,1}=vertcat(tCent{:});
                Num_Signals{1,i}=1:size(Centroids{i,1},1);
            end
            
            switch Type
                case 'crossSignal'
                    Possible_Group_IDs=allcomb(Num_Signals{:});
                    Possible_Seed_Pairs=nchoosek(1:size(Possible_Group_IDs,1),Seed_Number);
                    Invalid_Pairs=false(size(Possible_Seed_Pairs,1),1);
                    for i=1:size(Possible_Seed_Pairs,1)
                        Internal_Combinations=nchoosek(1:numel(Possible_Seed_Pairs(i,:)),2);
                        for j=1:size(Internal_Combinations,1)
                            C1=Possible_Group_IDs(Possible_Seed_Pairs(i,Internal_Combinations(j,1)),:);
                            C2=Possible_Group_IDs(Possible_Seed_Pairs(i,Internal_Combinations(j,2)),:);
                            if sum(C1==C2)~=0
                                Invalid_Pairs(i,1)=true;
                                break
                            end
                        end
                        
                    end
                    if sum(~Invalid_Pairs)==0
                        error('No Valid Pairs Could be made: Consider kMeans')
                    end
                    Valid_Pairings=Possible_Seed_Pairs(~Invalid_Pairs,:);
                    Avrg_Cluster_Dist=nan(size(Valid_Pairings,1),Seed_Number);

                    for i=1:size(Valid_Pairings,1)
                        Item_Pos_Index=Possible_Group_IDs(Valid_Pairings(i,:),:);
                        for j=1:size(Item_Pos_Index,1)
                            Temp_Centroid=nan(Seed_Number,size(Centroids{1},2));
                            for k=1:numel(Item_Pos_Index(j,:))
                                Temp_Centroid(k,:)=Centroids{k}(Item_Pos_Index(j,k),:);
                            end
                            Avrg_Cluster_Dist(i,j)=mean(pdist2(Temp_Centroid,mean(Temp_Centroid,1)));
                        end
                        
                    end
                    [~,Best_Cluster_Index]=min(sum(Avrg_Cluster_Dist,2));
                    Best_Groups=Possible_Group_IDs(Valid_Pairings(Best_Cluster_Index,:),:);
                    Cluster_Centroids=nan(Seed_Number,size(Centroids{1},2));
                    
                    for i=1:Seed_Number
                        Temp_Centroid=nan(Seed_Number,size(Centroids{1},2));
                        for j=1:size(Best_Groups,2)
                            Temp_Centroid(j,:)=Centroids{j}(Best_Groups(i,j),:);
                        end
                        Cluster_Centroids(i,:)=mean(Temp_Centroid,1);
                    end
                    Group_Cluster_Ids=arrayfun(@(x) {x},Best_Groups);
                    for i=1:size(Best_Groups,2)
                        Unassigned_Signal=find(~ismember(1:size(Centroids{i},1),Best_Groups(:,i)));
                        if ~isempty(Unassigned_Signal)
                            for j=1:size(Unassigned_Signal,2)
                                [~,I]=min(pdist2(Centroids{i}(Unassigned_Signal(j),:),Cluster_Centroids));
                                Group_Cluster_Ids{I,i}=[Group_Cluster_Ids{I,i},Unassigned_Signal(j)];
                            end
                        end
                    end
                case 'kMeans'
                    [Cluster_IDs,Cluster_Centroids]=kmeans(vertcat(Centroids{:}),Seed_Number);
                    Chan_IDs=cell(size(Centroids,1),1);
                    Chan_Order=cell(size(Centroids,1),1);

                    for i=1:size(Centroids)
                    Chan_IDs{i,1}=repmat(i,size(Centroids{i},1),1);
                    Chan_Order{i,1}=1:size(Centroids{i},1);
                    end
                    Chan_IDs=vertcat(Chan_IDs{:});
                    Chan_Order=[Chan_Order{:}];

                    Group_Cluster_Ids=cell(Seed_Number,size(Centroids,1));
                    for i=1:numel(Chan_IDs)
                    Group_Cluster_Ids{Cluster_IDs(i),Chan_IDs(i)}=vertcat(Group_Cluster_Ids{Cluster_IDs(i),Chan_IDs(i)},Chan_Order(i));
                    end
                    
            end
            
        end
    
    end
    methods %Helper Functions
        function Image=makePerm_Image(obj,Image)
            Image=obj.makeFilled_Image(Image);
            Image=bwperim(Image);
        end
        function Image=makeFilled_Image(~,Image)
            for i=1:size(Image,3)
                Image(:,:,i)=bwfill(Image(:,:,i),'holes');
            end
            
        end
        function Image=makemROI_Image(obj,Images,FS)
            if isa(Images{1,1},'logical')
                Image=false(obj.mROI_Size*2);
                FS=FS+1;
                
                
                for i=1:size(Images,1)
                    Image(FS(i,2):FS(i,2)+size(Images{i,1},1)-1,...
                        FS(i,1):FS(i,1)+size(Images{i,1},2)-1,...
                        FS(i,3):FS(i,3)+size(Images{i,1},3)-1)= Image(FS(i,2):FS(i,2)+size(Images{i,1},1)-1,...
                        FS(i,1):FS(i,1)+size(Images{i,1},2)-1,...
                        FS(i,3):FS(i,3)+size(Images{i,1},3)-1)+Images{i,1};
                end
                Image=Image(1:obj.mROI_Size(1),1:obj.mROI_Size(2),1:obj.mROI_Size(3));
            else
                Image=Images{1,1}(FS(1,2):FS(1,2)+obj.mROI_Size(1)-1,...
                    FS(1,1):FS(1,1)+obj.mROI_Size(2)-1,...
                    FS(1,3):FS(1,3)+obj.mROI_Size(3)-1) ;
            end
        end
    end
end