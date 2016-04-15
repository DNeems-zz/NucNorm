function [Path,Filenames]=Result_toCSV(data,Path)
DataSets=data{1,1};

Filenames=cell(numel(DataSets),1);

Ref_Point=regexp(data{2,1},': ','split');
    warning('off','MATLAB:DELETE:FileNotFound')
        warning('off', 'MATLAB:xlswrite:AddSheet')

for i=1:numel(DataSets)
    Info_Header=[{'Image:'},{' '},...
        {'Referance Chan:'},{' '},...
        {'Analysis Chan:'},{' '},...
        sprintf('%s to',data{2,1}),{' '}];

    [Base,Ref,Ana]=SplitName(DataSets{i}.Properties.ObsNames{1,1});

    Info_Header{1,2}=Base; Info_Header{1,4}=Ref;
    Info_Header{1,6}=Ana; Info_Header{1,8}=DataSets{i}.Properties.Description;
    Data_Header=DataSets{i}.Properties.UserData;
    Data_Header{1,1}='Image: mROI:: Ref_# to Signal_#';
    ObsNames=DataSets{i}.Properties.ObsNames;
    Output_Data=[Data_Header;[ObsNames,arrayfun(@(x) {x},double(DataSets{i}))]];

    Filenames{i,1}=sprintf('%s_%s-%s %s %s to %s.csv',Base,Ref,Ana,Ref_Point{1},Ref_Point{2},DataSets{i}.Properties.Description);
    Filenames{i,1}=strcat(Path,'\',Filenames{i,1});
    fid = fopen(Filenames{i,1},'w+');
    %invalid File Name
    if fid==-1
        keyboard
    end
    numColumns_Info_Header = size(Info_Header,2);
    numColumns_Output_Data = size(Output_Data,2);
    % use repmat to construct repeating formats
    % ( numColumns-1 because no comma on last one)
    headerFmt = repmat('%s,',1,numColumns_Info_Header-1);
    headerData = repmat('%s,',1,numColumns_Output_Data-1);
    numFmt =strcat('%s,',repmat('%f,',1,numColumns_Output_Data-2));
    
    fprintf(fid,[headerFmt,'%s\n'],Info_Header{1,:});
    fprintf(fid,[headerData,'%s\n'],Output_Data{1,:});
    for j=2:size(Output_Data,1)
        fprintf(fid,[numFmt,'%f\n'],Output_Data{j,:});
    end
    fclose(fid);    
end

Input_Table=cell(numel(DataSets),1);
Contents=dir(Path);
cNames=cell(numel(Contents),1);
for j=1:numel(Contents)
cNames{j,1}=Contents(j).name;
end
BaseName=sprintf('%s %s-%s',Base,Ref_Point{1},Ref_Point{2});
toDelete=cNames(~cellfun(@isempty ,arrayfun(@(x) regexp(x,BaseName),cNames)),:);
for j=1:numel(toDelete)
delete(strjoin([Path,toDelete(j)],'/'))
end
for i=1:numel(DataSets)
    display(sprintf('Writing XLS Sheet %d/%d',i,numel(DataSets)));
    Input_Table{i,1}=readCSV(Filenames{i,1});
       [Base,Ref,Ana]=SplitName(DataSets{i}.Properties.ObsNames{1,1});
SP=regexp(DataSets{i}.Properties.Description,'-','split');
    Sheet_Name=sprintf('%s %s-%s',SP{end},Ref,Ana);
    if length(Sheet_Name)>31
        Sheet_Name=Sheet_Name(1:31);
    end
    xlswrite(strcat(Path,'/',sprintf('%s %s-%s %s.xls',Base,Ref_Point{1},Ref_Point{2},date)),...
        Input_Table{i,1},...
        Sheet_Name);  
end
Mat_Name=strcat(Path,'/',sprintf('%s %s-%s %s.mat',Base,Ref_Point{1},Ref_Point{2},date));
save(Mat_Name,'DataSets');
zip(strcat(Path,'/',sprintf('%s %s-%s %s',Base,Ref_Point{1},Ref_Point{2},date)),Filenames);
for i=1:numel(Filenames);
    delete(Filenames{i,1})
end
end

function [Base,Ref,Ana]=SplitName(FullName)    
Image_Name=regexp(FullName,'::','split');
Base_Name=regexp(Image_Name{1},':','split');
Base=Base_Name{1};
Image_Name=regexp(Image_Name{2},' to ','split');
Ref=regexp(Image_Name{1},'_','split');
Ref=Ref{1};
if numel(Image_Name)==1
    Ana=regexp(Image_Name{1},'_','split');
    Ana=Ana{1};
else
    Ana=regexp(Image_Name{2},'_','split');
    Ana=Ana{1};
end
end
function [Table]=readCSV(Filename)

    fid=fopen(Filename);
    z=1;
    Table=cell(1,1);
    inFile=true;
    while  inFile
        Line=fgetl(fid);
         if Line==-1
         inFile=false;
         else
        Table{z,1}=regexp(Line,',','split');
         end
        z=z+1;
    end
    for i=3:size(Table,1)
        Table{i}(1,2:end)=arrayfun(@(x) {x},arrayfun(@(x) str2double(x),Table{i}(2:end)));
    
    end
    [Table]=square_forWriting(Table);
    fclose(fid);
end
function [Table]=square_forWriting(Table)
Max_Col=max(cellfun('size',Table,2));

for i=1:size(Table,1)
    if numel(Table{i,1})~=Max_Col
    Table{i,1}=[Table{i,1},repmat({nan},1,Max_Col-numel(Table{i,1}))];
    end
end
 Table=vertcat(Table{:});
end