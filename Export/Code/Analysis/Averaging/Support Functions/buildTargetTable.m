function [target_map, nearest] = buildTargetTable( locations, map, options )
% Helper function to determine the expected correlation between a set of
% numerical grid locations and the known network of stations.

temperatureGlobals;
session = sessionStart;

sessionSectionBegin( 'Build Target Map' );

% Data locations
targ_x = [locations(:).x];
targ_y = [locations(:).y];
targ_z = [locations(:).z];

% Locations for numerical integral grid
X = [map(:).x];
Y = [map(:).y];
Z = [map(:).z];

% Precomputed monthly covariance information.
p = options.CorrelationParameters;
maxd = options.CorrelationLimitDistance;

% Eliminate station locations with no usable data.
R = [targ_x' targ_y', targ_z'];

lenR = length(locations);

% Determining correlation relationships for numerical grid
target_map = zeros( length(X), lenR, 'single' );
parfor j = 1:length(X)
    dd = ((X(j) - R(:,1)).^2 + (Y(j) - R(:,2)).^2 + (Z(j) - R(:,3)).^2).^(1/2);
    template = dd.*0;
    f = ( dd <= maxd );
    template(f) = exp(polyval( p, dd(f) )');
    target_map(j,:) = template;
end

[~, nearest] = max( target_map, [], 1 );

sessionSectionEnd( 'Build Target Map' );
