function [times, temps] = getLocalTemperatureSeries( results, location, months )
% [times, temps] = getLocalTemperatureSeries( results, location, months )
%
% Retrieves the temperature time series for the point closest to
% "location" while applying a "months" moving average ( defaults to 1
% month ).  

if ~isfield( results, 'map' )
    error( 'Local results data not available in results structure' );
end

if nargin < 3
    months = 1;
end

pos = nearest( location, results.map_pts );

times1 = results.times_monthly;
values = results.values_monthly' + results.map(pos,:) + results.base_map(pos);
coverage = results.coverage_map(pos,:);

[times, temps] = simpleMovingAverage( times1, values, months );
[~, coverage] = simpleMovingAverage( times1, coverage, months );

f = (coverage < 0.2);

temps( f ) = NaN;
f2 = find(~isnan(temps));

select = f2(1):f2(end);
temps = temps(select);
times = times(select);

