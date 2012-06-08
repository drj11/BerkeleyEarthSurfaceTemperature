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
        case { 'uids', 'uid' }
            val = {ss.associated_uids};
            if length(ss) == 1
                val = val{1};
            end
        case { 'ids', 'other_ids' }
            val = {ss.other_ids};
            if length(ss) == 1
                val = val{1};
            end
        case { 'id' }
            val = [ss.id];
        case { 'country' }
            global country_names_dictionary;

            if isempty(country_names_dictionary)
                loadCountryCodes();
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
        case { 'source' }
            val = {ss.sources};
            if length(ss) == 1
                val = val{1};
            end
        case { 'source_code' }
            val = {ss.sources};
            if length(ss) == 1
                val = val{1};
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
                val = val{1};
            end
        case { 'name' }
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
                if isa( ss(k).location, 'geoPoint' )
                    val(k) = ss(k).location.latitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'longitude', 'long' }
            val = zeros(length(ss),1);
            for k = 1:length(ss)
                if isa( ss(k).location, 'geoPoint' )
                    val(k) = ss(k).location.longitude;
                else
                    val(k) = NaN;
                end
            end
        case { 'flags' }
            val = {ss.flags};
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

