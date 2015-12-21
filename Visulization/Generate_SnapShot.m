function []=Generate_SnapShot(varargin)
Input_H=varargin{3};
data=varargin{4};
Image_Window=varargin{5};
NumChan=numel(data{9});
MChan=data{10}(1).Channel_Master;
mROI_Choice=get(Input_H.ObjMenu,'value')-1;
Slice=get(Input_H.SliceMenu,'value');
if mROI_Choice==0
    mROI_Choice=transpose(1:numel(cell2mat(data{9}{MChan}{2,9}(:,2))));
end

if numel(mROI_Choice)==1
    SingleROI_Image(Input_H,data,mROI_Choice,Image_Window)
else
    AllROI_Image(Input_H,data,mROI_Choice,Image_Window)
    
end

end


function []=SingleROI_Image(Input_H,data,mROI_Choice,Image_Window)
NumChan=sum(cellfun('size',data{9},1)==2);

MChan=data{10}(1).Channel_Master;
Slice=get(Input_H.SliceMenu,'value')-1;
RawImage=uint8(zeros(data{9}{MChan}{2,9}{mROI_Choice,4}(1:2)+1));
BinaryImage=repmat(RawImage,[1,1,3]);
RawImage=repmat(RawImage,[1,1,3]);
Color_Index=[{3},{2},{1},{[1,3]}];
Region_Obj=mROI_Obj(data,mROI_Choice);

for i=1:NumChan
    if get(Input_H.Type(i),'value')~=3
        P=Color_Index{i};
        
        switch CallBack_Value_String(Input_H.Type(i))
            case 'Binary'
                switch CallBack_Value_String(Input_H.Fill(i))
                    case 'Perimeter'
                        Mask=Region_Obj.getPerm_Image(i,'Whole');
                    case 'Mask'
                        Mask=Region_Obj.getmROI_Image(i,'Binary');
                end
                if Slice==0
                    switch CallBack_Value_String(Input_H.Fill(i))
                        case 'Perimeter'
                            for k=1:numel(P)
                                BinaryImage(:,:,P(k))=BinaryImage(:,:,P(k))+uint8(bwperim(max(Mask,[],3)))*255;
                            end
                        otherwise
                            for k=1:numel(P)
                                BinaryImage(:,:,P(k))=BinaryImage(:,:,P(k))+uint8(max(Mask,[],3))*255;
                            end
                    end
                else
                    
                    for k=1:numel(P)
                        BinaryImage(:,:,P(k))=BinaryImage(:,:,P(k))+uint8(Mask(:,:,Slice))*255;
                    end
                end
            case 'Intensity'
                switch CallBack_Value_String(Input_H.Fill(i))
                    case 'All'
                        Int_Image=Region_Obj.getmROI_Image(i,'Intensity');
                    case 'Cut-Out'
                        Int_Image=Region_Obj.getmROI_Image(i,'Intensity');
                        Mask=Region_Obj.getmROI_Image(i,'Binary');
                        Int_Image=Int_Image-uint8(~Mask)*255;
                        
                end
                if Slice==0
                    for k=1:numel(P)
                        RawImage(:,:,P(k))=RawImage(:,:,P(k))+max(Int_Image,[],3);
                    end
                else
                    for k=1:numel(P)
                        RawImage(:,:,P(k))=RawImage(:,:,P(k))+Int_Image(:,:,Slice);
                    end
                end
        end
    end
end


for i=1:3
    RawImage(:,:,i)=RawImage(:,:,i)+BinaryImage(:,:,i);
end
ScaleBar=uint8(false(size(RawImage(:,:,1))));
[H,W]=size(ScaleBar);
Length=5/Region_Obj.Calibration(1);
wEnd=round(W-(W*.05));
wStart=round(wEnd-Length);
hStart=round(H-H*.05);
hEnd=round(hStart+2);
for i=wStart:wEnd
    for j=hStart:hEnd
    ScaleBar(j,i)=255;
    end
end
RawImage=RawImage+repmat(ScaleBar,[1,1,3]);


imshow(RawImage,'parent',Image_Window.Parent_Ax)
set(Image_Window.Image_Window,'visible','on')
end

function []=AllROI_Image(Input_H,data,mROI_Choice,Image_Window)
NumChan=numel(data{9});
Slice=get(Input_H.SliceMenu,'value');
RawImage=uint8(zeros(data{1}.IMSize(1:2)));
BinaryImage=repmat(RawImage,[1,1,3]);
RawImage=repmat(RawImage,[1,1,3]);
Color_Index=[{3},{2},{1},{[1,3]}];

for i=1:NumChan
    if strcmp(get(Input_H.Fill(i),'enable'),'on')
        IMs=[data{9}{i}(1,2),data{9}{i}(2,2),{data{9}{i}{2,6}(:,1)}];
        
        for j=1:size(IMs{3},1)
            for k=1:size(IMs{3}{j},3)
                IMs{3}{j}(:,:,k)=imfill(IMs{3}{j}(:,:,k),'holes');
            end
            IMs{3}{j}=bwperim( IMs{3}{j});
        end
        if Slice==1
            IMs=[{max(IMs{1,1},[],3)},{max(IMs{1,2},[],3)},{arrayfun(@(x) max(x{1},[],3),IMs{3},'uniformoutput',0)}];
            Valid_Index=transpose(1:size(data{9}{i}{2,6}(:,1),1));
        else
            Adj_Slice=(repmat(Slice-1,size(data{9}{i}{2,7}(:,3),1),1)-data{9}{i}{2,7}(:,3));
            Section_Slice=cell(size(Adj_Slice,1),1);
            for j=1:size(Adj_Slice,1)
                if size(data{9}{i}{2,6}{j,1},3)>=Adj_Slice(j,:) && Adj_Slice(j,:)>0
                    Section_Slice{j,1}= IMs{3}{j}(:,:,Adj_Slice(j,:));
                end
            end
            Valid_Index=find(~cellfun(@isempty,Section_Slice));
            
            IMs=[{IMs{1,1}(:,:,Slice-1)},...
                {IMs{1,2}(:,:,Slice-1)},...
                {Section_Slice(Valid_Index,:)}];
            
        end
        P=Color_Index{i};
        
        switch CallBack_Value_String(Input_H.Type(i))
            case 'Binary'
                switch CallBack_Value_String(Input_H.Fill(i))
                    case 'Perimeter'
                       
                        Mask=logical(max(BinaryImage,[],3));
                       
                        for k=1:size(IMs{1,3},1)
                            BWP=(IMs{1,3}{k,1});
                            FS=data{9}{i}{2,7}(Valid_Index(k),1:2);
                            [W,H]=size(BWP);
                            Mask(FS(2):FS(2)+W-1,FS(1):FS(1)+H-1)=Mask(FS(2):FS(2)+W-1,FS(1):FS(1)+H-1)+BWP;
                            
                        
                        end
                    case 'Mask'
                        Mask=IMs{1,2};
                end
                    for k=1:numel(P)
                        BinaryImage(:,:,P(k))=BinaryImage(:,:,P(k))+uint8(Mask)*255;
                    end

            case 'Intensity'
                switch CallBack_Value_String(Input_H.Fill(i))
                    case 'All'
                        for k=1:numel(P)
                            RawImage(:,:,P(k))=RawImage(:,:,P(k))+IMs{1,1};
                        end
                    case 'Cut-Out'
                        for k=1:numel(P)
                            RawImage(:,:,P(k))=RawImage(:,:,P(k))+(IMs{1,1}-(uint8(~IMs{1,2})*255));
                        end
                        
                end
        end
    end
end

for i=1:3
    RawImage(:,:,i)=RawImage(:,:,i)+BinaryImage(:,:,i);
end

imshow(RawImage,'parent',Image_Window.Parent_Ax)
set(Image_Window.Image_Window,'visible','on')
end

