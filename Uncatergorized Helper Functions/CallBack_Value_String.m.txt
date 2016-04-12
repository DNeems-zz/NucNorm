function [String]=CallBack_Value_String(H)
All_Value=get(H,'string');
if ~iscell(All_Value)
All_Value={All_Value};
end
value=get(H,'value');

String=All_Value{value};

end