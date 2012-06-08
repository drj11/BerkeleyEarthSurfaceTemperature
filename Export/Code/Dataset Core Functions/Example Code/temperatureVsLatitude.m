% This script generates a plot of the average station temperature as a
% function of latitude.

% Load the 2% sample monthly average values with seasonality removed
[se, sites] = loadTemperatureData( '2% Sample', 'Detrended', 'Monthly', 'TAVG' );

% List of latitudes
lat = [sites(:).lat];

% Lookup bad flags
bf = getBadFlags();

% Calculate mean values
mean_values = zeros( length(se), 1 );
for k = 1:length(se)
    [dates, data] = getData( se(k), bf );
    mean_values(k) = mean(data);
end

%Create figure
figure
plot( lat, mean_values, '.' );

set( gca, 'xlim', [-90, 90], 'ylim', [-60,40] );
title( 'Mean Temperature vs. Latitude' );
xlabel( 'Latitude (Positive is North)' );
ylabel( 'Annual Mean Temperature (C)' );