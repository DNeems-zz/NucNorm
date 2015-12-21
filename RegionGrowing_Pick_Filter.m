function  [ROI]=RegionGrowing_Pick_Filter(Image,sHandles)   
ROI=cell(size(Image,1),1);

Ratio=str2double(get(sHandles.IntDif,'string'));
if (Ratio<0) || (Ratio>1)
    error('Max Percent Change: Inclusion must be between 0-1')
end

Seeds=cell(size(Image,1),1);
for i=1:size(Image,1)
    display(sprintf('Picking Regions: ROI %d/%d',i,size(Image,1)));
   H.fh=figure;
    H.ax=axes;
    imshow(max(Image{i,1},[],3),'parent',H.ax)
    prompt={'How Many Regions Do you Wish to Define'};
    name='Regions';
    numlines=1;
    defaultanswer={'2'};
    numRegions=inputdlg(prompt,name,numlines,defaultanswer);
    numRegions=str2double(numRegions{1});
    [Y,X]=ginput(numRegions);
    close(H.fh)
    
    X=round(X);
    Y=round(Y);
    Z=nan(numel(X),1);
    for j=1:numel(X)
        [R,C]=find(max(max(max(Image{i,1}(X(j)-4:X(j)+4,Y(j)-4:Y(j)+4,:),[],3)))==max(Image{i,1}(X(j)-4:X(j)+4,Y(j)-4:Y(j)+4,:),[],3));
        X(j)=X(j)+R(1)-5;
        Y(j)=Y(j)+C(1)-5;
        [~,I]=max(Image{i,1}(X(j),Y(j),:));
        Z(j,1)=I;
    end
    Seeds{i,1}=[X,Y,Z];
end

for i=1:size(Image,1)
       display(sprintf('Finding Regions: ROI %d/%d',i,size(Image,1)));
  Temp_IM=Image{i,1};
    Temp_Mask=Image{i,4};
    NucSize=sum(sum(sum(Temp_Mask~=0)));
 
   
    dIM=im2double(Temp_IM);
    dIM(dIM==0)=nan;
    
    Building_IM=(zeros(size(Temp_IM)));
    for j=1:size(Seeds{i,1},1)
    J = regiongrowing(dIM,Seeds{i,1}(j,1),Seeds{i,1}(j,2),Seeds{i,1}(j,3),Ratio,NucSize);
    Building_IM=Building_IM+J;
    end
           Binary_Image=BasicImage_Filter(Building_IM,sHandles);
    ROI{i,1}=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
    for k=1:numel(ROI{i,1})
        ROI{i,1}(k).RegionNum=Image{i,2};
    end
end
end
