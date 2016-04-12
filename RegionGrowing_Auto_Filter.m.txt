function  [ROI]=RegionGrowing_Auto_Filter(Image,sHandles)   
ROI=cell(size(Image,1),1);

switch sHandles.Init_Callback{4}
    case 1
        [ROI]=Foreground(Image,sHandles);
    case 2
[ROI]=Background(Image,sHandles);
end

end
function [ROI]=Background(Image,sHandles)
CheckNum=str2double(get(sHandles.Search_Num,'string'));

for i=1:size(Image,1)
    display(sprintf('Finding Regions: ROI %d/%d',i,size(Image,1)));
    Temp_IM=Image{i,1};
    Temp_Mask=Image{i,4};
    Sub_Image=Temp_IM-(uint8(~Temp_Mask)*255);
    NucSize=sum(sum(sum(Temp_Mask~=0)));
    %Basic Otso
    IM_NoZero=(Sub_Image(Sub_Image~=0));
    Freq_Table=tabulate(IM_NoZero);
    [~,I]=sort(Freq_Table(:,3),'descend');
    Freq_Table=Freq_Table(I,:);
    Image_Mode=Freq_Table(1,1);
    [X,Y,Z]=ind2sub(size(Sub_Image),find(Sub_Image==Image_Mode));
    Seeds=[X,Y,Z];
    rSeed=Seeds(randsample(1:(size(Seeds,1)),CheckNum,0),:);
    
    Ratio=Region_Growing_Ratio(IM_NoZero,Temp_IM);
    Group_Mask=cell(1,CheckNum);
    
    for k=1:CheckNum
        display(sprintf('Iterative Search Pass %d of %d',k,CheckNum));
        dIM=im2double(Temp_IM);
        dIM(dIM==0)=nan;
        J = regiongrowing(dIM,rSeed(k,1),rSeed(k,2),rSeed(k,3),Ratio,NucSize);
        while Total_Sum(J)<NucSize*.1
            Freq_Table(1,:)=[];
            Image_Mode=Freq_Table(1,1);
            [X,Y,Z]=ind2sub(size(Sub_Image),find(Sub_Image==Image_Mode));
            Seeds=[X,Y,Z];
            rSeed=Seeds(randsample(1:(size(Seeds,1)),CheckNum,0),:);
            dIM=im2double(Temp_IM);
            dIM(dIM==0)=nan;
            J = regiongrowing(dIM,rSeed(k,1),rSeed(k,2),rSeed(k,3),Ratio,NucSize);
            Total_Sum(J)
        end
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
function [ROI]=Foreground(Image,sHandles)

CheckNum=str2double(get(sHandles.Search_Num,'string'));
Objects=str2double(get(sHandles.IntDif,'string'));

for i=1:size(Image,1)
    display(sprintf('Finding Regions: ROI %d/%d',i,size(Image,1)));
    Temp_IM=Image{i,1};
    Temp_Mask=Image{i,4};
    
    Sub_Image=Temp_IM-(uint8(~Temp_Mask)*255);
    NucSize=sum(sum(sum(Temp_Mask~=0)));
    IM_NoZero=(Sub_Image(Sub_Image~=0));
    Freq_Table=tabulate(IM_NoZero);
    [~,I]=sort(Freq_Table(:,1),'descend');
    Freq_Table=Freq_Table(I,:);
    for j=1:size(Freq_Table,1)
    Freq_Table(j,4)=sum(Freq_Table(1:j,3));
    end
    UnChanged_Pos=diff(Freq_Table(:,4))==0;
    Freq_Table(UnChanged_Pos,:)=[];
    Int_Cutoff=Freq_Table(find(diff(smooth(diff(Freq_Table(:,4))))>.05,1,'first')-2,1);
    RP=regionprops(Image{1,4},Image{1,1},'pixellist','pixelvalues');
    Bright_Spots_Coor=RP.PixelList(RP.PixelValues>=Int_Cutoff,:);
    Bright_Spots_Int=RP.PixelValues(RP.PixelValues>=Int_Cutoff,:);
    keyboard
    [Cluster_Index,Cluster_Centroids]=kmeans(Bright_Spots_Coor,Objects);
        Group_Mask=cell(1,CheckNum);
        for j=1:Objects
            Dist_Weight_Int_Val=double(Bright_Spots_Int(Cluster_Index==j,:)')./pdist2(Cluster_Centroids(j,:),Bright_Spots_Coor(Cluster_Index==j,:));
            [~,I]=sort(Dist_Weight_Int_Val,'descend');
            Spots=Bright_Spots_Coor(Cluster_Index==j,:);
            Dist_Weight_Int_Coor=Spots(I,:);
            Seeds=Dist_Weight_Int_Coor(1:floor(size(Dist_Weight_Int_Coor,1)*.01),:);
            rSeed=Seeds(randsample(1:(size(Seeds,1)),CheckNum,0),:);
            Iterative_Image=zeros(size(Temp_IM));
            
            for k=1:CheckNum
                Ratio=Region_Growing_Ratio(IM_NoZero,Temp_IM);
                
                display(sprintf('Iterative Search Pass %d of %d',k,CheckNum));
                dIM=im2double(Temp_IM);
                dIM(dIM==0)=nan;
                J = regiongrowing(dIM,rSeed(k,2),rSeed(k,1),rSeed(k,3),Ratio,NucSize*.55);
                if Total_Sum(J)>=NucSize*.5
                   Ratio=Ratio/10;
                J = regiongrowing(dIM,rSeed(k,2),rSeed(k,1),rSeed(k,3),Ratio,NucSize*.55);

                else
                end
                    J_Previous=Total_Sum(J)*100;
                    Stored_Change=cell(0,2);
                    while Total_Sum(J_Previous)/Total_Sum(J)>.1  && Total_Sum(J)<NucSize*.5
                        J_Previous=J;
                        display(sprintf('Increasing Ratio from %0.3f to %0.3f',Ratio,Ratio-Ratio*.05))
                        Ratio=Ratio+Ratio*.05;
                        J = regiongrowing(dIM,rSeed(k,2),rSeed(k,1),rSeed(k,3),Ratio,NucSize*.5);
                        Stored_Change{end+1,2}=(Total_Sum(J)/Total_Sum(J_Previous));
                        Stored_Change{end,1}=J_Previous;
                    end
                    if Total_Sum(J)>=NucSize*.5 && Total_Sum(J_Previous)/Total_Sum(J)>.1
                        [~,I]=min(cell2mat(Stored_Change(:,2)));
                        Group_Mask{1,j}=Iterative_Image+Stored_Change{I,1};
                        
                    else
                        Group_Mask{1,j}=Iterative_Image+J_Previous;
                    end
            end
            keyboard
        end
        Binary_Image=zeros(size(Temp_IM));
        for j=1:Objects
            Binary_Image=Binary_Image+Group_Mask{j};
        end
        Binary_Image=BasicImage_Filter(logical(Binary_Image),sHandles);
        ROI=regionprops(Binary_Image,'pixellist','boundingbox','Area','Image','Centroid');
        for j=1:numel(ROI)
            ROI(j).RegionNum=Image{1,2};
        end
        ROI={ROI};
end
end

function [Value]=Total_Sum(matrix)
Value=matrix;
while numel(sum(Value))~=1
    Value=sum(Value);
end
 Value=sum(Value);
end
