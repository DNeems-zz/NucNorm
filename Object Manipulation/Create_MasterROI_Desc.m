function [mROI_data]=Create_MasterROI_Desc(mRegions,FS,RawImage,Expand_Rate)
[R,~]=size(mRegions);
        mROI_data=cell(R,4);
        %if numel(Expand_Rate)~=numel(R)
        %    Expand_Rate
        
       % end
        for i=1:R
            W=size(mRegions{i,1},1); h=size(mRegions{i,1},2); D=size(mRegions{i,1},3);
            Y=FS(i,2);X=FS(i,1); Z=FS(i,3);
            
            [RI,BB(1),BB(2),BB(3)]=Crop_Image(RawImage{:},X,Y,Z,h,W,D,Expand_Rate(i));
            
            mROI_data{i,2}=mRegions{i,3};
            mROI_data{i,3}=BB;
            mROI_data{i,4}=size(RI)-1;
            Y_Corner=[mROI_data{i,3}(2),mROI_data{i,3}(2)+mROI_data{i,4}(1),mROI_data{i,3}(2)+mROI_data{i,4}(1),mROI_data{i,3}(2),mROI_data{i,3}(2)];
            X_Corner=[mROI_data{i,3}(1),mROI_data{i,3}(1),mROI_data{i,3}(1)+mROI_data{i,4}(2),mROI_data{i,3}(1)+mROI_data{i,4}(2),mROI_data{i,3}(1)];
            mROI_data{i,1}=[X_Corner',Y_Corner'];
        end
end