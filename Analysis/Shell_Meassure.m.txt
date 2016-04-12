function H=Shell_Meassure(varargin)

if numel(varargin)==2
[Region_Objs,H]=Region_PreProcesses(varargin{[1,2]});

else
    
    
[H]=Analysis_setParameters(varargin{4},1:2);
[Region_Objs,H]=Region_PreProcesses(varargin{3},H);
keyboard
close(H.fh)
end

Save_Dir=H.SaveDir;
Relative_Shell=[{'Perimeter'},{'Centroid'}];
DS_Return=cell(3,2);
Cali=Region_Objs{1,1}.Calibration;
[X,Y,Z]=meshgrid(0:Cali(1):(2*Cali(1)),0:Cali(2):(2*Cali(2)),0:Cali(3):(2*Cali(3)));
H.Cutoff=mean(pdist2([0,0,0],[X(:),Y(:),Z(:)]));
H.Generic_Header=[{' '},{'All: Weighted Average Shell'},...
    {'Outside'},{'Edge'},repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'},...
    {'uCI: Weighted Average Shell'},{'Outside'},{'Edge'},...
    repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'},...
    {'lCI: Weighted Average Shell'},{'Outside'},{'Edge'},...
    repmat({'>>>>>>'},1,H.Num_Shell-2),{'Center'}];
     FuncName=str2func('Measure_Shells');


for Ana_Type=1:numel(H.Use_Method)
    if H.Use_Method(Ana_Type)==1
        H.Shell_Type=Relative_Shell{Ana_Type};
        Shells=calc_Shells(Region_Objs,H);

        for R=1:size(Region_Objs,1)
            H.FuncName=FuncName;
            
            for j=1:numel(H.Ref_Channel)
                H.Ref_ID{R,j}=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ref_Channel(j));
                H.Ref_Set{R,j}=Shells(R,1);
                
            end
            for i=1:numel(H.Ana_Channels)
                H.Ana_ID{R,i}=Region_Objs{R,1}.Channel_Name(Region_Objs{R,1}.Channel_Num==H.Ana_Channels(i));
            end
        end
        
        DS_Return{1,Ana_Type}=Analyzie(Region_Objs,H,nan(size(Region_Objs,1),1));
        DS_Return(2,Ana_Type)=strcat(H.Method_Names(Ana_Type),':',{' '},num2str(H.Num_Shell));
        DS_Return{3,Ana_Type}=nan;
      
        Result_toCSV(DS_Return(:,Ana_Type),Save_Dir);
      
      
    end
end


end

function Shell_Points=calc_Shells(Region_Objs,H)
Shell_Points=cell(size(Region_Objs,1),1);
for R=1:size(Region_Objs,1)
    display(sprintf('Calculating Shells from ROI %d/%d',R,size(Region_Objs,1)));
    Ref_Set=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),H.Shell_Type,'Microns');
    Pixel_byShell=cell(size(Ref_Set,1),1);
    Ref_Set_whole=Region_Objs{R,1}.getPixel_List(Region_Objs{R,1}.Channel_Num(ismember(Region_Objs{R,1}.Channel_Num,H.Ref_Channel)),'Whole','Microns');
   
    for i=1:size(Ref_Set,1)
        Dist_From_Perm=nan(size(Ref_Set_whole{i,1},1),1);
        for j=1:size(Ref_Set_whole{i,1},1)
            Dist_From_Perm(j,1)=min(min(pdist2(Ref_Set_whole{i,1}(j,:),Ref_Set{i,1})));
        end
        [Dist_From_Perm,Index_From_Perm]=sort(Dist_From_Perm,'ascend');
      Pixel_byShell{i,1}=[{Dist_From_Perm},{Ref_Set_whole{i,1}(Index_From_Perm,:)}];
    end
   Shell_Points{R,1}=Pixel_byShell;
end
end
