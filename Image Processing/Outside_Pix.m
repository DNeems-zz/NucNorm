function [Filtered_ROIs,delta_ROIs]=Outside_Pix(mROIs,Filtered_ROIs)
Centroids=Filtered_ROIs{2}(:,4);
FS=mROIs{1,2};
PL=cell(size(mROIs{1,1},1),1);
for i=1:size(mROIs{1,1},1)
    tPL=regionprops(mROIs{1,1}{i,1},'pixellist');
    PL{i,1}=tPL.PixelList+repmat(FS(i,:),size(tPL.PixelList,1),1);
end
Del_ROI=false(size(Filtered_ROIs{1,1},1),1);

for i=1:size(Filtered_ROIs{1,1},1)
    Match=false(size(mROIs,1),1);
    for j=1:size(PL,1)
        Match(j,i)=mean(pdist2(PL{j,1}(knnsearch(PL{j,1},Centroids{i},'k',9),:),Centroids{i}),1)<=1;
    end
    if sum(Match)==0
    Del_ROI(i,1)=true;
    end
    display(sprintf('Filtering region %d of %d',i,size(Filtered_ROIs{1,1},1)))
end

delta_ROIs=cell(sum(Del_ROI),2);
for i=1:size(delta_ROIs,1)
delta_ROIs{i,2}=1;
end
for i=1:3
    rm=Filtered_ROIs{1,i}(Del_ROI,:);
    
    for j=1:size(rm,1)
    delta_ROIs{j,1}{1,i}=rm(j,:);
    end
    Filtered_ROIs{1,i}(Del_ROI,:)=[];
end

end