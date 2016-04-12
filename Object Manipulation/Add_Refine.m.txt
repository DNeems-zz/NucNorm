function []=Add_Refine(varargin)
data=varargin{4};
Mod_ROIs=varargin{5};
handle=data{1};
Mode=varargin{3};
Image=handle.CurrentView;
Channel_Choice=get(handle.ChannelMenu,'value');
Current_mROI=get(handle.MasterROIMenu,'value');
Current_Display=get(handle.DisplayModeMenu,'value');
Current_Overlay=get(handle.OverlayMenu,'value');
[RawImage]=Extract_Data(data,2,Channel_Choice,1);
RawImage=RawImage{:};
Shift=varargin{6};




if islogical(Image)
    Image=max(Image,[],3);
end

switch Mode
    case 1
        if Current_mROI~=1
            mROIs=data{9}{data{10}(1).Channel_Master}{2,9};
            mROI_IndexPull=cell2mat(mROIs(Current_mROI-1,2));
            [mROI_RowPull]=Find_RowPull(mROIs(:,2),mROI_IndexPull);
            W=mROIs{mROI_RowPull,4}(1); H=mROIs{mROI_RowPull,4}(2); D=mROIs{mROI_RowPull,4}(3);
            Y=mROIs{mROI_RowPull,3}(2);X=mROIs{mROI_RowPull,3}(1); Z=mROIs{mROI_RowPull,3}(3);
            [RawImage,BB(1),BB(2),BB(3)]=Crop_Image(RawImage,X,Y,Z,H,W,D,0);
            
        end
        Polygon=roipoly(Image);
        BB=regionprops(Polygon,'boundingbox');
        BB=floor(BB.BoundingBox);
        data{1}.ImagePlace_Handle=get(handle.IMAxes,'children');
        ModImage=RawImage(BB(2):BB(2)+BB(4),BB(1):BB(1)+BB(3),:);
        BB(3)=1;
        BB(4:end)=[];
        BB=[BB,Shift];
        rmROI=cell(1,2);
    case 2
        Refine_Index=ID_Click_Obj(Mod_ROIs{2},handle.IMAxes,Shift);
        [W,H,D]=size(Mod_ROIs{2}{Refine_Index,1});
        Y=Mod_ROIs{3}(Refine_Index,2);X=Mod_ROIs{3}(Refine_Index,1); Z=Mod_ROIs{3}(Refine_Index,3);
        [ModImage,BB(1),BB(2),BB(3)]=Crop_Image(RawImage,X,Y,Z,H,W,D,1);
        BB=[(BB-(Shift-[1,1,1])),Shift];
        rmROI=cell(1,3);
        
        FSS_Data=Extract_Data(data,5:7,Channel_Choice,Current_Display);
        rmROI{1,1}=FSS_Data{1}(Refine_Index,:);
        rmROI{1,2}=FSS_Data{2}(Refine_Index,:);
        rmROI{1,3}=FSS_Data{3}(Refine_Index,:);
        [data]=Remove_Data(data,5:7,Channel_Choice,Current_Display,Refine_Index);
        rmROI=[{rmROI},1];

end
guidata(data{1}.fh,data)
Original_DataStruc=guidata(data{1}.fh);

data=ResetGUI(data{1});
data{2}{1,1}=ModImage;
data{3}{1,1}=max(ModImage,[],3);
data{4}{1,1}='Raw Image';
data{8}{1,1}=[{'Raw Image'},{'Raw Image'}];
data{10}=Original_DataStruc{10}(Channel_Choice);
data{10}.Channel_Master=0;
data{10}.Other=[Channel_Choice,Current_mROI,Current_Display,Current_Overlay,BB-1];
guidata(data{1}.fh,data)
LoadImage(data{1}.fh,[],4)
data=guidata(data{1}.fh);
Sub_H=data{1};
set(Sub_H.FileMenu,'enable','off')
set(Sub_H.AnaMenu,'enable','off')
set(Sub_H.MMenu.Set,'enable','off')
set(Sub_H.MasterSet,'enable','off')
set(Sub_H.ChannelMenu,'enable','off')
set(Sub_H.MasterROIMenu,'enable','off')
set(Sub_H.ApplySelection,'callback',{@Apply_Threshold,2,[{Sub_H.fh},{Original_DataStruc},{rmROI}]})

end