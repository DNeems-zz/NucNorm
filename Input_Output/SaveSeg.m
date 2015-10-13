function []=SaveSeg(varargin)
switch varargin{3}
    % Save the Whole data strucutre 
    case 1
        data=guidata(varargin{1});
        data{1}.ChannelMenu=get(data{1}.ChannelMenu,'String');
        data{1}.DisplayModeMenu=get(data{1}.DisplayModeMenu,'String');
        def = {sprintf('%s_%s.mat',data{10}(1).Image_ID,data{10}(1).Image_Number)};
        [FileName,PathName] = uiputfile(def,'Save Segmentation Progress');
        
        save([PathName,FileName],'data', '-v7.3')
    %Saves on the commited data
    case 2
        data=guidata(varargin{1});
        data{1}.ChannelMenu=get(data{1}.ChannelMenu,'String');
        data{1}.DisplayModeMenu=get(data{1}.DisplayModeMenu,'String');
        def = {sprintf('%s_%s_SegOnly.mat',data{10}(1).Image_ID,data{10}(1).Image_Number)};
        %Maniupulation Log
        ManipLog=data{1}.ManipulationLog;
        data{10}(1).ManiLog=data{1}.ManipulationLog;
        [FileName,PathName] = uiputfile(def,'Save Segmentation Progress');
        A=regexp(FileName,'.mat','split');
        fid = fopen([PathName,sprintf('%s_Log.txt',A{1})],'wt');
        for i=1:numel(ManipLog)
            fprintf(fid, '%s\n', data{10}(i).Channel_ID);
            for j=1:size(ManipLog{i},1)
                fprintf(fid, '%s\n', ManipLog{i}{j,:});
            end
            fprintf(fid, '\n');
            fprintf(fid, '\n');
            fprintf(fid, '\n');
            fprintf(fid, '\n');
            
        end
        data=data(:,9:10);
        save([PathName,FileName],'data', '-v7.3')
        
end
end