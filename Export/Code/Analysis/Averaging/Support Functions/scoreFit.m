function [ssd, base_adjustment_scale, data_points] = scoreFit( data_array, ...
    dates_array, t_res, b_res, new_spatial_table, map, ...
    near_index, first, sigma, sigma_full, options )
% Scores the quality of the fit.

if matlabPoolSize > 1
    spmd        
        [A, B] = globalIndices( data_array, 1 );
        [ssd, base_adjustment_scale, data_points] = ...
            reallyScoreFit( getLocalPart( data_array ), ...
                getLocalPart( dates_array ), t_res, ...
                b_res(A:B), getLocalPart( new_spatial_table ), map, ...
                near_index(A:B), first, sigma, sigma_full, options );
        
        ssd = gplus( ssd, 1 );
        base_adjustment_scale = gcat( base_adjustment_scale, 1, 1 );
        data_points = gplus( data_points, 1 );
    end 
    ssd = ssd{1};
    base_adjustment_scale = base_adjustment_scale{1};
    data_points = data_points{1};
else
    [ssd, base_adjustment_scale, data_points] = reallyScoreFit( data_array, ...
    dates_array, t_res, b_res, new_spatial_table, map, ...
    near_index, first, sigma, sigma_full, options );
end


function [ssd, base_adjustment_scale, data_points] = reallyScoreFit( data_array, ...
    dates_array, t_res, b_res, new_spatial_table, map, ...
    near_index, first, sigma, sigma_full, options )

if options.UseIterativeReweighting && options.UseOutlierWeighting
    local_outlier_limit = options.OutlierWeightingCutoffMultiplier;
    global_outlier_limit = options.OutlierWeightingGlobalCutoffMultiplier;
else
    local_outlier_limit = Inf;
    global_outlier_limit = Inf;
end

ssd = 0;
data_points = 0;
bs = b_res; % baselines

base_adjustment_scale = zeros( length(b_res), 2);

len_s = length(data_array);

temp_blocking_size = 2500;

for j = 1:len_s
    if mod( j, temp_blocking_size ) == 1
        sp_weight_temp = full( new_spatial_table( j:min(j+temp_blocking_size, end), : ) );
    end
    if ~first && isnan( bs(j) )
        continue;
    end
    
    % Load data from station
    monthnum = dates_array{j};
    data = data_array{j};

    fs = isnan( t_res( monthnum ) );
    monthnum(fs) = [];
    data(fs) = [];
    if isempty( monthnum ) 
        continue;
    end
        
    if ~first && options.UseOutlierWeighting
        % Perform outlier adjustments
        
        sp_weights = sp_weight_temp( mod( j-1, temp_blocking_size ) + 1, monthnum );
        
        if options.LocalMode
            compare = map( near_index( j ), monthnum )' + t_res( monthnum );
        else
            compare = t_res( monthnum );
        end
        
        if options.OutlierWeightingRemoveSelf && options.LocalMode
            % Approximately remove the impact of the current station, since
            % we don't want local matches to have high quality just because
            % a station is isolated.
            compare = compare - sp_weights.*( data' - bs(j) - t_res( monthnum )' );
        end
        
        % Introduce cutoffs to reduce the impact of outliers.
        if local_outlier_limit < Inf && options.LocalMode
            f = find( ( data - compare - bs(j) ) > local_outlier_limit*sigma );
            data( f ) = local_outlier_limit*sigma + compare(f) + bs(j);
            f = find( ( data - compare - bs(j) ) < -local_outlier_limit*sigma );
            data( f ) = -local_outlier_limit*sigma + compare(f) + bs(j);
        end
        
        if global_outlier_limit < Inf
            f = find( ( data - t_res( monthnum ) - bs(j) ) > global_outlier_limit*sigma_full );
            data( f ) = global_outlier_limit*sigma_full + t_res( monthnum(f) ) + bs(j);
            f = find( ( data - t_res( monthnum ) - bs(j) ) < -global_outlier_limit*sigma_full );
            data( f ) = -global_outlier_limit*sigma_full + t_res( monthnum(f) ) + bs(j);
        end
    end
    
    local_table = data;
    if ~first && options.LocalMode
        % Improve parameter fit by reducing data by the local anomaly field.
        compare = map( near_index( j ), monthnum );
        local_table = data - compare';
    end
    
    % Add entries corresponding to
    % (spatial correlation_table)*(data(t, x) - baseline(x) - mean_temp(t))
    
    s = sp_weight_temp( mod( j-1, temp_blocking_size ) + 1, monthnum );
    d = local_table' - b_res(j) - t_res( monthnum )';
    
    ssd = ssd + sum( s.*(d.^2) );
    
    base_adjustment_scale( j, 1 ) = -2*sum( s.*d );
    base_adjustment_scale( j, 2 ) = sum( s );
    
    data_points = data_points + length(data);
end
