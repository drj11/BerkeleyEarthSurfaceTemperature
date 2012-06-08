function mn = processGHCNMstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

try
    mn.country = country_codes_dictionary(['cc' st(1:3)]);
catch
    mn.country = 0;
end
    
id = st(1:11);
mn.ids = {['ghcnm_' id]};

v = stationID( stationSourceType('GHCN-M'), id );
mn.ids{end+1} = ['uid_' num2str(v)];

if strcmp(id(end-2:end), '000')
    mn.ids{end+1} = ['wmo_' id(4:end-3)];
end

mn.name = {strtrim(st(13:42))};

lat = str2double(st(43:49));
long = str2double(st(51:57));
elev = str2double(st(59:62));
if elev == -999
    elev = NaN;
end
mn.location = geoPoint( lat, long );
mn.location.elevation = elev;

mn.alt_elevation = str2double(st(63:67));
