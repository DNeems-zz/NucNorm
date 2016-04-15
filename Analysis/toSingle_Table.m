function Labeled_Dataset=toSingle_Table(all,summary,Header,Title)

cAll=cell(1,numel(all{1,1}));
cSummary=cell(1,numel(summary{1,1}));
Labeled_Dataset=cell(1,numel(summary{1,1}));
summary=summary(~cellfun(@isempty,summary(:,1)),:);
all=all(~cellfun(@isempty,all(:,1)),:);

if isempty(all)
    for i=1:max(size(summary,2),size(all,2))
        cAll(1,i)={nan};
    end
else
     [R,C]=size(all{1,1});
    for i=1:numel(all)
        z=1;
        for j=1:R
            for k=1:C
                Sorted_All{i,z}=all{i,1}{j,k};
                z=z+1;
            end
        end
        
    end
    z=1;
    for i=1:size(Sorted_All,2)
        TT=vertcat(Sorted_All{:,i});
        if sum(sum(~cellfun(@isempty,vertcat(TT))))==0
            cAll{1,z}=nan;
        else
            
            tt=[Header;vertcat(TT)];
            tt{1,1}=Title{1}{1};
            cAll{1,z}=toDataSet(tt);
        end
        z=z+1;
    end

end

if isempty(summary)
    for i=1:max(size(summary,2),size(all,2))
        cSummary{1,i}=arrayfun(@(x) {x},nan(1,3));
    end
else
    [R,C]=size(summary{1,1});
    for i=1:numel(summary)
        z=1;
        for j=1:R
            for k=1:C
                Sorted_Summary{i,z}=summary{i,1}{j,k};
                z=z+1;
            end
        end
        
    end
    z=1;

for i=1:size(Sorted_Summary,2)
    TT=vertcat(Sorted_Summary{:,i});
    temp_Summary=cell(1,size(TT,2));
    TT(cellfun(@isempty,TT(:,1)),:)=[];
    for j=1:size(TT,2)
        if isempty(TT) ||sum(sum(~cellfun(@isempty,vertcat(TT{:,j}))))==0
            temp_Summary{1,j}=nan;
        else
            tt=[Header;vertcat(TT{:,j})];
            tt{1,1}=Title{1}{2}{j};
            temp_Summary{1,j}=toDataSet(tt);
        end
        z=z+1;
    end
    cSummary{1,i}=temp_Summary;
end

end

    Labeled_Dataset=[cAll,[cSummary{:}]];

end

