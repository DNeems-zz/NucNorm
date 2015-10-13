function [Mod_ROIs]=Delete_ROI(varargin)
data=varargin{4};
Mode=varargin{3};
Mod_ROIs=varargin{5};
handle=data{1};
Shift=varargin{6};
mROI_Choice=get(data{1}.MasterROIMenu,'value');
% Generates the Image from the current view called by the function
Image=Get_Image(handle);


switch Mode
    case 1
        %Point Nearest Click
        Del_Index=ID_Click_Obj(Mod_ROIs{2},handle.IMAxes,Shift);
        dRow=Del_Index;
    case 2
        %mROIs encompossed by click
        coordinates = get(handle.IMAxes,'CurrentPoint');
        coordinates = coordinates(1,1:2);
        aproxCoor=round(coordinates);
        Corners=data{9}{data{10}(1).Channel_Master}{2,9}(:,1);
        if mROI_Choice==1
            Match=false(size(Corners,1),1);
            for i=1:size(Corners,1)
                Match(i,1)=inpolygon(aproxCoor(1),aproxCoor(2),Corners{i,1}(:,1),Corners{i,1}(:,2));
            end
            rmROI=[{cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(Match,2))},get(handle.ChannelMenu,'value')];
            [Del_Index]=Find_RowPull(Mod_ROIs{2}(:,3),rmROI{1});
            dRow=Del_Index;
            
        else
        end
    case {3 , 4}
        %Crop Zone
        [~, ~, ~, xi, yi]=roipoly(max(logical(Image),[],3));
        Centroid=vertcat(Mod_ROIs{2}{:,4});
        Centroid=Centroid-repmat(Shift,size(Centroid,1),1);
        try
            Del_Index=inpolygon(Centroid(:,1),Centroid(:,2),xi,yi);
            if Mode==4
                Del_Index=~Del_Index;
            end
        catch
            Del_Index=false(size(Centroid,1),1);
        end
        dRow=find(Del_Index);
end


if (Mode==1 || Mode==3 || Mode==4) && mROI_Choice==1
    %This is true when a single object is deleted from the image when the entire image is being viewed
    [Mod_ROIs,delta_ROIs,data]=Remove_Outright(Mod_ROIs,dRow,data);
elseif mROI_Choice~=1 && (Mode==1 || Mode==3 || Mode==4)
    Working_Region=data{9}{data{10}(1).Channel_Master}{2,9}{mROI_Choice-1,2};
    [Mod_ROIs,delta_ROIs,data]=Remove_Assosciation(Mod_ROIs,dRow,data,Working_Region);
elseif Mode==2 && mROI_Choice==1
    Working_Region=rmROI{1};
    [Mod_ROIs,delta_ROIs,data]=Remove_Assosciation(Mod_ROIs,dRow,data,Working_Region);
elseif Mode==2
    rmROI=[data{9}{data{10}(1).Channel_Master}{2,9}(mROI_Choice-1,2),get(handle.ChannelMenu,'value')];
    Working_Region=rmROI{1};
    dRow=Find_RowPull(Mod_ROIs{2}(:,3),Working_Region);
    [Mod_ROIs,delta_ROIs,data]=Remove_Assosciation(Mod_ROIs,dRow,data,Working_Region);

    
end


data{1}.ImagePlace_Handle=findobj(get(handle.IMAxes,'children'),'type','image');

Manipulation_PostProcess(Mod_ROIs,delta_ROIs,data,'Modify')


if handle.MasterSet_Toggle==1
    data=guidata(data{1}.fh);
    Inverse_Match=~ismember(cell2mat(data{9}{data{10}(1).Channel_Master}{2,9}(:,2)),cell2mat(data{9}{data{10}(1).Channel_Master}{2,6}(:,3)));
    if ~sum(Inverse_Match)==0
        Empty_ROI=data{9}{data{10}(1).Channel_Master}{2,9}{Inverse_Match,2};
        Mode=2;
        rmROI=[{Empty_ROI},get(handle.ChannelMenu,'value')];
    end
end
if Mode==2
    MasterROI_Removal(data,rmROI)
end

end


function Image=Get_Image(handle)
switch CallBack_Value_String(handle.OverlayMenu)
    case 'None'
        Image=handle.CurrentView;
    case 'Composite'
        Image=get(handle.ImagePlace_Handle,'cData');
        Image=double(Image(:,:,3))-double(Image(:,:,2));
        Image(Image<0)=1;
        Image=logical(Image);
    case 'Color'
        Image=max(get(handle.ImagePlace_Handle,'cData'),[],3);
    case 'Numbered'
                Image=handle.CurrentView;

end
end



