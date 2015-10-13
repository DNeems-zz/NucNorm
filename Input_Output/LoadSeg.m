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
        data=L.data;
        handles.ManipulationNumber=data{10}(1).ManipNum;
        handles.MasterSet_Toggle=data{1}.MasterSet_Toggle;
        handles.MasterExpansion=data{1}.MasterExpansion;

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