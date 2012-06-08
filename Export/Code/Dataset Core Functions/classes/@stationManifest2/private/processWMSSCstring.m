function mn = processWMSSCstring( mn, st )
% Process a WMSSC manifest string and return a stationManifest

% Load country codes
persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

[id, year, month, ~, lat, long, elev, name] = strread( st, '%7s%5s%3s%4s%7s%7s%7s%s', 'whitespace', '' );

ids = {};
id = id{1};

% Include start date
mn.duration = timeRange( timeInstant( str2double(year{1}) + str2double(month{1})/12 - 1/24 ), timeInstant( NaN ) );

ids{end+1} = ['wmssc_' num2str( str2double( strtrim(id) ) )];
mn.archive_key = ['WMSSC_' num2str( str2double( strtrim(id) ) )];
mn.source = stationSourceType('WMSSC');


% Some ID also contain the country name or former id at the end of the string.
% We try to trim this off when we can detect it.
A = strtrim(name{1});

f = regexpi( A, 'WAS [0-9]*' );
if ~isempty(f)
    tail = str2double( strtrim( A(f(end)+4:end) ) );
    A = strtrim( A(1:f(end)-1) );
    ids{end+1} = ['wmssc_' num2str( tail )];
end

f = find( A == ' ' );
df = diff(f);
f2 = find(df == 1);
if ~isempty(f2)
    tail = strtrim(A(f(f2(end)):end));
    if ismember( tail, country_codes_dictionary )
        A = strtrim( A(1:end-length(tail)) );
        country = country_codes_dictionary( tail );
        mn.country = country;
    end
else
    for j = length(f):-1:length(f)-4
        if j <= 0
            break;
        end
        if ismember( strtrim( A(f(j):end) ), country_codes_dictionary )
            country = country_codes_dictionary( strtrim( A(f(j):end) ) );
            mn.country = country;
            A = strtrim( A(1:f(j)-1) );
            break;
        end
    end            
end

mn.name{end+1} = A;


% Location info
lat_str = lat{1};
long_str = long{1};
precision = 0.05;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat{1})/10;
long = -str2double(long{1})/10;

if lat == -99.9
    lat = NaN;
end
if long == -199.9 || long == -99.9 || long == -999.9
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