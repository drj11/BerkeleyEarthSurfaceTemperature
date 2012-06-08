function mn = processGSNMONstring( mn, st )
% Process GSNMON string and store it into a manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

C = textscan( st, '%d%s%s%s%s%s', 'delimiter', '\t\n' );

wmo = C{1};
fips = C{2};
name = C{3};
lat_str = C{4};
long_str = C{5};
country = C{6};

ids = {['wmo_' num2str( wmo )]};
mn.archive_key = ['GSNMON_' num2str( wmo )];

mn.name{end+1} = strtrim(name{1});

country_code = fips;
try
    mn.country = country_codes_dictionary( strtrim(country_code{1}) );
catch
    try
        mn.country = country_codes_dictionary( strstrim(country{1}) );
    catch
        mn.country = 0;
    end
end

%Prepare Lat / Long
precision = 0.005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat_str);
if lat == -99.99
    lat = NaN;
end

long = str2double(long_str);
if long == -99.99
    long = NaN;
end

if lat == 0 && long == 0
    lat = NaN;
    long = NaN;
end

mn.location = geoPoint2( lat, long, NaN, precision, precision, NaN );
mn.ids = ids;