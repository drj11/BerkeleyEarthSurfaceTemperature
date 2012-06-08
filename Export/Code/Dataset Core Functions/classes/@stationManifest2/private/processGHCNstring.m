function mn = processGHCNstring( mn, st )
% Process GHCN-D manifest string and load it.

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

FIPS = st(1:2);
mn.country = country_codes_dictionary(FIPS);

type_code = st(3);
id = st(4:11);
switch type_code
    case 'W'
        mn.ids = {['wban_' num2str(str2double(id))]};
    case 'C'
        mn.ids = {['coop_' num2str(str2double(id))]};
    otherwise
end
mn.ids{end+1} = ['ghcnd_' st(1:11)];

mn.archive_key = ['GHCN-D_' st(1:11)];

%Prepare Lat / Long
lat_str = st(13:20);
long_str = st(22:30);
precision = 0.00005;
pos = 0;
while ismember( lat_str( end-pos ), '.0' ) && ismember( long_str( end-pos ), '.0' )
    if lat_str( end-pos ) == '0'
        precision = precision * 10;
    end
    pos = pos + 1;
end

lat = str2double(lat_str);
long = str2double(long_str);
elev = str2double(st(32:37));
elev_unc = 0.5;
if elev == -999.9 || elev == -999
    elev = NaN;
    elev_unc = NaN;
end

mn.state = strtrim(st(39:40));
name = strtrim(st(42:71));
if ~isempty(name)
    mn.name{end+1} = name;
end

try
    WMO = str2double(st(81:85));
    if ~isnan(WMO)
        mn.ids = {mn.ids{:}, ['wmo_' num2str(WMO)]};
    end
catch ME
    % Some rows truncate early.
end

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );
