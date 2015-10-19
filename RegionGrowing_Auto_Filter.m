function  [ROI]=RegionGrowing_Auto_Filter(Image,sHandles)   
ROI=cell(size(Image,1),1);

CheckNum=str2double(get(sHandles.Search_Num,'string'));
for i=1:size(Image,1)
    display(sprintf('Finding Regions: ROI %d/%d',i,size(Image,1)));
    Temp_IM=Image{i,1};
    Temp_Mask=Image{i,4};
    Sub_Image=Temp_IM-(uint8(~Temp_Mask)*255);
    NucSize=sum(sum(sum(Temp_Mask~=0)));
    %Basic Otso
  IM_NoZero=(Sub_Image(Sub_Image~=0));
    Image_Mode=mode(IM_NoZero);
    [X,Y,Z]=ind2sub(size(Sub_Image),find(Sub_Image==Image_Mode));
    Seeds=[X,Y,Z];
    rSeed=Seeds(randsample(1:(size(Seeds,1)),CheckNum,0),:);
 
 Ratio=Region_Growing_Ratio(IM_NoZero,Temp_IM);
    Group_Mask=cell(1,CheckNum);
    for k=1:CheckNum
        display(sprintf('Iterative Search Pass %d of %d',k,CheckNum));
        dIM=im2double(Temp_IM);
        dIM(dIM==0)=nan;
        J = regiongrowing(dIM,Seeds(rSeed(k),1),Seeds(rSeed(k),2),Seeds(rSeed(k),3),Ratio,NucSize);
        dIM(~isnan(dIM))=1;
        dIM(isnan(dIM))=0;
        subJ=~logical(double(~logical(dIM))+J);
        Group_Mask{1,k}=subJ;
        
    end
    ImagePool=cell(size(Group_Mask{1},3),1);
    for p=1:size(Group_Mask{1},3)
        for j=1:CheckNum
            ImagePool{p,1}(:,:,j)=Group_Mask{1,j}(:,:,p);
        end
    end
    CompImage_M= false(size(Temp_IM));
    for p=1:size(Group_Mask{1},3)
        TI=sum(ImagePool{p},3);
        TI(TI<CheckNum)=0;
        CompImage_M(:,:,p)=logical(TI);
    end
        Binary_Image=BasicImage_Filter(CompImage_M,sHandles);
    ROI{i,1}=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
    for k=1:numel(ROI{i,1})
        ROI{i,1}(k).RegionNum=Image{i,2};
    end
end
end