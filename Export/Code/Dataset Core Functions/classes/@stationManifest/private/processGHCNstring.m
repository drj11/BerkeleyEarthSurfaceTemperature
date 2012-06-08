function mn = processGHCNstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
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
mn.ids{end+1} = ['ghcn_' st(1:11)];

v = stationID( stationSourceType('GHCN-D'), st(1:11) );
mn.ids{end+1} = ['uid_' num2str(v)];

lat = str2double(st(13:20));
long = str2double(st(22:30));
elev = str2double(st(32:37));
if elev == -999.9 || elev == -999
    elev = NaN;
end

mn.state = strtrim(st(39:40));
name = strtrim(st(42:71));
if ~isempty(name)
    mn.name{end+1} = name;
end

WMO = str2double(st(81:85));
if ~isnan(WMO)
    mn.ids = {mn.ids{:}, ['wmo_' num2str(WMO)]};
end
mn.location = geoPoint( lat, long );
mn.location.elevation = elev;