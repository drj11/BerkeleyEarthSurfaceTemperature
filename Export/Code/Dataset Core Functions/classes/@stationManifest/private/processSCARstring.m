function mn = processSCARstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

ids = {};

WMO_id = str2double(st(1:6));
ids{end+1} = ['wmo_' num2str(WMO_id)];

v = stationID( stationSourceType('SCAR'), num2str(WMO_id) );
ids{end+1} = ['uid_' num2str(v)];

nm = strtrim(st(7:37));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

country_code = 'ANTARCTICA';
try
    mn.country = country_codes_dictionary( country_code );
catch
    mn.country = 0;
end

lat = str2double(st(39:45));
if lat == -99.999
    lat = NaN;
end

long = str2double(st(47:54));
if long == -999.999
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

mn.location = geoPoint( lat, long );

elev = str2double(st(56:64)); % meters
if elev == -99.999 || elev == 9999.9 || elev == -9999.9
    elev = NaN;
end
mn.location.elevation = elev;

mn.ids = ids;