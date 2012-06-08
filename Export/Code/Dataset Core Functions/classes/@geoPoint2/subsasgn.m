function pts = subsasgn( pt, S, values )
% SUBASGN Set properties of the point
% and return the value

pts = pt;

if strcmp(S(1).type, '.')
    if length(pt) > 1
        for k = 1:length(pt)
            if length(values) == 1
                pts(k) = subsasgn( pts(k), S, values);
            elseif length(values) == length(pts)
                pts(k) = subsasgn( pts(k), S, values(k));
            else
                error( 'Number of values does not match number of indexes.');
            end
        end
    else
        switch lower( S(1).subs )
            case { 'latitude', 'lat' }
                pts.latitude = values;
            case { 'longitude', 'long' }
                pts.longitude = values;
            case { 'elevation', 'elev', 'height' }
                pts.elevation = values;
            case { 'latitude_error', 'lat_error' }
                pts.lat_uncertainty = values;
            case { 'longitude_error', 'long_error' }
                pts.long_uncertainty = values;
            case { 'elevation_error', 'elev_error', 'height_error' }
                pts.elev_uncertainty = values;
            otherwise
                error( 'Unknown GeoPoint property' );
        end
        pts = computeXYZ(pts);
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        pts( S(1).subs{:} ) = subsasgn( pt( S(1).subs{:} ), S(2:end), values );
    else
        pts( S(1).subs{:} ) = values;
    end
else
    error( 'Cell array of geoPoint not supported' );
end
