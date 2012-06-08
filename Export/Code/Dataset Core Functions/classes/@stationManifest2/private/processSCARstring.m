function mn = processSCARstring( mn, st )
% Convert SCAR string into manifest.

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

ids = {};

WMO_id = str2double(st(1:6));
ids{end+1} = ['wmo_' num2str(WMO_id)];
mn.archive_key = ['SCAR_' num2str(WMO_id)];

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

% Prepare Lat / Long
lat_str = st(39:45);
long_str = st(47:54);
precision = 0.0005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat_str);
if lat == -99.999
    lat = NaN;
end

long = str2double(long_str);
if long == -999.999
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

elev = str2double(st(56:64)); % meters
elev_unc = 0.5;
if elev == -99.999 || elev == 9999.9 || elev == -9999.9
    elev = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );

mn.ids = ids;