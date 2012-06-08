function mn = processMMTSstring( mn, st )
% Process MMS string into manifest

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

ids = {};
NCDC_id = str2double(st(1:8));
ids{end+1} = ['ncdc_' num2str(NCDC_id)];
mn.archive_key = ['MMS_' num2str(NCDC_id)];

COOP_id = str2double(st(13:18));
if ~isempty(COOP_id) && ~isnan(COOP_id)
    ids{end+1} = ['coop_' num2str(COOP_id)];
end

mn.climate_division = str2double(st(20:21));
WBAN_id = str2double(st(23:27));
if ~isempty(WBAN_id) && ~isnan(WBAN_id)
    ids{end+1} = ['wban_' num2str(WBAN_id)];
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

location_precision = str2double(st(213:214));
switch location_precision
    case 54
        precision = 0.5 / 60;
    case 55
        precision = 0.5 / 60 / 60;
    case 63
        precision = 0.5 / 60 / 100;
    case 64
        precision = 0.5 / 60 / 1000;
    case 66
        precision = 0.5 / 60 / 60 / 10;
    case 67
        precision = 0.5 / 60 / 60 / 100;        
    otherwise
        % Catch all condition for bad and missing values.
        precision = 0.5 / 60;
end

if str2double(st(216:221)) ~= -99999
    ground_elevation = str2double(st(216:221)) / 3.2808399;  % m, converted from feet
    elev_unc = 0.5 / 3.2808399;
else
    ground_elevation = NaN;
    elev_unc = NaN;
end

mn.location = geoPoint2( latitude, longitude, ground_elevation, ...
    precision, precision, elev_unc );

if str2double(st(223:228)) ~= -99999
    mn.alt_elevation = str2double(st(223:228)) / 3.2808399;  % m, converted from feet
    mn.alt_elevation_type = str2double(st(230:231));
else
    mn.alt_elevation = NaN;
    mn.alt_elevation_type = NaN;
end
mn.reloc = strtrim(st(233:243));

% Currently we ignore station type.  Should be converted to flags later.
%mn.station_type = strtrim(st(245:294));
