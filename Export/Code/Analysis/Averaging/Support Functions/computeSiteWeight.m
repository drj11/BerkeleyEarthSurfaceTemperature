function site_weight = computeSiteWeight( data_array, dates_array, ...
    t_res, b_res, new_spatial_table, map, near_index, first, ...
    sigma, sigma_full, options )

% Helper function used to determine the quality of fit for each station.

sessionSectionBegin( 'Compute Site Weight' );

if matlabPoolSize > 1
    spmd
        [A,B] = globalIndices( data_array, 1 );
        
        site_weight = reallyComputeSiteWeight( getLocalPart( data_array ), ...
            getLocalPart( dates_array ), ...
            t_res, b_res(A:B), getLocalPart( new_spatial_table ), ...
            map, near_index(A:B), first, sigma, sigma_full, options );       
       
        site_weight = gcat( site_weight, 1, 1 );
    end
    site_weight = site_weight{1};
else
    site_weight = reallyComputeSiteWeight( data_array, dates_array, ...
        t_res, b_res, new_spatial_table, map, near_index, first, ...
        sigma, sigma_full, options ); 
end

sessionSectionEnd( 'Compute Site Weight' );


function site_weight = reallyComputeSiteWeight( data_array, dates_array, ...
    t_res, b_res, new_spatial_table, map, near_index, first, ...
    sigma, sigma_full, options )

if options.UseSiteWeighting
    local_site_limit = options.SiteWeightingCutoffMultiplier;
    global_site_limit = options.SiteWeightingGlobalCutoffMultiplier;
end

temp_blocking_size = 2500;

len_s = length(data_array);
site_weight = zeros(len_s, 1);

% Loop over stations
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
    
    if ~first && options.UseSiteWeighting
        % Determine site weighting
        sp_weights = sp_weight_temp( mod( j-1, temp_blocking_size ) + 1, monthnum );
        
        if options.LocalMode
            % If local, adjust from local anomaly map.
            compare = map( near_index( j ), monthnum ) + t_res( monthnum )';
        else
            compare = t_res( monthnum )';
        end
        
        if options.LocalMode && options.SiteWeightingRemoveSelf
            % Approximately remove the impact of the current station, since
            % we don't want local matches to have high quality just because
            % a station is isolated.
            compare = compare - sp_weights.*( data' - b_res(j) - t_res( monthnum )' );
        end
        
        % Insert cutoffs to limit the degree that outlier points can
        % influence the site weight
        
        % Local outlier cutoff
        if local_site_limit < Inf && options.LocalMode
            f = find( ( data - compare' - b_res(j) ) > local_site_limit*sigma );
            data( f ) = local_site_limit*sigma + compare(f)' + b_res(j);
            f = find( ( data - compare' - b_res(j) ) < -local_site_limit*sigma );
            data( f ) = -local_site_limit*sigma + compare(f)' + b_res(j);
        end
        
        % Global outlier cutoff
        if global_site_limit < Inf
            f = find( ( data - t_res( monthnum ) - b_res(j) ) > global_site_limit*sigma_full );
            data( f ) = global_site_limit*sigma_full + t_res( monthnum(f) ) + b_res(j);
            f = find( ( data - t_res( monthnum ) - b_res(j) ) < -global_site_limit*sigma_full );
            data( f ) = -global_site_limit*sigma_full + t_res( monthnum(f) ) + b_res(j);
        end
        
        % RMS of fit for this station after outlier adjustments
        list_sum = sum((data - compare' - b_res(j)).^2);
        list_count = length( data );
        
        square_dev = list_sum / list_count; % RMS^2
        
        % Site weight calculation.  The expected mean is roughly, but
        % only approximately, one.  The sigma in the denominator
        % serves to avoid overweighting short records that may fit very
        % "well".
        sw = 2*sigma^2/(sigma^2 + square_dev);
    else
        sw = 1;
    end
    site_weight(j) = sw;
end
