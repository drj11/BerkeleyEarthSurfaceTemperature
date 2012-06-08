function mn = processUSSODCstring( mn, st )
% Process USSOD-C string into a manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

ids = {};
COOP_id = str2double(st(1:6));
if COOP_id ~= 999999
    ids{end+1} = ['coop_' num2str(COOP_id)];
end

WBAN_id = str2double(st(8:12));
if WBAN_id ~= 99999
    ids{end+1} = ['wban_' num2str(WBAN_id)];
end

mn.archive_key = ['USSOD-C_' st(1:6) '_' st(8:12)];

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

% Process lat / long which is in Degrees, Minutes format
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

try
    lat = readLatLongString( lat_str );
    if strcmp( strtrim(lat_str), '-99999' )
        lat = NaN;
    end

    long = readLatLongString( long_str );
    if strcmp( strtrim(long_str), '-99999' )
        long = NaN;
    end
catch
    disp(st)
    error(lasterror);
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

mn.ids = ids;


function v = readLatLongString( str_val )

str_val = strtrim( str_val );
if length(str_val) < 2 || ( length(str_val) < 3 && str_val(1) == '-' )
    % At 0 latitude or 0 longitude, the 0 is omitted and only degrees are
    % printed.
    if str_val(1) == '-'
        v = -eps;
    else
        v = eps;
    end
else
    v = str2double( str_val(1:end-2) );
    if v == 0
        if str_val(1) == '-'
            v = -eps;
        else
            v = eps;
        end
    end        
end

if length(str_val) > 1
    v = v + sign(v)*str2double( str_val(end-1:end) )/60;
else
    v = v + sign(v)*str2double( str_val )/60;
end    