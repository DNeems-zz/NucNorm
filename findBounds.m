function [Lower_Bounds,Upper_Bounds]=findBounds(PL,Cali,Multi)
Lower_Bounds=(min(PL))-(Multi*[Cali.X,Cali.Y,Cali.Z]);
    Upper_Bounds=(max(PL))+(Multi*[Cali.X,Cali.Y,Cali.Z]);
    for j=1:numel(Lower_Bounds)
        if Lower_Bounds(j)<0
            Lower_Bounds(j)=0;
        end
    end
end
