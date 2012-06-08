function [base_weights, base_constants, temperature_map, ...
    temperature_constant, record_weight] = ...
    buildMatrices( data_array, dates_array, new_spatial_table, map, near_index, ...
    t_res, b_res, sigma, sigma_full, first, options )
% Builds the matrix equations required for solving the whole problem

sessionSectionBegin( 'Build Matrices' );

if matlabPoolSize > 1    
    spmd
        [A,B] = globalIndices( data_array, 1 );
        
        [base_weights, base_constants, temperature_map, ...
            temperature_constant, record_weight] = reallyBuildMatrices( ...
            getLocalPart( data_array ), getLocalPart( dates_array ), ...
            getLocalPart( new_spatial_table ), map, near_index(A:B), ...
            t_res, b_res(A:B), sigma, sigma_full, first, options );
        
        base_weights = gcat( base_weights, 1, 1 );
        base_constants = gcat( base_constants, 1, 1 );
        record_weight = gcat( record_weight, 1, 1 );        
    end
    
    base_weights = base_weights{1};
    base_constants = base_constants{1};
    temperature_map = fastSum( temperature_map );
    temperature_constant = fastSum( temperature_constant );
    record_weight = record_weight{1};
else
    [base_weights, base_constants, temperature_map, ...
        temperature_constant, record_weight] = reallyBuildMatrices( ...
        data_array, dates_array, new_spatial_table, map, near_index, ...
        t_res, b_res, sigma, sigma_full, first, options );
end

sessionSectionEnd( 'Build Matrices' );


function [base_weights, base_constants, temperature_map, ...
    temperature_constant, record_weight] = reallyBuildMatrices( ...
    data_array, dates_array, new_spatial_table, map, near_index, ...
    t_res, b_res, sigma, sigma_full, first, options )
% Helper function used to efficiently divide the solution into parallel
% work blocks for parallel processing.

if options.UseIterativeReweighting
    if options.UseOutlierWeighting
        local_outlier_limit = options.OutlierWeightingCutoffMultiplier;
        global_outlier_limit = options.OutlierWeightingGlobalCutoffMultiplier;
    end
end

sz = size( new_spatial_table );
len_t = sz(2);
len_s = sz(1);

% Perpare matrix equation data holders
base_weights = zeros( len_s, 1, 'double' );
base_constants = zeros( len_s, 1, 'double' );

temperature_map = zeros( len_t, len_t, 'double' );
temperature_constant = zeros( len_t, 1, 'double' );

diagonal_template = diagonalIndices( len_t ); 

% Loop over stations

record_weight = zeros( len_s, 1 );

temp_blocking_size = 2500;

for j = 1:len_s
    if mod( j, temp_blocking_size ) == 1
        sp_weight_temp = full( new_spatial_table( j:min(j+temp_blocking_size, end), : ) );
    end
    
    if ~first && isnan( b_res(j) )
        continue;
    end
    
    % Load data from station
    monthnum = dates_array{j};
    data = data_array{j};
    
    if ~first
        fs = isnan( t_res( monthnum ) );
        monthnum(fs) = [];
        data(fs) = [];
        if isempty( monthnum )
            continue;
        end
    end
    
    outlier_weight = ones( size( data ) );
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
            compare = compare - sp_weights.*( data - b_res(j) - t_res( monthnum ) );
        end
        
        % Introduce cutoffs to reduce the impact of outliers.
        if local_outlier_limit < Inf && options.LocalMode
            f = find( ( data - compare - b_res(j) ) > local_outlier_limit*sigma );
            outlier_weight( f ) = local_outlier_limit*sigma ./ ( data( f ) - compare(f) - b_res(j) );
            data( f ) = local_outlier_limit*sigma + compare(f) + b_res(j);
            f = find( ( data - compare - b_res(j) ) < -local_outlier_limit*sigma );
            outlier_weight( f ) = -local_outlier_limit*sigma ./ ( data( f ) - compare(f) - b_res(j) );
            data( f ) = -local_outlier_limit*sigma + compare(f) + b_res(j);
        end
        
        if global_outlier_limit < Inf
            f = find( ( data - t_res( monthnum ) - b_res(j) ) > global_outlier_limit*sigma_full );
            outlier_weight( f ) = global_outlier_limit*sigma_full ./ ( data( f ) - t_res( monthnum(f) ) - b_res(j) );
            data( f ) = global_outlier_limit*sigma_full + t_res( monthnum(f) ) + b_res(j);
            f = find( ( data - t_res( monthnum ) - b_res(j) ) < -global_outlier_limit*sigma_full );
            outlier_weight( f ) = -global_outlier_limit*sigma_full ./ ( data( f ) - t_res( monthnum(f) ) - b_res(j) );
            data( f ) = -global_outlier_limit*sigma_full + t_res( monthnum(f) ) + b_res(j);
        end
    end
    
    if ~first && options.LocalMode
        % Improve parameter fit by reducing data by the local anomaly field.
        compare = map( near_index( j ), monthnum )';
        local_table = data - compare;
    else
        local_table = data;
    end
    
    % Add entries corresponding to
    % (spatial correlation_table)*(data(t, x) - baseline(x) - mean_temp(t))
    
    s = sp_weight_temp( mod( j-1, temp_blocking_size ) + 1, monthnum );
    record_weight(j) = sum( abs(s)*outlier_weight );
    
    base_weights( j ) = base_weights( j ) + length( s );
    base_constants( j ) = base_constants( j ) + sum( local_table );
    
    temperature_map( diagonal_template( monthnum ) ) = temperature_map( diagonal_template( monthnum ) ) + s;
    temperature_constant( monthnum ) = temperature_constant( monthnum ) + ( s'.*data );
end
