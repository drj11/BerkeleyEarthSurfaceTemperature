function mn = processUSHCNMstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

ids = {};

COOP_id = str2double(st(1:6));
if ~(COOP_id == 999999)
    ids{end+1} = ['coop_' num2str(COOP_id)];
end

v = stationID( stationSourceType('USHCN-M'), st(1:6), 'no-save' );
ids{end+1} = ['uid_' num2str(v)];

nm = strtrim(st(37:66));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

country_code = 'UNITED STATES';
mn.country = country_codes_dictionary( country_code );

mn.state = strtrim(st(34:35));

lat = str2double(st(8:15));
long = str2double(st(17:25));

mn.location = geoPoint( lat, long );

elev = str2double(st(27:32)); % meters
mn.location.elevation = elev;

mn.time_zone = str2double( st(89:end) );

mn.ids = ids;