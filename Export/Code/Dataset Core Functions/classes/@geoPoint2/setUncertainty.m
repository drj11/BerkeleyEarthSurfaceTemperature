function gp = setUncertainty( gp, lat_error, long_error, elev_error )
% Sets the uncertainty on a geoPoint.

if nargin < 3
    error( 'Need more arguments' );
end

lat_error = abs( lat_error );
long_error = abs( long_error );

if length(lat_error) == length(gp)
    for k = 1:length(gp)
        gp(k).lat_uncertainty = lat_error(k);
    end
elseif length(lat_error) == 1
    for k = 1:length(gp)
        gp(k).lat_uncertainty = lat_error;
    end
else
    error( 'Latitude error is wrong length' );
end

if length(long_error) == length(gp)
    for k = 1:length(gp)
        gp(k).long_uncertainty = long_error(k);
    end
elseif length(long_error) == 1
    for k = 1:length(gp)
        gp(k).long_uncertainty = long_error;
    end
else
    error( 'Longitude error is wrong length' );
end

if nargin > 3
    elev_error = abs( elev_error );
    if length(elev_error) == length(gp)
        for k = 1:length(gp)
            gp(k).elev_uncertainty = elev_error(k);
        end
    elseif length(elev_error) == 1
        for k = 1:length(gp)
            gp(k).elev_uncertainty = elev_error;
        end
    else
        error( 'Elevation error is wrong length' );
    end
end
