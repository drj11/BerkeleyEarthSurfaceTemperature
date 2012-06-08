function [val, varargout] = subsref( mn, S )
% SUBSREF Get properties of the station manifest
% and return the value

if strcmp(S(1).type, '.')
    if nargout > 1 && length(mn) > 1
        error( ['Forbidden syntax: Use "class(:).field" when accessing all' ...
            ' elements of a class array.'] );
    end
    if length(S) > 1
        error( 'Chain subreferences not supported.' );
    end        
    switch lower( S(1).subs )
        case { 'ncdc_id', 'ncdc' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'ncdc');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'usaf_id', 'usaf' }
            for k = 1:length(mn)
                v = findID(mn(k), 'usaf');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'uid_id', 'uid' }
            for k = 1:length(mn)
                v = findID(mn(k), 'uid');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'other_id' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'other');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'wmssc' }
            for k = 1:length(mn)
                v = findID(mn(k), 'wmssc');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'ids' }
            val = {mn.ids};
            if length(mn) == 1
                val = val{1};
            end
        case { 'file', 'filename', 'file_name' }
            error( 'Don''t use this' );
            val = fileName( mn );
        case { 'coop_id', 'coop' }
            for k = 1:length(mn)
                v = findID(mn(k), 'coop');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'climate', 'climate_division' }
            val = [mn.climate_division];
        case { 'wban_id', 'wban' }
            for k = 1:length(mn)
                v = findID(mn(k), 'wban');
                v2 = zeros(length(v),1);
                for j = 1:length(v)
                    v2(j) = str2double(v{j});
                end
                val{k} = v2;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'ghcn_id', 'ghcn' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'ghcn');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'wmo_id', 'wmo' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'wmo');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'faa_id', 'faa' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'faa');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'nws_id', 'nws' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'nws');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'icao_id', 'icao' }
            for k = 1:length(mn)
                val{k} = findID(mn(k), 'icao');
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'country' }
            persistent country_names_dictionary;
            if isempty(country_names_dictionary)
                [~, country_names_dictionary] = loadCountryCodes();
            end

            for k = 1:length(mn)
                try
                    val{k} = country_names_dictionary(mn(k).country);
                catch
                    val{k} = '[Missing]';
                end
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'country_code' }
            val = [mn.country];
        case { 'source' }            
            val = cell(length(mn),1);
            last = -1;
            for k = 1:length(mn)
                if mn(k).source == last
                    val{k} = val{k-1};
                else
                    val{k} = stationSourceType(mn(k).source);
                end
                last = mn(k).source;
            end
            if length(mn) == 1
                val = val{1};
            end
        case { 'source_code' }
            val = [mn.source];
        case { 'county' }
            val = {mn.county};
            if length(mn) == 1
                val = val{1};
            end
        case { 'state' }
            val = {mn.state};
            if length(mn) == 1
                val = val{1};
            end
        case { 'timezone', 'time_zone' }
            val = [mn.time_zone];
            if length(mn) == 1
                val = val{1};
            end
        case { 'name' }
            val = {mn.name};
            if length(mn) == 1
                val = val{1};
            end
        case { 'elevation', 'elev', 'height' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if isa( mn(k).location, 'geoPoint2' )
                    val(k) = mn(k).location.elevation;
                    if isnan(val(k))
                        val(k) = mn(k).alt_elevation;
                    end
                else
                    val(k) = mn(k).alt_elevation;
                end               
            end
        case { 'alt_elevation', 'alt_elev' }
            val = [mn.alt_elevation];
        case { 'location' }           
            val = [mn.location];
        case { 'latitude', 'lat' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if isa( mn(k).location, 'geoPoint2' )
                    val(k) = mn(k).location.latitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'longitude', 'long' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if isa( mn(k).location, 'geoPoint2' )
                    val(k) = mn(k).location.longitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'duration', 'length' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if ~isnan(mn(k).duration)
                    val(k) = mn(k).duration.length;
                else
                    val(k) = NaN;
                end
            end
        case { 'time_range', 'range', 'timerange' }
            val(1:length(mn)) = timeRange();
            persistent bad_val;
            
            for k = 1:length(mn)
                if ~isnan( mn(k).duration )
                    val(k) = mn(k).duration;    
                else
                    if isempty( bad_val )
                        bad_val = timeRange( timeInstant( NaN ), timeInstant( 2500, 1, 1 ) );
                    end
                    val(k) = bad_val;
                end
            end
        case { 'start', 'first', 'start_date' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if ~isnan(mn(k).duration) && length(mn(k).duration.start) == 1
                    val(k) = mn(k).duration.start;
                else
                    val(k) = NaN;
                end
            end
        case { 'last', 'end', 'end_date', 'stop' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if ~isnan(mn(k).duration) && length(mn(k).duration.last) == 1
                    val(k) = mn(k).duration.last;
                else
                    val(k) = NaN;
                end
            end
        case { 'start_instant', 'first_instant' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if ~isnan(mn(k).duration)
                    val(k) = mn(k).duration.first_instant;
                else
                    val(k) = NaN;
                end
            end
        case { 'last_instant', 'end_instant' }
            val = zeros(length(mn),1);
            for k = 1:length(mn)
                if ~isnan(mn(k).duration)
                    val(k) = mn(k).duration.last_instant;
                else
                    val(k) = NaN;
                end
            end
        case { 'site_flags', 'flags' }
            val = {mn.site_flags};
            if length(mn) == 1
                val = val{1};
            end
        case { 'relocated' }
            val = zeros(length(mn),1);
            for j = 1:length(mn)
                val(j) = ~isempty(mn(j).reloc) && ~isnan(mn(j).reloc);
            end
        case { 'relocation' }
            val = {mn.reloc};
            if length(mn) == 1
                val = val{1};
            end
        case { 'archive_key', 'archive' }
            val = {mn.archive_key};
            if length(mn) == 1
                val = val{1};
            end
        case { 'access_key', 'key' }
            val = cell( length( mn), 1 );
            for j = 1:length(mn)
                range_str = '';
                if ~isnan( mn(j).duration )
                    tr = mn(j).duration;    

                    if ~isnan( tr.first ) || ~isnan( tr.last ) 
                        range_str = [num2str( tr.first ) ' - ' num2str( tr.last )];
                    end
                end
                if ~strcmp( range_str, '' )
                    val{j} = [mn(j).archive_key ' : ' range_str];
                else
                    val{j} = [mn(j).archive_key];
                end   
            end
            if length(mn) == 1
                val = val{1};
            end
        otherwise
            error( 'Unknown StationManifest property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( mn( S(1).subs{:} ), S(2:end) );
    else
        val = mn( S(1).subs{:} );
    end
else
    error( 'Cell array of stationManifest not supported' );
end


function v = findID( mn, kind )

kind = lower(kind);
kind = [kind '_'];
mx = length(kind);

v = {};

for k = 1:length(mn.ids)
    if length(mn.ids{k}) > mx && strcmp(mn.ids{k}(1:mx), kind)
        v{end+1} = mn.ids{k}(mx+1:end);
    end
end


function v = fileName( mn )

switch mn.source
    case sourceType('GHCND')
        id = findID( mn, 'ghcn' );
        id = id{1};
        
        v = ['ghcn_' id];
    case sourceType('GSOD')
        id = '';
        id1 = findID( mn, 'wban' );
        if ~isempty(id1)
            id = ['wban_' id1{1}];
        end
        
        id2 = findID( mn, 'usaf' );
        if ~isempty(id2)
            if ~isempty(id)
                id = [id '_'];
            end
            id = [id 'usaf_' id2{1}];
        end
        v = id;
    case sourceType('USSOD')
        id = findID( mn, 'wban' );
        if isempty(id)
            id = findID( mn, 'coop' );
            id = id{1};
            v = ['coop_' id];
        else
            id = id{1};
            v = ['wban_' id];
        end
    otherwise
        error( 'Unknown Source' );
end