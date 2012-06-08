function result = checkConsistency( gp )
% Determines if a set of geoPoints are mutually consistent.

lat = [gp.latitude];
long = [gp.longitude];
f = ( isnan( lat ) | isnan( long ) );
gp(f) = [];

if length( gp ) == 0
    result = 1;
    return;
end
if length( gp ) <= 1
    result = 1;
    return;
end

lat = [gp.latitude]';
long = [gp.longitude]';
elev = [gp.elevation]';

lat_error = [gp.lat_uncertainty]';
long_error = [gp.long_uncertainty]';
elev_error = [gp.elev_uncertainty]';

if any( isnan(lat) | isnan(long) )
    error( 'Location data is not set' );
end

if any( isnan(lat_error) | isnan(long_error) )
    error( 'Location uncertainty is not set' );
end

if min( long - long_error ) < -180
    offset = 180;
elseif max( long + long_error ) > 180
    offset = -180;
else
    offset = 0;
end

lat_bands = [lat - lat_error, lat + lat_error];
long_bands = [long - long_error + offset, long + long_error + offset];

lat_range = [max(lat_bands(:,1)), min(lat_bands(:,2))];
long_range = [max(long_bands(:,1)), min(long_bands(:,2))];

if lat_range(1) <= lat_range(2) && long_range(1) <= long_range(2)
    result = 1;
else
    result = 0;
end
    
