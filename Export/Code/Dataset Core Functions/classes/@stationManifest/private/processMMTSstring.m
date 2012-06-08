function mn = processMMTSstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
end

ids = {};
NCDC_id = str2double(st(1:8));
ids{end+1} = ['ncdc_' num2str(NCDC_id)];

COOP_id = str2double(st(13:18));
if ~isempty(COOP_id) && ~isnan(COOP_id)
    ids{end+1} = ['coop_' num2str(COOP_id)];
    p = sprintf('%06d', COOP_id); 
    v = stationID( stationSourceType('USSOD-C'), p );
    ids{end+1} = ['uid_' num2str(v)];
end

mn.climate_division = str2double(st(20:21));
WBAN_id = str2double(st(23:27));
if ~isempty(WBAN_id) && ~isnan(WBAN_id)
    ids{end+1} = ['wban_' num2str(WBAN_id)];
    p = sprintf('%05d', WBAN_id); 
    v = stationID( stationSourceType('USSOD-FO'), p );
    ids{end+1} = ['uid_' num2str(v)];
end

WMO_id = str2double(st(29:33));
if ~isempty(WMO_id) && ~isnan(WMO_id)
    ids{end+1} = ['wmo_' num2str(WMO_id)];
end

FAA_id = strtrim(st(35:38));
if ~isempty(FAA_id)
    ids{end+1} = ['faa_' FAA_id];
end

NWS_id = strtrim(st(40:44));
if ~isempty(NWS_id)
    ids{end+1} = ['nws_' NWS_id];
end

ICAO_id = strtrim(st(46:49));
if ~isempty(ICAO_id)
    ids{end+1} = ['icao_' ICAO_id];
end

mn.ids = ids;

try
    mn.country = country_codes_dictionary(strtrim(st(51:70)));
catch
    mn.country = 0;
end

mn.state = strtrim(st(72:73));
mn.county = strtrim(st(75:104));
mn.time_zone = str2double(st(106:110));

nm = strtrim(st(112:141)); % COOP name
if ~isempty(nm)
    if ~ismember( nm, mn.name )
        mn.name{end+1} = nm;
    end
end
nm = strtrim(st(143:172)); % WBAN name
if ~isempty(nm)
    if ~ismember( nm, mn.name )
        mn.name{end+1} = nm;
    end
end

tm1 = datenum( st(174:181), 'yyyymmdd');
tm2 = datenum( st(183:190), 'yyyymmdd');

if tm1 == datenum( '00010101', 'yyyymmdd' )
    tm1 = 365243; % Jan 1, 1000
end
if tm2 == datenum( '99991231', 'yyyymmdd' )
    tm2 = 913108; % Jan 1, 2500
end

mn.duration = timeRange( timeInstant( tm1 ), ...
    timeInstant( tm2 ) );

latitude = str2double(st(193:194)) + str2double(st(196:197))/60 + ...
    str2double(st(199:200))/60/60;
if st(192) == '-'
    latitude = -latitude;
end

longitude = str2double(st(203:205)) + str2double(st(207:208))/60 + ...
    str2double(st(210:211))/60/60;
if st(202) == '-'
    longitude = -longitude;
end

mn.location = geoPoint( latitude, longitude );

mn.location_precision = str2double(st(213:214));

if str2double(st(216:221)) ~= -99999
    ground_elevation = str2double(st(216:221)) / 3.2808399;  % m, converted from feet
else
    ground_elevation = NaN;
end

mn.location.elevation = ground_elevation;

if str2double(st(223:228)) ~= -99999
    mn.alt_elevation = str2double(st(223:228)) / 3.2808399;  % m, converted from feet
    mn.alt_elevation_type = str2double(st(230:231));
else
    mn.alt_elevation = NaN;
    mn.alt_elevation_type = NaN;
end
mn.reloc = strtrim(st(233:243));
mn.station_type = strtrim(st(245:294));
