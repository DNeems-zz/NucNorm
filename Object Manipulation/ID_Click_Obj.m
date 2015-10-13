function [Index]=ID_Click_Obj(Mod_ROIs,Axises_H,Shift)
coordinates = get(Axises_H,'CurrentPoint');
coordinates = coordinates(1,1:2);
aproxCoor=round(coordinates);
Centroids=vertcat(Mod_ROIs{:,4});
Centroids=Centroids-repmat(Shift,size(Centroids,1),1);

[~,Index]=min(pdist2(Centroids(:,1:2),aproxCoor));

end