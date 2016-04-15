function [allTable,summaryTable]=Object_Props(~,Ref_PL,Region_Objs,~,H)
%Mode Determines the Function to use on the set of pair wise distances once computed 
%Mode: 'min'
%Mode: 'max'
%Mode: 'mean'

[PL,Name]=Ref_PL{:};
Obj_Region_Chan=Region_Objs.mROI_Name;
allTable=cell(numel(PL),5);
summaryTable=cell(1,5);
Region_Index=find(ismember(Region_Objs.Channel_Name,Name));
for j=1:numel(PL)
    allTable{j,1}=sprintf('%s:%s_%d',Obj_Region_Chan,Name,j);
    for i=1:numel(H.Ana_Type);
        if H.Ana_Type(i)==1
            switch i
                case 1
                  allTable{j,2}=size(PL{j,1},1);
                case 2

                    [~,  allTable{j,3}] = convhulln(PL{j,1});
                case 3
                allTable{j,4} =prod(Region_Objs.Calibration)*size(PL{j,1},1);
                case 4
                    SA=Compute_Surface_Area(Region_Objs.makemROI_Image(Region_Objs.Binary{Region_Index}(j,1),Region_Objs.FrameShift{Region_Index}(j,:)));
                    SAC=sum(SA).*prod(Region_Objs.Calibration(1:2));
                    allTable{j,5}=SAC;
                case 5
                    allTable{j,6}= allTable{j,5}/ allTable{j,4};
                case 6
                    allTable{j,7}= allTable{j,5}/ allTable{j,3};
            end
        end
    end
end
Name=sprintf('%s:%s Summary',Obj_Region_Chan,Name);
[summaryTable{1,1},summaryTable{1,2},summaryTable{1,3}]=toSignal_Summary(allTable(:,2:end),Name,11,H,'Within');

summaryTable=[{vertcat(summaryTable{:,1})},{vertcat(summaryTable{:,2})},{vertcat(summaryTable{:,3})}];
allTable=allTable(~cellfun(@isempty,allTable(:,1)),:);
end

function [SurfaceArea]=Compute_Surface_Area(SSS)
conn6Kernel = zeros([3,3,3]);
conn6Kernel(2,2,1) = 1;
conn6Kernel(1,2,2) = 1;
conn6Kernel(2,1,2) = 1;
conn6Kernel(2,3,2) = 1;
conn6Kernel(3,2,2) = 1;
conn6Kernel(2,2,3) = 1;



sumOfFaces = convn(SSS, conn6Kernel, 'same');
surfaceArea = 6 * SSS - sumOfFaces;
surfaceArea(surfaceArea<0) = 0;
binaryVolume = surfaceArea > 0;
cc = bwconncomp(binaryVolume, 6);
measurements = regionprops(cc, surfaceArea, 'PixelValues','Image');
numberOfRegions = length(measurements);
thisRegionsArea=zeros(numberOfRegions,1);
for kk = 1 : numberOfRegions
    thesePixelValues = [measurements(kk).PixelValues];
    thisRegionsArea(kk,1) = sum(thesePixelValues);
end

SurfaceArea=sum(thisRegionsArea);

end
