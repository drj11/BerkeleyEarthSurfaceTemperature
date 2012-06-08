function [counties, places] = readCensus

temperatureGlobals;

nm = [temperature_data_dir 'Census Data\1990 Census Gazetteer Files\counties.txt'];
[A,B,name,state,pop,area,lat,long] = textread( nm, '%d%d%67c%2s%d%*d%d%*d%d%d' );
code = A*1000+B;

nm = [temperature_data_dir 'Census Data\2000 Census Gazetteer Files\county2k.txt'];
[state2,code2,name2,pop2,area2,lat2,long2] = textread( nm, '%2c%5d%64c%9d%*9d%14d%*14d%*12n%*12n%10n%11n' );

counties = struct();

codes = union(code,code2);
cnt = 1;
for k = 1:length(codes)
    fk1 = findk(code,codes(k));
    fk2 = findk(code2,codes(k));
    
    if code(fk1) ~= code2(fk2)
        continue;
    end
    if abs(area(fk1)*1000 - area2(fk2)) / (area(fk1)*1000 + area2(fk2)) > 0.1
        continue;
    end
    
    counties(cnt).code = codes(k);
    counties(cnt).name = strtrim(name(fk1,:));
    counties(cnt).state = state{fk1};
    counties(cnt).area = area2(fk2);
    counties(cnt).pop1990 = pop(fk1);
    counties(cnt).pop2000 = pop2(fk2);
    counties(cnt).lat = lat(fk1)/1e6;
    counties(cnt).long = long(fk1)/1e6;
    cnt = cnt + 1;
end


nm = [temperature_data_dir 'Census Data\1990 Census Gazetteer Files\places.txt'];
[A,B,name,state,pop,area,lat,long] = textread( nm, '%d%d%66c%2s%d%*d%d%*d%d%d' );
code = A*100000+B;

nm = [temperature_data_dir 'Census Data\2000 Census Gazetteer Files\places2k.txt'];
[state2,code2,name2,pop2,area2,lat2,long2] = textread( nm, '%2c%7d%64c%9d%*9d%14d%*14d%*12n%*12n%10n%11n' );

codes = union(code,code2);
clear places;
places(length(codes)) = struct();

cnt = 1;
for k = 1:length(codes)
    fk1 = findk(code,codes(k));
    fk2 = findk(code2,codes(k));
    
    if code(fk1) ~= code2(fk2)
        continue;
    end
    if abs(area(fk1)*1000 - area2(fk2)) / (area(fk1)*1000 + area2(fk2)) > 0.1
        continue;
    end
    
    places(cnt).code = codes(k);
    places(cnt).name = strtrim(name(fk1,:));
    places(cnt).state = state{fk1};
    places(cnt).area = area2(fk2);
    places(cnt).pop1990 = pop(fk1);
    places(cnt).pop2000 = pop2(fk2);
    places(cnt).lat = lat(fk1)/1e6;
    places(cnt).long = long(fk1)/1e6;
    cnt = cnt + 1;
end

places = places(1:cnt-1);