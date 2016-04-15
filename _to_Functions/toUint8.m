function [Input]=toUint8(Color_Chan)
Input=cell(numel(Color_Chan),1);
for k=1:numel(Color_Chan)
    B_Stack=Color_Chan{k};
    [numRow,numCol]=size(B_Stack(:,:,1));
    Stack_8=zeros(numRow,numCol,size(B_Stack,3));
    Stack_8=uint8(Stack_8);
    M_Temp=max(max(max(B_Stack)));
    M_Temp=double(M_Temp);
    for i=1:size(B_Stack,3)
        temp=double(B_Stack(:,:,i));
        temp=(temp/M_Temp);
        temp=temp*255;
        temp=uint8(temp);
        Stack_8(:,:,i)=temp;
        clear temp
    end
    Input{k,1}=Stack_8;
    clear Stack_8 B_Stack
end