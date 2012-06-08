function mn = processGSODstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

ids = {};

USAF_id = str2double(st(1:6));
if ~(USAF_id == 999999 || USAF_id == 949999 || USAF_id == 49999)
    ids{end+1} = ['usaf_' num2str(USAF_id)];
end

WBAN_id = str2double(st(8:12));
if WBAN_id ~= 99999
    ids{end+1} = ['wban_' num2str(WBAN_id)];
end

GSOD_id = [st(1:6) '-' st(8:12)];
v = stationID( stationSourceType('GSOD'), GSOD_id );
ids{end+1} = ['uid_' num2str(v)];

nm = strtrim(st(14:42));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

country_code = strtrim(st(47:49));
try
    mn.country = country_codes_dictionary( country_code );
catch
    mn.country = 0;
end
mn.state = strtrim(st(50:51));

ICAO_id = strtrim(st(53:57));
if ~isempty(ICAO_id)
    ids{end+1} = ['icao_' ICAO_id];
end

lat = str2double(st(59:64))/1000;
if lat == -99.999
    lat = NaN;
end

long = str2double(st(66:72))/1000;
if long == -999.999
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

mn.location = geoPoint( lat, long );

elev = str2double(st(74:79))/10; % meters
if elev == -99.999 || elev == 9999.9 || elev == -9999.9
    elev = NaN;
end
mn.location.elevation = elev;

mn.ids = ids;