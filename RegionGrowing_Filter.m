function  [ROI]=RegionGrowing_Filter(Image,sHandles)   
ROI=cell(size(Image,1),1);
CheckNum=3;
for i=1:size(Image,1)
    display(sprintf('Finding Regions: ROI %d/%d',i,size(Image,1)));
    Temp_IM=Image{i,1};
    NucSize=sum(sum(sum(Temp_IM~=0)));
    %Basic Otso
    I=graythresh(Temp_IM);
    I=I*255;
    %Intenseity Mode and location of the mode pixels
        IM_NoZero=(Temp_IM(Temp_IM~=0));
    IM_NoZero=double(IM_NoZero(IM_NoZero>I));
    Image_Mode=mode(IM_NoZero);
    [X,Y,Z]=ind2sub(size(Temp_IM),find(Temp_IM==Image_Mode));
    Seeds=[X,Y,Z];
    rSeed=Seeds(randsample(1:(size(Seeds,1)),CheckNum,0),:);

    Sorted_Int=sort(IM_NoZero);
    NumPix=numel(Sorted_Int);
    Range=floor(NumPix/3);
    % Differance in intensisty between the dimest 3rd and birghtest third
    % of the voxel above ostu threshold 
    Section_Mean=abs(mean(Sorted_Int(1:Range))-mean(Sorted_Int(end-Range:end)));
    Correction=(255-Section_Mean)*2; %The two here is an arbitary fudge factor/
    Ratio=Image_Mode/Correction;
    Image_Mean=mean(IM_NoZero);
    Prcnt_Over_Mean=sum(IM_NoZero>Image_Mean)/NumPix;
    Ratio=Ratio+(Prcnt_Over_Mean/15); %The fifteen here is an arbitary fudge factor/
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