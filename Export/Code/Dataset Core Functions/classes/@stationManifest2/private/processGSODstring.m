function mn = processGSODstring( mn, st )
% Process GSOD string and store it into a manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
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
mn.archive_key = ['GSOD_' GSOD_id];
if ~strcmp( GSOD_id, '999999-99999' )
    ids{end+1} = ['gsod_' GSOD_id];
end

nm = strtrim(st(14:42));
if ~isempty(nm)
    if nm(end) == '&'
        nm(end) = [];
        nm = strtrim(nm);
    end
end

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

%Prepare Lat / Long
lat_str = st(59:64);
long_str = st(66:72);
precision = 0.0005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat_str)/1000;
if lat == -99.999
    lat = NaN;
end

long = str2double(long_str)/1000;
if long == -999.999
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

elev = str2double(st(74:79))/10; % meters
elev_unc = 0.05;
if elev == -99.999 || elev == 9999.9 || elev == -9999.9
    elev = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );

mn.ids = ids;