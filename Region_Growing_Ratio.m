function Ratio=Region_Growing_Ratio(IM_NoZero,Temp_IM) 
Sorted_Int=sort(IM_NoZero);
    NumPix=numel(Sorted_Int);
    Range=floor(NumPix/3);
    % Differance in intensisty between the dimest 3rd and birghtest third
    % of the voxel above ostu threshold 
    Section_Mean=abs(mean(Sorted_Int(1:Range))-mean(Sorted_Int(end-Range:end)));
    Correction=(max(max(max(Temp_IM)))-Section_Mean)*2; %The two here is an arbitary fudge factor/
    Ratio=Image_Mode/Correction;
    Image_Mean=mean(IM_NoZero);
    Prcnt_Over_Mean=sum(IM_NoZero>Image_Mean)/NumPix;
    Ratio=Ratio+(Prcnt_Over_Mean/15); 
end