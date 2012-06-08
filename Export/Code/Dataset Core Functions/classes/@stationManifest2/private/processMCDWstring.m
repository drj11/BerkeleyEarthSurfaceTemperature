function mn = processMCDWstring( mn, st )
% Process MCDW string and store it into a manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

wmo = str2double( st(1:5) );
name =  strtrim( st(11:43) );
long_str = strtrim( st(45:50) );
lat_str = strtrim( st(52:57) );
elevation = str2double(st(59:65));
country = strtrim( st(67:105) );

ids = {['wmo_' num2str( wmo )]};
mn.archive_key = ['MCDW_' num2str(wmo)];
mn.name{end+1} = strtrim(name);

try
    mn.country = country_codes_dictionary( country );
catch
    mn.country = 0;
end

%Prepare Lat / Long
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    pos = pos + 1;
    if length( lat_str ) <= pos || length( long_str ) <= pos
        pos = -1;
        break;
    end
end
switch pos
    case -1
        precision = NaN;
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
if lat == -99.99 || strcmp( lat_str, '999') || ...
        strcmp( lat_str, '99999' ) || strcmp( lat_str, '9999' )
    lat = NaN;
end

long = readLatLongString(long_str);
if long == -99.99 || strcmp( long_str, '999') || ...
        strcmp( long_str, '99999' ) || strcmp( long_str, '9999' )
    long = NaN;
end

if (abs(lat) < 1e-15 && abs(long) < 1e-15) || isnan( precision )
    lat = NaN;
    long = NaN;
end

if elevation ~= 9999 &&  elevation ~= 999
    elev = elevation;
    elev_unc = 0.5;
else
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