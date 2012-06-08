function val = subsref( pt, S )
% SUBSREF Get properties of the point
% and return the value

if strcmp(S(1).type, '.')
    switch lower( S(1).subs )
        case { 'latitude', 'lat' }
            val = [pt.latitude];
        case { 'longitude', 'long' }
            val = [pt.longitude];
        case { 'elevation', 'elev', 'height' }
            val = [pt.elevation];
        case { 'x' }
            val = [pt.x];
        case { 'y' }
            val = [pt.y];
        case { 'z' }
            val = [pt.z];
        otherwise
            error( 'Unknown GeoPoint property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( pt( S(1).subs{:} ), S(2:end) );
    else
        val = pt( S(1).subs{:} );
    end
else
    error( 'Cell array of geoPoint not supported' );
end
