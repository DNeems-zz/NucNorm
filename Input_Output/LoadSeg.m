function []=LoadSeg(varargin)

data=guidata(varargin{1});
handles=data{1};
data=ResetGUI(handles);

switch varargin{3}
    case 1
        %All the Data
        tic
        [filename,pathName,~]=uigetfile;
        addpath(pathName)
        L=load(strcat(pathName,filename));
        lData=L.data;
        
        if numel(lData)==2
            MChan=find(cellfun('size',lData{1},2)==9);
            
            data=ResetGUI(handles);
            data{9}=lData{1};
            data{10}=lData{2};
            data{10}(1).ManipNum=1;
            data{10}(1).FilePath=strcat(pathName,filename);
            for i=1:size(data{9}{MChan}{2,9},1)
                Bottom=min(data{9}{MChan}{2,9}{i,1});
                Top=max(data{9}{MChan}{2,9}{i,1});
                data{9}{MChan}{2,9}{i,1}=[Bottom(1),Bottom(2);Top(1),Bottom(2);Top(1),Top(2);Bottom(1),Top(2);Bottom(1),Bottom(2)];
                data{9}{MChan}{2,9}{i,3}=[Bottom(1:2),1];
                data{9}{MChan}{2,9}{i,4}=[fliplr(Top(1:2)),Top(3)]-[fliplr(Bottom(1:2)),Bottom(3)];
            end
            
            for i=1:size(data{9},2)
                display(sprintf('Restrutring Data for Chan %d of %d',i,size(data{9},2)))
                if size(data{9}{i},1)==1
                  data{2}{1,i}=data{9}{i}{1,2};
                  data{3}{1,i}=data{9}{i}{1,3};
                  data{9}{1,i}=[];
                else
                    for j=1:size(data{9}{i}{2,6},1)
                        display(sprintf('Object %d of %d',j,size(data{9}{i}{2,6},1)))
                        Temp_Region=regionprops(data{9}{i}{2,6}{j,1},'centroid','boundingbox','image','area');
                        if numel(Temp_Region)>1
                            display('Multiple Objects, Used Largest')
                            [~,I]=max([Temp_Region.Area]);
                            Temp_Region=Temp_Region(I);
                        
                        end
                            data{9}{i}{2,6}{j,1}=Temp_Region.Image;
                            data{9}{i}{2,6}{j,2}=max(Temp_Region.Image,[],3);
                            data{9}{i}{2,6}{j,3}=data{9}{i}{2,6}{j,5};
                            Original_FS=data{9}{i}{2,7}(j,1:2);
                            data{9}{i}{2,7}(j,1:3)=floor(Temp_Region.BoundingBox(1:3))+[data{9}{i}{2,7}(j,1:2),0];
                            
                            data{9}{i}{2,6}{j,4}=Temp_Region.Centroid+[Original_FS,0];
                            
                    end
                    data{9}{i}{2,6}=data{9}{i}{2,6}(:,1:4);
                    data{2}{1,i}=data{9}{i}{1,2};
                    data{3}{1,i}=data{9}{i}{1,3};
                end
                  data{4}{1,i}='Raw Stack';
                  data{5}{1,i}=cell(1,2);
                  data{6}{1,i}=cell(1,5);
                  data{7}{1,i}=zeros(1,3);
                  data{8}{1,i}=[{'Raw Stack'},{'Raw Stack'}];
                  data{11}{1,i}={[{'Raw Stack'},{'Raw Stack'}],1};

            
            end
            try
            data{9}{MChan}{2,9}(:,5)=data{10}(MChan).SimSet(:,2);
            catch
            display('No Simulation Data Added')    
            end
            handles.MasterSet_Toggle=1;
            handles.MasterExpansion=0.2;
        else
            handles.ManipulationNumber=lData{10}(1).ManipNum;
            handles.MasterSet_Toggle=lData{1}.MasterSet_Toggle;
            handles.MasterExpansion=lData{1}.MasterExpansion;
            data=lData;
        end
        toc
    case 2
        %COmmited Data Only
      %{
        tic
        [filename,pathName,~]=uigetfile;
        addpath(pathName)
        L=load(strcat(pathName,filename));
        loaddata=L.data;
        close(findall(0,'tag','IMMaster'));      
        for i=1:numel(loaddata{1})
            if cellfun('size',loaddata{1}(i),1)>1
                if cellfun('size',loaddata{1}{i}(2,2),1)==0
                    loaddata{1}{i}(2,:)=[];
                else
                    loaddata{1}{i}{2,1}=1;
                end
            end
        end
        ThresholdingGUI(loaddata,[pathName,filename]);
        toc
        ThresholdingGUI(data);
        close(handles.fh)
%}
end

guidata(handles.fh,[{handles},data(2),data(3),data(4),data(5),data(6),data(7),data(8),data(9),data(10),data(11)])
LoadImage(handles.fh,[],4)
end