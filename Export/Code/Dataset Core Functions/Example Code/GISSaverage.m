function [times, result] = GISSaverage( se, locations )
% [times, global_average] = GISSaverage( stationElements, sites )
%
% Creates a GISS-like average of the data in "stationElements" at locations
% specified by "sites".  "Sites" may be of class stationSites or geoPoint.
%
% Currently only works with monthly time series.
% 
% Based on Hansen and Lebedeff 1987 and Hansen et al. 1999
%
% This function performs GISS style averaging only.  It does not reproduce 
% any of the homogenization routines used by GISS or their quality control.

% Convert locations to geoPoint format
if isa( locations, 'stationSite' ) || isa( locations, 'stationSite2' )
    locations = [locations(:).location];
end

% Create GISS grid
[LAT, LONG] = createGISSGrid();

map = geoPoint( LAT(:), LONG(:) );
weight = ones(length(map),1)*4*pi/length(map);  %Equal area by construction

% Data locations
X = [locations(:).x];
Y = [locations(:).y];
Z = [locations(:).z];

% Map locations
targX = [map(:).x];
targY = [map(:).y];
targZ = [map(:).z];

% Determine list of stations relevant to each map location

%%% Note: The current implementation uses secant distances rather than true
%%% spherical distances.  This introduces an error of up to 0.15% in the 
%%% distances.  This is assumed to be negligible.

target = cell(length(map),1);
for k = 1:length(map)
    dd = sqrt((targX(k) - X).^2 + (targY(k) - Y).^2 + (targZ(k) - Z).^2);
    f = find( dd < 1200 & ~isnan(dd) );
    target{k} = [f; dd(f)];
end

% Lookup Bad Flags
bf = getBadFlags();

% Find time range
[min_month, max_month] = monthRange( se );
times = double(min_month:max_month)/12 - 1/24 + 1600;

% Initialize variables to store north, south, and equatorial results. 
result_N = zeros( max_month - min_month + 1, 1 );
result_E = result_N;
result_S = result_N;
counts_N = result_N;
counts_E = result_N;
counts_S = result_N;

% Expand data and store in temporary variables.
time_v = cell(length(se),1);
data_v = cell(length(se),1);
for k = 1:length(se)
    monthnum = se(k).monthnum;
    data = se(k).data;
    exc = findFlags( se(k), bf );
    monthnum(exc) = [];
    data(exc) = [];
    
    if length(monthnum) >= 12*20    
        time_v{k} = monthnum;
        data_v{k} = data;
    else
        time_v{k} = [];
        data_v{k} = [];
    end
end

was_used = zeros( length(se), 1 );

% Performs averaging by looping over all map locations.
for k = 1:length(map)
    timePlot( 'GISS Average', k/length(map) );
    
    % Stations to use at map point k
    f_o = target{k}(1,:);
    
    % Station weight is proportional to distance, out to 1200 km.
    local_weight = target{k}(2,:) / 1200;
    
    current_data = data_v(f_o);
    current_time = time_v(f_o);
    
    % No records at map point, skip.
    if isempty( current_data )
        continue;
    end
    
    % Create arrays that are (num stations) x (num months) and populate
    usage_table = zeros( max_month - min_month + 1, length(f_o) );
    data_table = usage_table;
    for j = 1:length(f_o)
        usage_table( current_time{j} - min_month + 1, j ) = 1;
        data_table( current_time{j} - min_month + 1, j ) = current_data{j};
    end
    
    usage_table = logical( usage_table );
    
    % Record of which stations have been combined.
    used = zeros( length(current_data), 1 );
    
    % Length of each station record
    full_length_v = sum(usage_table);
    
    % Start analysis with longest record
    [~, index] = max( full_length_v );    
    used(index) = 1;
    current_was_used = was_used;
    current_was_used( f_o(index) ) = 1;
    
    % Temporary variables to store average for the current map
    temp_sum = result_N.*0;
    temp_count = temp_sum;
    
    temp_sum = data_table( :, index ) * local_weight(index);
    temp_count( usage_table( :, index ) ) = local_weight(index);
    
    current_estimate = result_N.*0;
    f2 = ( temp_count > 0 );
    current_estimate(f2) = temp_sum(f2) ./ temp_count(f2);
    
    % Find records that haven't been used yet.  GISS requires at least 20
    % years of overlap for a record to be included, exclude records shorter
    % than 20 years.
    
    f = find( used == 0 & full_length_v' >= 12*20 );
    if isempty(f)
        continue;
    end
    
    % Determine overlap between the current average and unused records.
    length_v = zeros(length(f),1);
    for j = 1:length(f)
        I2 = usage_table( :, f(j) ) & f2;
        length_v(j) = sum(I2);
    end        
    
    % Loop while there are still unused records with at least 20 years of
    % overlap with the current average.
    
    while min(used) == 0 && max(length_v) >= 12*20 
        
        % Find longest overlap
        [~,index] = max(length_v);
        
        % Store chosen record in temp variable
        new_estimate = result_N.*0;
        used(f(index)) = 1;
        current_was_used(f_o(f(index))) = 1;
        
        fx = usage_table( :, f(index) );
        new_estimate( fx ) = data_table( fx, f(index) );
        
        % Determine overlap interval
        I2 = fx & f2;
        
        % Adjust current record to have the same mean as the working averge
        % during the interval of overlap.
        
        new_estimate( fx ) = new_estimate( fx ) + ...
            mean( current_estimate( I2 ) ) - ...
            mean( new_estimate( I2 ) );
        
        % Add new record to working average.
        temp_sum( fx ) = temp_sum( fx ) + new_estimate( fx )*local_weight( f(index) );
        temp_count( fx ) = temp_count( fx ) + local_weight( f(index) );

        % Update working average.
        current_estimate = result_N.*0;
        f2 = ( temp_count > 0 );
        current_estimate(f2) = temp_sum(f2) ./ temp_count(f2);

        % Update length overlap information
        old_length_v = length_v( [1:index-1, index+1:end] );
        f = find( used == 0 & full_length_v' >= 12*20 );
        if isempty(f)
            break;
        end
        length_v = zeros(length(f),1);
        for j = 1:length(f)
            if full_length_v(f(j)) == old_length_v(j)
                length_v(j) = old_length_v(j);
            else                
                I2 = usage_table( :, f(j) ) & f2;
                length_v(j) = sum(I2);
            end            
        end
    end
        
    f2 = find( temp_count > 0 );
    if isempty(f2)
        continue;
    end
    
    % Update working average by dividing out weights.
    temp_sum(f2) = temp_sum(f2) ./ temp_count(f2);
    
    % Select baseline interval times >= 1951 and times < 1981.
    f3 = find( times >= 1951 & times < 1981 & temp_count' > 0 );
    if length(f3) < 12*20
        % It is unclear from the papers how complete the baseline interval
        % needs to be in order for a record to be used.  Does it may
        % require 100% occupancy?  Our working assumption is that the
        % minimum is 20 years, the same as the overlap calculation, but not
        % sure this is correct.
        continue;
    end
    
    % Adjust working average to have zero mean in the baseline interval
    temp_sum(f2) = temp_sum(f2) - mean(temp_sum(f3));
    
    % Track which stations were used.
    was_used = current_was_used;
    
    % Assign working average to appropriate band based on latitude
    if LAT(k) > 23.6
        result_N(f2) = result_N(f2) + temp_sum(f2)*weight( k );
        counts_N(f2) = counts_N(f2) + weight( k );
    elseif LAT(k) > -23.6
        result_E(f2) = result_E(f2) + temp_sum(f2)*weight( k );
        counts_E(f2) = counts_E(f2) + weight( k );
    else
        result_S(f2) = result_S(f2) + temp_sum(f2)*weight( k );
        counts_S(f2) = counts_S(f2) + weight( k );        
    end
end
timePlot( 'GISS Average', 1 );

disp(['  GISS Average: ' num2str(sum(was_used)) ' records used']);

% Compute averages for each band
f1 = ( counts_N > 0 );
result_N(f1) = result_N(f1) ./ counts_N(f1);

f2 = ( counts_S > 0 );
result_S(f2) = result_S(f2) ./ counts_S(f2);

f3 = ( counts_E > 0 );
result_E(f3) = result_E(f3) ./ counts_E(f3);

% Band weighting functions based on occupancy.
ww = f1*0.3 + f3*0.4 + f2*0.3;

% Compute and return band averages
f = (ww > 0);
result = (result_N.*0.3 + result_E.*0.4 + result_S*0.3);
result(f) = result(f) ./ ww(f);
f = (ww == 0);
result(f) = NaN;


