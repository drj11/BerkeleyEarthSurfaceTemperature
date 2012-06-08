function [val, varargout] = subsref( ss, S )
% SUBSREF Get properties of the station manifest
% and return the value

if strcmp(S(1).type, '.')
    if nargout > 1 && length(ss) > 1
        error( ['Forbidden syntax: Use "class(:).field" when accessing all' ...
            ' elements of a class array.'] );
    end
    if length(S) > 1
        error( 'Chain subreferences not supported.' );
    end        
    switch lower( S(1).subs )
        case { 'ids' }
            val = {ss.ids};
            if length(ss) == 1
                val = val{1};
            end
        case { 'ghcnm_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'ghcnm');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'ghcnd_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'ghcnd');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'wwr_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'wwr');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'coop_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                v = findID(ss(k), 'coop');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
           end
            if length(ss) == 1
                val = val{1};
            end
        case { 'gsod_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'gsod');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'wmssc_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'wmssc');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'ca_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'ca');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'wmo_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                v = findID(ss(k), 'wmo');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'wban_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                v = findID(ss(k), 'wban');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'icao_id' }
            val = cell( length(ss), 1 );
            for k = 1:length(ss)
                val{k} = findID(ss(k), 'icao');
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'country' }
            persistent country_names_dictionary;
            if isempty(country_names_dictionary)
                [~, country_names_dictionary] = loadCountryCodes();
            end

            for k = 1:length(ss)
                if length(ss(k).country) > 1
                    val{k} = '[Conflict]';
                else
                    try
                        val{k} = country_names_dictionary(ss(k).country);
                    catch
                        val{k} = '[Missing]';
                    end
                end
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'country_code' }
            val = [ss.country];
            if length(ss) == 1
                val = val(1);
            end
        case { 'source', 'sources' }
            val = {ss.sources};
            if length(ss) == 1
                val = val{1};
            end
        case { 'source_code' }
            val = {ss.sources};
            if length(ss) == 1
                val = val{1};
            end
        case { 'hash' }
            val = [ss(:).hash];
            if length(ss) == 1
                val = val(1);
            end
        case { 'county' }
            val = {ss.county};
            if length(ss) == 1
                val = val{1};
            end
        case { 'state' }
            val = {ss.state};
            if length(ss) == 1
                val = val{1};
            end
        case { 'timezone', 'time_zone' }
            val = [ss.time_zone];
            if length(ss) == 1
                val = val(1);
            end
        case { 'name', 'primary_name' }
            val = {ss.primary_name};
            if length(ss) == 1
                val = val{1};
            end
        case { 'alt_names' }
            val = {ss.alt_names};
            if length(ss) == 1
                val = val{1};
            end
        case { 'relocated' }
            val = {ss.relocated};
            if length(ss) == 1
                val = val{1};
            end
        case { 'possible_relocated' }
            val = {ss.possible_relocated};
            if length(ss) == 1
                val = val{1};
            end
        case { 'elevation', 'elev', 'height' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                val(k) = ss(k).location.elevation;
            end
        case { 'elevation_uncertainty', 'elev_unc', 'height_unc' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                val(k) = ss(k).location.elevation_uncertainty;
            end
        case { 'location' }           
            val = [ss.location];
        case { 'all_location', 'all_locations' }           
            val = {ss.all_locations};
            if length(ss) == 1
                val = val{1};
            end
        case { 'all_location_times', 'all_locations_times', 'all_locations_time', 'all_location_time' }           
            val = {ss.all_location_times};
            if length(ss) == 1
                val = val{1};
            end
        case { 'latitude', 'lat' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                if isa( ss(k).location, 'geoPoint2' )
                    val(k) = ss(k).location.latitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'longitude', 'long' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                if isa( ss(k).location, 'geoPoint2' )
                    val(k) = ss(k).location.longitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'latitude_uncertainty', 'latitude_unc', ...
                'lat_uncertainty', 'lat_unc' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                if isa( ss(k).location, 'geoPoint2' )
                    val(k) = ss(k).location.latitude_uncertainty;
                else
                    val(k) = NaN;
                end
            end
        case { 'longitude_uncertainty', 'longitude_unc', ...
                'long_uncertainty', 'long_unc' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                if isa( ss(k).location, 'geoPoint2' )
                    val(k) = ss(k).location.longitude_uncertainty;
                else
                    val(k) = NaN;
                end
            end
        case { 'flags' }
            val = {ss.flags};
            if length(ss) == 1
                val = val{1};
            end
        case { 'primary_manifests', 'primary_manifest' }
            val = {ss.primary_manifests};
            if length(ss) == 1
                val = val{1};
            end
        case { 'secondary_manifests', 'secondary_manifest' }
            val = {ss.secondary_manifests};
            if length(ss) == 1
                val = val{1};
            end
        case { 'archive', 'archive_keys', 'keys' }
            val = {ss.archive_keys};
            if length(ss) == 1
                val = val{1};
            end
        otherwise
            error( 'Unknown StationSite property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( ss( S(1).subs{:} ), S(2:end) );
    else
        val = ss( S(1).subs{:} );
    end
else
    error( 'Cell array of stationSite not supported' );
end




function v = findID( ss, kind )

kind = lower(kind);
kind = [kind '_'];
mx = length(kind);

v = {};

for k = 1:length(ss.ids)
    if length(ss.ids{k}) > mx && strcmp(ss.ids{k}(1:mx), kind)
        v{end+1} = ss.ids{k}(mx+1:end);
    end
end