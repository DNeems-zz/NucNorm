function [data]=ResetGUI(handle)
numChan=1;
data{2}=cell(20,numChan);
data{3}=cell(20,numChan);
data{4}=cell(20,numChan);
data{5}=cell(20,numChan);
data{6}=cell(20,numChan);
data{7}=cell(20,numChan);
data{8}=cell(20,numChan);
data{9}=cell(1,numChan);
data{11}=repmat({[cell(1,1),1]},20,numChan);

MetaData=struct('Image_ID', 'UnSet',...
    'Image_Number', 'UnSet',...
    'Channel_ID', 'UnSet',...
    'Channel_Dye', 'UnSet',...
    'Channel_Color', 'yellow',...
    'Other', 'UnSet',...
    'CaliMetaData', [],...
    'Channel_Master','None',...
    'byObj_ID', []);
MetaData.CaliMetaData=struct('XCal', 1,...
    'YCal', 1,...
    'ZCal', 1,...
    'Dye_Wavelength', nan,...
    'Mag',nan,...
    'Numerical_Aperture', nan,...
    'Refractive_Index',nan,...
    'Immersion_Media', 'Unset');
MetaData.byObj_ID=repmat({'Unset'},1,1);
MetaData=repmat(MetaData,1,numChan);
Color{1}='blue';
Color{2}='green';
Color{3}='red';
Color{4}='yellow';
for i=1:numChan
    MetaData(i).Channel_Color=Color{i};
    MetaData(i).Channel_ID=sprintf('Chan %d',i);
end


for i=1:numel(handle.byChanObj)
set(handle.byChanObj(i),'visible','off')
end
set(handle.DisplayTypeMenu,'value',1)
set(handle.AdvancedDisplay,'value',0)
set(handle.DisplayTypeMenu,'visible','off')
set(handle.SliceSlider,'visible','off')
set(handle.SliceSlider,'value',1)
set(handle.CurrentSlice,'visible','off')
set(handle.CurrentSlice,'string','Current Slice: 1')
handle.IMSize=[1024,1024,1];
handle.ManipulationNumber=1;
handle.MasterSet_Toggle=false;
handle.MasterExpansion=.2;

data{10}=MetaData;
data{1}=handle;
set(handle.DisplayModeMenu,'string','Raw Stack','value',1)
set(handle.OverlayMenu,'string','None','value',1)
set(handle.ChannelMenu,'string',MetaData(1).Channel_ID,'value',1)
set(handle.MasterROIMenu,'string','None','value',1)
set(handle.Title,'string','None')
set(handle.Type,'string','Image Type: Gray Scale')
set(handle.InputImage,'string','Input Image: None')
set(handle.Seg,'string','Segmented: No')
set(handle.ObjCount,'string','Num ROIs: NaN')
handle.ImagePlace_Handle=(findobj((get(handle.IMAxes,'Children')),'type','image'));

set(handle.ImagePlace_Handle,'cData',false([1,1,3]))
end