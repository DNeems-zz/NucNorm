
function H=Geometric_Meassure(varargin)

if numel(varargin)==2
[Region_Objs,H]=Region_PreProcesses(varargin{[1,2]});
else
[H]=Analysis_setParameters(varargin{4},1:6);
[Region_Objs,H]=Region_PreProcesses(varargin{3},H);
H.useCentroid=1;
keyboard
close(H.fh)

end
Norm_Vals=ones(numel(Region_Objs),1);
DS_Return=cell(2,1);

Save_Dir=H.SaveDir;

FuncName=str2func('Object_Props');
H.Generic_Header=[{' '},{'Number Voxels'},...
    {'Convex Hull Vol'},{'Voxel Volume'},{'Surface Area'},{'Surf Area/Voxel Vol'},{'Surf Area/Convex Vol'}];

H.Ref_Channel=[H.Ref_Channel,H.Ana_Channels];
H.Ana_Channels=1;
if sum(H.Use_Method)>0
    for R=1:size(Region_Objs,1)
        H.Pixel_Set=NaN;
        H.FuncName=FuncName;
        H.Comp_Mode=NaN;
        H.Ana_Type=H.Use_Method;
        H.Ana_ID{R,1}=NaN;
        for i=1:numel(H.Ref_Channel)
            H.Ref_ID{R,i}=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ref_Channel(i));
            %Removes _ in names as they have a special meaning later in
            % data manipulation and name creation
            
            if ~cellfun(@isempty,strfind(H.Ref_ID{R,i},'_'))
                H.Ref_ID{R,i}{1}(cell2mat(strfind(H.Ref_ID{R,i},'_')))=[];
            end
            H.Ref_Set{R,i}=Region_Objs{R,1}.getPixel_List(H.Ref_Channel(i),'Whole','Microns');
        end
    end
    DS_Return{1,1}=Analyzie(Region_Objs,H,Norm_Vals);
    DS_Return{2,1}='Shape: Descriptions';
    for i=1:numel(DS_Return{1,1})
        DS_Return{1}{i}.Properties.Description = 'Shape Des';
    end
    Result_toCSV(DS_Return(:,1),Save_Dir);
    
    
end


display('done')


end
