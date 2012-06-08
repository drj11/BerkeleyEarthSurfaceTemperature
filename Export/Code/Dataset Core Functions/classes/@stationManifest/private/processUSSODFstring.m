function mn = processUSSODFstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

ids = {};

COOP_id = str2double(st(1:6));
if ~(COOP_id == 999999 )
    ids{end+1} = ['coop_' num2str(COOP_id)];
    p = sprintf('%06d', COOP_id); 
    v = stationID( stationSourceType('USSOD-C'), p );
    ids{end+1} = ['uid_' num2str(v)];
end

WBAN_id = str2double(st(8:12));
if WBAN_id ~= 99999
    ids{end+1} = ['wban_' num2str(WBAN_id)];
    p = sprintf('%05d', WBAN_id); 
    v = stationID( stationSourceType('USSOD-FO'), p );
    ids{end+1} = ['uid_' num2str(v)];
end

nm = strtrim(st(14:42));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

mn.country = country_codes_dictionary( 'UNITED STATES' );
 
mn.state = strtrim(st(44:45));

mn.county = strtrim(st(47:76));

mn.climate_division = str2double(st(78:79));

lat = str2double(st(81:86))/100;
if lat == -99.99 || lat == -999.99
    lat = NaN;
end

long = str2double(st(88:93))/100;
if long == -999.99
    long = NaN;
end

%correct for DMS 
lat = fix(lat) + sign(lat).*mod(abs(lat),1)*100/60;
long = fix(long) + sign(long).*mod(abs(long),1)*100/60;    

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

mn.location = geoPoint( lat, long );

elev = str2double(st(122:end)); % meters
if elev == -99.999 || elev == 9999.9 || elev == -9999.9 || elev == -99999
    elev = NaN;
end
mn.location.elevation = elev;

mn.ids = ids;