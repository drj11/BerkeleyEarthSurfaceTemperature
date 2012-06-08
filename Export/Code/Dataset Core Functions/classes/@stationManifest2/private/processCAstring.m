function mn = processCAstring( mn, st )
% Process a CA manifest string and return a stationManifest

% Load country codes
persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

[id, name, lat, long, elev, country] = strread( st, '%*4s%12s%30s%5s%6s%4s%*4s%*4s%20s%*s', 'whitespace', '' );

ids = {};
id = num2str( str2double( strtrim( id{1} ) ) );

ids{end+1} = ['ca_' strtrim(id)];
mn.archive_key = ['CA_' strtrim(id)];
mn.source = stationSourceType('CA');

mn.name{end+1} = strtrim( name{1} );
try
    mn.country = country_codes_dictionary( strtrim( country{1} ) );
catch
%    disp( country{1} );
    mn.country = 0;
end

% Location info
lat_str = lat{1};
long_str = long{1};
precision = 0.005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat{1})/100;
long = str2double(long{1})/100;

if lat == -99.99
    lat = NaN;
end
if long == -199.99 || long == -99.99 || long == -999.99
    long = NaN;
end

elev = str2double(elev{1});
elev_unc = 0.5;
if elev == -999 || elev == 9999
    elev = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );

mn.ids = ids;