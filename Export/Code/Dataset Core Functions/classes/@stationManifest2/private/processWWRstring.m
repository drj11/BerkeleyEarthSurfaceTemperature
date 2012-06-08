function mn = processWWRstring( mn, st )
% Process a WWR manifest string and return a stationManifest

% Load country codes
persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

[wmo, lat, long, country, name, elev1, elev2] = strread( st, '%*2s%5s%*1s%5s%6s%24s%24s%5s%6s', 'whitespace', '' );

ids = {};
id = wmo{1};
wmo_id = str2double( strtrim(id) );
if ~isnan(wmo_id)
    ids{end+1} = ['wmo_' num2str( wmo_id )];
end
ids{end+1} = ['wwr_' strtrim(id)];

mn.archive_key = ['WWR_' strtrim(id)];
mn.source = stationSourceType('WWR');

if length( country{1} ) > 13
    if strcmp( country{1}(1:13), 'UNITED STATES' )
        mn.state = country{1}(17:18);      
        country{1} = 'UNITED STATES';
    end
end
try
    mn.country = country_codes_dictionary( upper( strtrim( country{1} ) ) );
catch
    mn.country = 0;
    %%disp( country{1} );
end
mn.name{end+1} = strtrim( name{1} );


% Location info
% Process lat / long which is in Degrees, Minutes format
lat_str = lat{1};
long_str = long{1};
pos = 1;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    pos = pos + 1;
end
switch pos - 1
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
    long = readLatLongString( long_str );
catch
    disp(st)
    error(lasterror);
end
    
if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

if ~isempty( elev2 )
    elev = str2double(elev2{1}/10);
    elev_unc = 0.05;
elseif ~isempty( elev1 )
    elev = str2double(elev1{1});
    elev_unc = 0.5;
else 
    elev = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );
mn.ids = ids;


function v = readLatLongString( str_val )

if length( str_val ) == 6
    degree = str2double( str_val(1:3) );
    minute = str2double( str_val(4:5) );
else
    degree = str2double( str_val(1:2) );
    minute = str2double( str_val(3:4) );
end

v = degree + minute / 60;

if str_val(end) == 'S' || str_val(end) == 'W'
    v = -v;
end