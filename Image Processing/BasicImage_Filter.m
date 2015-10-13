function [Image]=BasicImage_Filter(Image,sHandles)
    
Conectivity_Struct=bwconncomp(Image,str2double(CallBack_Value_String(sHandles.Conc)));
    Pix_per_Obj=cellfun(@length,[Conectivity_Struct.PixelIdxList]);
    % Exclude Objects by Size
    Conectivity_Struct.PixelIdxList=Conectivity_Struct.PixelIdxList(Pix_per_Obj>=str2double(get(sHandles.ExluVal,'string')));
    Conectivity_Struct.NumObjects=numel(Conectivity_Struct.PixelIdxList);
    L = labelmatrix(Conectivity_Struct);
    ROI=regionprops(L,'pixellist','boundingbox','Area','Image','Centroid');
    [totCol,totRow,~]=size(Image);
    tobedeleted=false(1,numel(ROI));
    if get(sHandles.EdgeRadio,'value')==1
        for i=1:numel(ROI)
            Edge12=ismember(1,ROI(i).PixelList(:,1:2));
            Edge3=ismember(totRow,ROI(i).PixelList(:,1));
            Edge4=ismember(totCol,ROI(i).PixelList(:,2));
            if (Edge12+Edge3+Edge4)>0
                tobedeleted(1,i)=true;
            end
            clear Edge12
            clear Edge3
            clear Edge4
        end
        ROI(tobedeleted,:)=[];
    end
    Image=ROI_to_Image(ROI,size(Image));
end