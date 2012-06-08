function mn = processGHCNMstring( mn, st )
% Takes a GHCN-M location string and spits back a manifest 

% Load country codes.
persistent country_codes_dictionary country_names_dictionary;
if isempty(country_codes_dictionary)
    [country_codes_dictionary, country_names_dictionary] = loadCountryCodes();
end

% Look up country
try
    mn.country = country_codes_dictionary(['cc' st(1:3)]);
    country_name = country_names_dictionary( mn.country );
catch
    mn.country = 0;
end
   
% Populate IDs
id = st(1:11);
mn.ids = {['ghcnm_' id]};
mn.archive_key = ['GHCN-M_' id];

if strcmp(id(end-2:end), '000')
    mn.ids{end+1} = ['wmo_' num2str( str2double( id(4:end-3) ) )];
end

% Some ID also contain the country name at the end of the string.
% We try to trim this off when we can detect it.
A = strtrim(st(13:42));
f = find( A == ' ' );
df = diff(f);
f2 = find(df == 1);
if ~isempty(f2)
    tail = strtrim(A(f(f2(end)):end));
    if length(tail) <= length(country_name) && strcmpi( tail, country_name(1:length(tail)) )
        A = strtrim( A(1:end-length(tail)) );
    else
        if ismember( tail, country_codes_dictionary )
            A = strtrim( A(1:end-length(tail)) );
        end
    end
end
    
% Store the name
mn.name = {A};

% Load location data
lat_str = st(43:49);
long_str = st(51:57);
precision = 0.005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat_str);
long = str2double(long_str);
elev = str2double(st(59:62));
elev_unc = 0.5;
if elev == -999
    elev = NaN;
    elev_unc = NaN;
end
mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );

mn.alt_elevation = str2double(st(63:67));
