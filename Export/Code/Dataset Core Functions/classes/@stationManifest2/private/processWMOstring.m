function mn = processWMOstring( mn, st )
% Process WMO string into manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

st2 = textscan( st, '%s', 'delimiter', '\t' );
st2 = st2{1};

ids = {};
WMO_id = str2double(st2{6});
index = str2double(st2{7});
if index == 0
    ids{end+1} = ['wmo_' num2str(WMO_id)];
end
mn.archive_key = ['WMO_' num2str(WMO_id) '_' num2str(index)];

mn.ids = ids;

try    
    mn.country = country_codes_dictionary(strtrim(st2{3}));
catch
    try
        f = find( st2{3} == '/' );
        if ~isempty(f)
            st2{3} = strtrim( st2{3}(1:f(1)-1) );
            mn.country = country_codes_dictionary(strtrim(st2{3}));
        else
            mn.country = 0;
        end
    catch
        mn.country = 0;
    end
end

nm = strtrim(st2{8}); % WMO name
if ~isempty(nm)
    if ~ismember( nm, mn.name )
        mn.name{end+1} = nm;
    end
end

lat_str = st2{9};
f = find( lat_str == ' ');
latitude = str2double(lat_str(1:f(1)-1)) + str2double(lat_str(f(1)+1:f(2)-1))/60 + ...
    str2double(lat_str(f(2)+1:f(2)+2))/60/60;
if lat_str(end) == 'S'
    latitude = -latitude;
end

long_str = st2{10};
f = find( long_str == ' ');
longitude = str2double(long_str(1:f(1)-1)) + str2double(long_str(f(1)+1:f(2)-1))/60 + ...
    str2double(long_str(f(2)+1:f(2)+2))/60/60;
if long_str(end) == 'W'
    longitude = -longitude;
end

pos = 1;
precision = 0;
while ismember( lat_str( end-pos ), ' 0' ) && ismember( long_str( end-pos ), ' 0' )
    if lat_str( end-pos ) == '0'
        precision = precision + 1;
    end
    pos = pos + 1;
end

switch precision
    case 0 
        precision = 0.5/60/60;
    case 1
        precision = 5/60/60;
    case 2 
        precision = 0.5 / 60;
    case 3
        precision = 5 / 60;
    case 4
        precision = 0.5;
    case 5 
        precision = 5;
    otherwise
        error( 'Precision is Strange' );
end

if ~isempty(st2{11})
    ground_elevation = str2double(st2{11});
    elev_unc = 0.5; % This is inaccuarate sometimes, needs to be fixed!!
else
    ground_elevation = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( latitude, longitude, ground_elevation, ...
    precision, precision, elev_unc );

if ~isempty(st2{13})
    mn.alt_elevation = str2double(st2{13});
    mn.alt_elevation_type = NaN;
else
    mn.alt_elevation = NaN;
    mn.alt_elevation_type = NaN;
end

% Currently we ignore station type.  Should be converted to flags later.
%mn.station_type = strtrim(st(245:294));
