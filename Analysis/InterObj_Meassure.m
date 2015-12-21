function H=InterObj_Meassure(varargin)

if numel(varargin)==2
[Region_Objs,H]=Region_PreProcesses(varargin{[1,2]});
else
[H]=Analysis_setParameters(varargin{4},1:6);
[Region_Objs,H]=Region_PreProcesses(varargin{3},H);
close(H.fh)

end

DS_Return=cell(3,6);
Pixel_Set=[{'Perimeter'},{'Centroid'},{'Whole'},{'Perimeter'},{'Centroid'},{'Perimeter'},{'Centroid'}];
Comp_Mode=[{'min'},{'min'},{'min'},{'mean'},{'mean'},{'max'},{'max'}];

Save_Dir=H.SaveDir;

FuncName=str2func('Measure_Distance');
H.Generic_Header=[{' '},{'Abs Distance'},...
    {'NN_pVal'},{'NN_pVal_uCI'},{'NN_pVal_lCI'},...
    {'W_pVal'},{'W_pVal_uCI'},{'W_pVal_lCI'},...
    {'cHull_pVal'},{'cHull_pVal_uCI'},{'cHull_pVal_lCI'}];


for Ana_Type=1:numel(H.Use_Method)
    if H.Use_Method(Ana_Type)==1
        for R=1:size(Region_Objs,1)
            H.Pixel_Set=Pixel_Set{Ana_Type};
            H.FuncName=FuncName;
            H.Comp_Mode=str2func(Comp_Mode{Ana_Type});
            for j=1:numel(H.Ref_Channel)
                H.Ref_ID{R,j}=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ref_Channel(j));
                H.Ref_Set{R,j}=Region_Objs{R,1}.getPixel_List(H.Ref_Channel(j),H.Pixel_Set,'Microns');
                %Removes _ in names as they have a special meaning later in
                % data manipulation and name creation
                if ~cellfun(@isempty,strfind(H.Ref_ID{R,j},'_'))
                    H.Ref_ID{R,j}{1}(cell2mat(strfind(H.Ref_ID{R,j},'_')))=[];
                end
            end
            for i=1:numel(H.Ana_Channels)
                H.Ana_ID{R,i}=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ana_Channels(i));
                %Removes _ in names as they have a special meaning later in
                % data manipulation and name creation
              
                if ~cellfun(@isempty,strfind(H.Ana_ID{R,i},'_'))
                    H.Ana_ID{R,i}{1}(cell2mat(strfind(H.Ana_ID{R,i},'_')))=[];
                end
            end
        end
        Norm_Vals=measure_SimDist(Region_Objs,H);
        
        DS_Return{1,Ana_Type}=Analyzie(Region_Objs,H,Norm_Vals);
        DS_Return{2,Ana_Type}=H.Method_Names{Ana_Type};
        DS_Return{3,Ana_Type}=Comp_Mode{Ana_Type};
        
        Result_toCSV(DS_Return(:,Ana_Type),Save_Dir);
        
    end
end


display('done')


end

function Norm_Vals=measure_SimDist(Region_Objs,H)
Names=[{'NN_Sim'}, {'W_Sim'},{'cHull_Sim'}];
Norm_Vals=cell(size(Region_Objs,1),3);

if sum(H.Sim_Usage)~=0
    switch H.NormType
        case 1
            for R=1:size(Region_Objs,1)
                display(sprintf('Calculating Normlized Distances from ROI %d/%d',R,size(Region_Objs,1)));
                for i=1:3;
                    if H.Sim_Usage(i)==1
                        Ref_Set=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),H.Pixel_Set,'Microns');
                        Sim_Points=Region_Objs{R,1}.(Names{i}){1,1};
                        for k=1:size(Ref_Set,1)
                            for j=1:size(Sim_Points,1)
                                All_Dist=pdist2(Sim_Points(j,:),Ref_Set{k,1});
                                All_Dist=All_Dist(:);
                                Norm_Vals{R,i}{k,1}(j,1)=H.Comp_Mode(All_Dist);
                            end
                        end
                    end
                end
            end
        case 2
            for R=1:size(Region_Objs,1)
                display(sprintf('Calculating Normlized Distances from ROI %d/%d',R,size(Region_Objs,1)));
                Num_Ref_Objs=0;
                for i=1:numel(H.Ref_Channel)
                    if size(Region_Objs{R,1}.Binary{ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel(i))},1)>Num_Ref_Objs
                        Num_Ref_Objs=size(Region_Objs{R,1}.Binary{ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel(i))},1);
                    end
                end
                for i=1:3;
                    if H.Sim_Usage(i)==1
                        Sim_Points=Region_Objs{R,1}.(Names{i}){1,1};
                            All_Dist=pdist2(Sim_Points,Sim_Points);
                            All_Dist=All_Dist(:);
                            Norm_Vals{R,i}=All_Dist(randsample(1:size(Sim_Points,1),size(Sim_Points,1),0));
                            
                         Norm_Vals{R,i}=repmat( Norm_Vals(R,i),Num_Ref_Objs,1);
                    end
                end
            end
    end
end
end