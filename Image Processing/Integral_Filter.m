function [ROI]=Integral_Filter(Image,HistImage,sHandles)
ROI=cell(size(Image,1),1);
UseAll=false;
for i=1:size(Image,1)
    if UseAll
        [ImR,ImC,ImD]=size(HistImage{i,1});
        [HIST,~]=hist(double(reshape(HistImage{i,1},1,ImC*ImR*ImD)),0:1:255);
        Percent_Occupany=HIST./sum(HIST);
        Cummulative_Occupany=zeros(1,255);
        for j=1:255
            Cummulative_Occupany(1,j)=sum(Percent_Occupany(j:end));
        end
        First_Empty_Index=find(Cummulative_Occupany==0,1);
        if isempty(First_Empty_Index)
            First_Empty_Index=255;
        end
        X=Cummulative_Occupany(1:First_Empty_Index);
        LLimit=find(X>=PercentInclude,1,'last')+1;
        
        
    else
        H=IntegralSliderU(Image{i,1},HistImage{i,1});
        waitfor(H.fh,'userdata')
        Res=guidata(H.fh);
        LLimit=find(Res{4}>=(1-(get(Res{1}.Slider,'value')/100)),1,'last')-1;
        PercentInclude=1-(get(Res{1}.Slider,'value')/100);
        UseAll=get(H.All,'value');
        close(H.fh)
    end
    
    Binary_Image=Image{i,1}>= round(LLimit);
    Binary_Image=BasicImage_Filter(Binary_Image,sHandles);
    ROI{i,1}=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
    for k=1:numel(ROI{i,1})
        ROI{i,1}(k).RegionNum=Image{i,2};
    end
end
end