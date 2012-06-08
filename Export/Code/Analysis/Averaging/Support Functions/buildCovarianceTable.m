function [weights, nugget] = buildCovarianceTable( locations, options )
% This helper function determines the pairwise covariance matrix between
% temperature stations.

temperatureGlobals;
session = sessionStart;

sessionSectionBegin( 'Build Covariance Table' );

% Precomputed monthly covariance information.
p = options.CorrelationParameters;
maxd = options.CorrelationLimitDistance;

% Data locations
targ_x = [locations(:).x];
targ_y = [locations(:).y];
targ_z = [locations(:).z];

% Eliminate station locations with no usable data.
R = [targ_x' targ_y', targ_z'];

lenR = length(R(:,1));

% Estimated pairwise station covariance matrix
weights = zeros(lenR, 'single');
for j = 1:lenR
    % Determine separation distance
    weights(:,j) = ((R(j,1) - R(:,1)).^2 + (R(j,2) - R(:,2)).^2 + (R(j,3) - R(:,3)).^2).^(1/2);
    f = ( weights(:,j) <= maxd );
    % Map distances to covariance model
    weights(f,j) = exp(polyval( p, weights(f,j) ));
    f = ( weights(:,j) > maxd );
    weights(f,j) = 0;
end

% Nugget for same site at zero distance
nugget = 1 - exp(polyval(p,0));

sessionSectionEnd( 'Build Covariance Table' );
