function Labeled_Dataset=toSingle_Table(all,summary,Header,Title)

cAll=cell(1,size(all,2));
cSummary=cell(1,size(summary,2));
Labeled_Dataset=cell(1,size(all,2));

if isempty(all{1,1})
    for i=1:size(all,2)
        cAll(1,i)={nan};
    end
else
    for i=1:size(all,2)
        
        Temp_Table=vertcat(all{:,i});
        Temp_Table=[Header;Temp_Table];
        Temp_Table{1,1}=Title{1}{1};
        cAll{1,i}=toDataSet(Temp_Table);
    end
end

if isempty(summary{1,1})
    for i=1:size(all,2)
        cSummary{1,i}=arrayfun(@(x) {x},nan(1,3));
    end
else
    for i=1:size(summary,2)
        
        tempTable=vertcat(summary{:,i});
        for j=1:3
            tt=[Header;vertcat(tempTable{:,j})];
            tt{1,1}=Title{1}{2}{j};
            cSummary{1,i}{1,j}=toDataSet(tt);
        end
    end
end
for i=1:size(all,2)
    Labeled_Dataset{1,i}=[cAll(1,i),cSummary{1,i}];
end
end
