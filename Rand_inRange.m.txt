

function Random_Point=Rand_inRange(min_Val,max_Val,NumPoints,Decimal_Place)
min_Val=double(min_Val)/Decimal_Place;
max_Val=double(max_Val)/Decimal_Place;
Random_Point = (max_Val-min_Val).*rand(NumPoints,1) + min_Val;
Random_Point=round(Random_Point)*Decimal_Place;
end
