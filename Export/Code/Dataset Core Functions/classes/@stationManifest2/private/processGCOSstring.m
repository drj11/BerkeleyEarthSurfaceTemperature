function mn = processGCOSstring( mn, st )
% Process a GCOS manifest string and return a stationManifest

% Load country codes
persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

st = strvcat(st);

year = str2num(st(:,1:4));
month = str2num(st(:,5:6));
id = str2num(st(:, 8:12));
name = cellstr( st(:,14:38) );
lat = cellstr( st(:,40:44) );
long = cellstr( st(:,46:52) );

ids = {};

% Include start date
mn.duration = timeRange( timeInstant( year(1) + month(1)/12 - 1/24 ), timeInstant( NaN ) );

ids{end+1} = ['wmo_' num2str(id(1))];
mn.source = stationSourceType('GCOS');

mn.archive_key = ['GCOS_' num2str(id(1))];

A = strtrim(name{1});
mn.name{end+1} = A;
mn.country = 0;

% Location info
lat_str = lat{1};
long_str = long{1};
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

lat_str = strtrim(lat_str);
long_str = strtrim(long_str);

lat = readLatLongString( lat_str );
if strcmp( lat_str, '-99999' ) || ...
        strcmp( lat_str, '-9999' ) || ...
        strcmp( lat_str, '9999' ) || ...
        strcmp( lat_str, '99999' )
    lat = NaN;
end

long = readLatLongString( long_str );
if strcmp( long_str, '-99999' ) || ...
        strcmp( long_str, '-9999' ) || ...
        strcmp( long_str, '9999' ) || ...
        strcmp( long_str, '99999' )
    long = NaN;
end

if lat == -99.9
    lat = NaN;
end
if long == -199.9 || long == -99.9 || long == -999.9
    long = NaN;
end

mn.location = geoPoint2( lat, long, NaN, precision, precision, NaN );
mn.site_flags(end+1) = siteFlags( 'GCOS' );
mn.ids = ids;



function v = readLatLongString( str_val )

str_val = strtrim( str_val );
if length(str_val) < 2 || ( length(str_val) < 3 && str_val(1) == '-' )
    % At 0 latitude or 0 longitude, the 0 is omitted and only degrees are
    % printed.  Stupid format.
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