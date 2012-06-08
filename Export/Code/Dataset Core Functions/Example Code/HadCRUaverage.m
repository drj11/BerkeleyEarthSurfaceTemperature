function [times, result] = HadCRUaverage( se, locations )
% [times, global_average] = HadCRUaverage( stationElements, sites )
%
% Creates a HadCRU-like average of the data in "stationElements" at locations
% specified by "sites".  "Sites" may be of class stationSites or geoPoint.
%
% Currently only works with monthly time series.
% 
% Based on Brohan et al. 2006 and Jones and Moberg 2030
%
% This function performs HadCRU style averaging only.  It does not 
% reproduce  any of the homogenization routines used by HadCRU or their 
% quality control.

% Convert locations to geoPoint format
if isa( locations, 'stationSite' ) || isa( locations, 'stationSite2' )
    locations = [locations(:).location];
end

% Define 5 x 5 grid
lat = -87.5:5:87.5;
long = -177.5:5:177.5;

[LAT, LONG] = meshgrid(lat, long);

map = geoPoint( LAT(:), LONG(:) );

% Weight by map cell area
weight = cos( LAT(:)*pi/180 );

% Station record locations
X = [locations(:).x];
Y = [locations(:).y];
Z = [locations(:).z];

% Map locations
targX = [map(:).x];
targY = [map(:).y];
targZ = [map(:).z];

% Assign each record to its nearest grid cell.  Distances are calculated
% via secant rather than true spherical distance.  Error should be no more
% than 0.02% for the HadCRU grid.
target = zeros(length(se),1);
for k = 1:length(locations)
    if isnan(X(k))
        target(k) = NaN;
        continue;
    end
    dd = (targX - X(k)).^2 + (targY - Y(k)).^2 + (targZ - Z(k)).^2;
    [~,index] = min( dd );
    target(k) = index;
end

% Determine list of populated grid cells.
un = unique( target );
f = find(un == 0 | isnan(un));
un(f) = [];

% Get bad flags list
bf = getBadFlags();

% Get time range
[min_month, max_month] = monthRange( se );
times = double(min_month:max_month)/12 - 1/24 + 1600;

% Temporary variables to store northern and southern hemisphere
% temperature series.
result_NH = zeros( max_month - min_month + 1, 1 );
result_SH = result_NH;
counts_NH = result_NH;
counts_SH = result_NH;

% Keep track of which stations are used
was_used = 0;

% Loop over list of populated grid cells
for k = 1:length(un)
    f = find( target == un(k) );
    
    % Temporary variables to store average at current grid cell.
    temp_sum = result_NH.*0;
    temp_count = temp_sum;
    
    temp_sum_2 = result_NH.*0;
    temp_count_2 = temp_sum_2;
    
    adj_total = 0;
    adj_number = 0;
    provisional_used = 0;

    % Loop over station list at current grid point
    for m = 1:length(f)
        
        % Get data
        monthnum = se(f(m)).monthnum;
        dates = se(f(m)).dates;
        data = se(f(m)).data;
        exc = findFlags( se(f(m)), bf );
        monthnum(exc) = [];
        data(exc) = [];
        dates(exc) = [];
        
        % Determine amount of data in baseline intervals
        f3_1 = find( dates >= 1961 & dates < 1971 );
        f3_2 = find( dates >= 1971 & dates < 1981 );
        f3_3 = find( dates >= 1981 & dates < 1991 );
        f3 = union( union(f3_1, f3_2), f3_3);
        f4 = find( dates >= 1951 & dates < 1970 );
        
        good = 0;
        need_adj = 0;
        
        %%% NEEDS UPDATE %%%
        % This partially implements the Jones and Moberg 2003 averaging and
        % baseline criteria.  It should be updated to run the Brohan et al.
        % 2006 system.
        if length(f3_1) >= 12*4 && ...
                length(f3_2) >= 12*4 && ...
                length(f3_3) >= 12*4 && ...
                length(f3) >= 12*20
            data = data - mean(data(f3));
            temp_sum( monthnum - min_month + 1 ) = temp_sum( monthnum - min_month + 1) + data';
            temp_count( monthnum - min_month + 1 ) = temp_count( monthnum - min_month + 1) + 1;
            good = 1;
            was_used = was_used + 1;
        end
        if length(f4) >= 12*15
            if good
                adj_total = adj_total + mean(data(f4));
                adj_number = adj_number + 1;
            else
                data = data - mean(data(f4));
                temp_sum_2( monthnum - min_month + 1 ) = temp_sum_2( monthnum - min_month + 1) + data';
                temp_count_2( monthnum - min_month + 1 ) = temp_count_2( monthnum - min_month + 1) + 1;
                provisional_used = provisional_used + 1;
            end
        end
    end
    
    % Make adjustment based on alternative baseline interval.
    if adj_number > 0
        adjustment = adj_total / adj_number;
        fx = find( temp_count_2 > 0 );
        
        temp_sum_2(fx) = temp_sum_2(fx) - adjustment*temp_count_2(fx);
        temp_sum = temp_sum + temp_sum_2;
        temp_count = temp_count + temp_count_2;
        was_used = was_used + provisional_used;
    end
    
    % Determine temperature series at grid cell
    f2 = find( temp_count > 0 );
    temp_sum(f2) = temp_sum(f2) ./ temp_count(f2);
    
    % Populate north or south temperature series based on latitude and 
    % scaled by grid cell area.
    if ~isempty(f2)
        if LAT(un(k)) > 0
            result_NH(f2) = result_NH(f2) + temp_sum(f2)*weight( un(k) );
            counts_NH(f2) = counts_NH(f2) + weight( un(k) );
        else
            result_SH(f2) = result_SH(f2) + temp_sum(f2)*weight( un(k) );
            counts_SH(f2) = counts_SH(f2) + weight( un(k) );            
        end
    end
end

disp(['  HadCRU Average: ' num2str(was_used) ' records used']);

% Compute north and south averages
f = ( counts_NH > 0 );
result_NH(f) = result_NH(f) ./ counts_NH(f);

f = ( counts_SH > 0 );
result_SH(f) = result_SH(f) ./ counts_SH(f);

% Average north and south series.
f = ( (counts_NH > 0) & (counts_SH > 0) );
result(f) = ( result_NH(f) + result_SH(f) ) / 2;
f = ( (counts_NH > 0) & (counts_SH == 0) );
result(f) = ( result_NH(f) );
f = ( (counts_NH == 0) & (counts_SH > 0) );
result(f) = ( result_SH(f) );
f = ( (counts_NH == 0) & (counts_SH == 0) );
result(f) = NaN;