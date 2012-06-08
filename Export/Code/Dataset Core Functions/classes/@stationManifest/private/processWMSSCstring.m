function mn = processWMSSCstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

[id, year, month, rnum, lat, long, elev, name] = strread( st, '%7s%5s%3s%4s%7s%7s%7s%s', 'whitespace', '' );

ids = {};

id = id{1};

mn.duration = timeRange( timeInstant( str2double(year{1}) + str2double(month{1})/12 - 1/24 ), timeInstant( NaN ) );

ids{end+1} = ['wmssc_' strtrim(id)];

v = stationID( stationSourceType('WMSSC'), strtrim(id), 'no-save' );
ids{end+1} = ['uid_' num2str(v)];

mn.source = stationSourceType('WMSSC');

mn.name{end+1} = strtrim(name{1});

lat = str2double(lat{1})/10;
long = -str2double(long{1})/10;

if lat == -99.9
    lat = NaN;
end
if long == -199.9 || long == -99.9 || long == -999.9
    long = NaN;
end

mn.location = geoPoint( lat, long );

elev = str2double(elev{1});
if elev == -999 || elev == 9999
    elev = NaN;
end
mn.location.elevation = elev;

mn.ids = ids;