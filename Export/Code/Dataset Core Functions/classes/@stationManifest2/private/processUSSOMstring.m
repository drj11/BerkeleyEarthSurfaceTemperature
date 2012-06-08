function mn = processUSSOMstring( mn, st )
% Read USSOM string and place in manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

ids = {};

COOP_id = str2double(st(1:6));
mn.archive_key = ['USSOM_' num2str(COOP_id)];
if ~(COOP_id == 999999 )
    ids{end+1} = ['coop_' num2str(COOP_id)];
end

WBAN_id = str2double(st(8:12));
if WBAN_id ~= 99999
    ids{end+1} = ['wban_' num2str(WBAN_id)];
end

nm = strtrim(st(14:42));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

country_code = strtrim(st(44:74));
try
    mn.country = country_codes_dictionary( country_code );
catch
    mn.country = 0;
end
mn.state = strtrim(st(76:77));

mn.county = strtrim(st(79:103));

mn.climate_division = str2double(st(105:106));

% Prepare Lat / Long
% Locations are in Degree, Minutes format

lat_str = st(107:113);
long_str = st(115:121);
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    pos = pos + 1;
end
switch pos
    case 0
        precision = 1/120;
    case 1
        precision = 1/12;
    case 2
        precision = 0.5;
    case 3
        precision = 5;
    otherwise
        error( 'Really?!?' )
end

lat = readLatLongString(lat_str);
if strcmp( strtrim( lat_str ), '-99999' )
    lat = NaN;
end

long = readLatLongString( long_str );
if strcmp( strtrim( long_str ), '-99999' )
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

elev = str2double(st(122:end)); % meters
elev_unc = 0.05;
if elev == 99999 || elev == 9999.9 || elev == -99999 || elev == -9999
    elev = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );
mn.location.elevation = elev;

mn.ids = ids;


function v = readLatLongString( str_val )

str_val = strtrim( str_val );
v = str2double( str_val(1:end-2) );
v = v + sign(v)*str2double( str_val(end-1:end) )/60;