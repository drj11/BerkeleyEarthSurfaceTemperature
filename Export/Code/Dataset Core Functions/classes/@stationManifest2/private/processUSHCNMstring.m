function mn = processUSHCNMstring( mn, st )
% Takes a USHCN-M location string and spits back a manifest 

% Load country codes
persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

ids = {};

% All ids are coop ids
COOP_id = str2double(st(1:6));
mn.archive_key = ['USHCN-M_' num2str(COOP_id)];
if COOP_id ~= 999999
    ids{end+1} = ['coop_' num2str(COOP_id)];
end

% Composite sites have alternate IDs
for k = 1:3    
    altID = st((68:73) + 7*(k-1));
    if ~strcmp( altID, '------' )
        altID = str2double( altID );
        ids{end+1} = ['coop_' num2str(altID)];
    end
end

if length(ids) > 1
    mn.site_flags(end+1) = siteFlags( 'USHCN_COMPOSITE' );
end

% Name
nm = strtrim(st(37:66));
if ~isempty(nm)
    mn.name{end+1} = nm;
end

% Continental US only
country_code = 'UNITED STATES';
mn.country = country_codes_dictionary( country_code );

mn.state = strtrim(st(34:35));

% Location and Location Uncertainty
lat_str = st(8:15);
long_str = st(17:25);
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
elev = str2double(st(27:32)); % meters
elev_unc = 0.05;

mn.location = geoPoint2( lat, long, elev, precision, precision, elev_unc );
mn.time_zone = str2double( st(89:end) );
mn.site_flags(end+1) = siteFlags( 'US_HCN' );

mn.ids = ids;