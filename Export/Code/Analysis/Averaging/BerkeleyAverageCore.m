function results = BerkeleyAverageCore( se, locations, options )
% results = BerkeleyAverageCore( se, sites, options )
%
% Actually performs the Berkeley Average.  This function is not generally
% intended to be called directly, rather users are encouraged to use the
% function BerkeleyAverage.
%
% Currently only works with monthly time series.
%
% This function performs averaging only.  It does not do any
% homogenization or quality control.

% Check parent function for unexpected direct calls.
name = parentFunction();
if ~strcmp( name, 'BerkeleyAverage' ) && ...
        ~strcmp( name, 'computeStatisticalUncertainty' )
    warning( 'BerkeleyAverageCore:Direct', ...
        ['BerkeleyAverageCore was called directly.  It is recommended to use ' ...
        'BerkeleyAverage instead.'] );
end

temperatureGlobals;
session = sessionStart;

% Check that data has the right form
if ~all( isMonthly( se ) )
    error( 'Only monthly time series are supported' );
end
if any( isMultiValued( se ) )
    error( 'Only single-valued time series are supported' );
end

% Determine which options are meaningful and which are superfluous in this
% context.
[options_hash, options] = getOptionsHash( options );

frc = sessionFunctionCache;
cache_hash = collapse( [ collapse( md5hash( se ) ), collapse( md5hash( locations ) ), ...
   options_hash] );

% Check for previously cached result on the same data and same options.  If
% it exists, retrieve from disk and return immediately.
result = get( frc, cache_hash );
if ~isempty( result )
    results = result;
    return;
end

% Load various options into local variables for easier access.
min_stations = options.MinStations;
min_months = options.MinMonths; 

if options.UseIterativeReweighting
    precision_target = options.PrecisionTarget;
    max_loop = options.MaxIterations;
else
    max_loop = 1;
end

if options.UseSeed
    f = isnan( options.SeedMonthlyValues ) | isnan( options.SeedMonthlyTimes );
    options.SeedMonthlyTimes(f) = [];
    options.SeedMonthlyValues(f) = [];
end

sessionSectionBegin( 'Berkeley Average Core Process' );

% Convert locations to geoPoint format
if isa( locations, 'stationSite' ) || isa( locations, 'stationSite2' )
    hashes = md5hash( locations );
    locations = [locations(:).location];
else
    hashes = md5hash;
    hashes( 1:length(locations) ) = md5hash;
    parfor k = 1:length( locations )
        hashes( k ) = md5hash( locations(k) );
    end
end

% Time range for station data
[min_month, max_month] = monthRange( se );
time_values = double(min_month:max_month)/12 - 1/24 + 1600;

% Get bad flag list
bf = options.BadFlags;

% Remove any data points that are flagged with indicators of the "bad flags
% list".  These points are not considered at all doing the averaging
% proccess.
parfor k = 1:length(se);
    exc = findFlags( se(k), bf );
    I = 1:numItems( se(k) );
    I(exc) = [];
    if ~isempty( exc )
        se(k) = compress( select( se(k), I ) );
    end
end

orig_length = length(se);
orig_map = true( length(se), 1 );

% Remove stations with no location
f = isnan( locations(:).x );
orig_map(f) = false;


%%%%%%%%
% Temporary Fix: Remove ultra-high variability created by bad seasonality
% procedure on sparse data.  This will be removed in the future versions
% when the seasonality procedure is fixed.
parfor k = 1:length(se)
    data = se(k).data;
    if std(data) > 7
        orig_map(k) = false;
    end
end     
%%%%%%%%    


% Create a table of data occurences, used to generate spatial weights
occurence_table = false( length(se), length(time_values) );
for k = 1:length(se)
    if orig_map(k)
        monthnum = se(k).monthnum - min_month + 1;
        occurence_table( k, monthnum ) = true;
    end
end

% Apply station length and minimum number of measurement requirements
changed = true;
while changed
    changed = false;
    
    % Remove stations with too little data
    f = ( sum(occurence_table,2) <= min_months ) & orig_map;
    orig_map(f) = false;
    occurence_table(f,:) = false;
    if any(f) 
        changed = true;
    end
    
    % Remove time steps where fewer than min_stations reported data
    not_fittable = find(sum( occurence_table, 1) < min_stations);
    change = false( length(se), 1 );
    parfor k = 1:length(se)
        monthnum = se(k).monthnum - min_month + 1;
        if any( ismember( monthnum, not_fittable ) )
            sel = ~ismember( monthnum, not_fittable );
            se(k) = compress( select( se(k), sel ) );
            change(k) = true;
        end
    end
    changed = changed | any(change);
    
    occurence_table( :, not_fittable ) = false;
end

% Update the various time and occurence tables to deal with times removed
% in the previous step.
MM = min_month:max_month;
MM(not_fittable) = [];
min_month = min(MM);
max_month = max(MM);
times2 = double(min_month:max_month)/12 - 1/24 + 1600;
drop = ~ismember( time_values, times2 );
time_values = times2;
occurence_table( :, drop ) = [];

% Collapse redundant locations
[~, collapsed, expand_map] = unique( hashes(orig_map) );
locations = locations( orig_map );

locations_short = locations( collapsed );
num_sites = length(locations_short);

% Eliminate station locations with no usable data.
occurence_table = occurence_table( orig_map, : );
se = se( orig_map );

% Map of sites having multiple records.
comparison_map = cell( num_sites, 1 );
st_value = zeros( length(se), 1 );
for k = 1:length(se)
    st_value(k) = min( se(k).monthnum );
end
parfor k = 1:num_sites
    f = find( expand_map == k );
    [~, I] = sort( st_value(f) );
    f = f(I);
    comparison_map{k} = f;
end

% Make access faster (requires more memory)
dates_array = cell( length(se), 1 );
data_array = cell( length(se), 1 );
parfor k = 1:length(se)
    dates_array{k} = se(k).monthnum - min_month + 1;
    data_array{k} = se(k).data;
end
clear se;

% Further collapse locations according to grid approximation rules
[locations_collapsed, collapse_indices] = collapseLocations( locations_short, ...
    options.GridApproximationDistance );

locations_short = locations_collapsed;
expand_map = collapse_indices( expand_map );

% Locations for numerical integral grid
[LAT2, LONG2] = idealGrid( options.GridSize );
map_pts = geoPoint( LAT2(:), LONG2(:) );
clear LAT2 LONG2;

% Spatial land mask for numerical integral
if options.UseLandMask || options.FullBaselineMapping
    if options.GridSize == 16000
        cache = load('mask16000');
        areal_weight = cache.mask;
        map_elev = cache.elev;
    else        
        [areal_weight, map_elev] = makeLandMask( [map_pts(:).lat], [map_pts(:).long] );
    end
    areal_weight = double( areal_weight )';
    map_elev = double( map_elev );
    if ~options.UseLandMask
         areal_weight = ones( length(map_pts), 1 );
    end
else
    areal_weight = ones( length(map_pts), 1 );
    map_elev = [];
end

% If using the full climatology model, we need to assign an elevation to
% each station
if options.FullBaselineMapping
    site_elev = assignElevation( locations );
    site_lat = [locations(:).lat];
    map_lat = [map_pts(:).lat];
end

sessionWriteLog(['Averaging: ' num2str(length(data_array)) ...
    ' records used from ' num2str(num_sites) ' sites']);
sessionWriteLog([num2str(length(locations_short)) ' sites used for network approximation']);

% Build station cross-correlation table
[correlation_table, nugget] = buildCovarianceTable(locations_short, options);

% Build spatial target function
[target_map, near_index] = buildTargetTable( locations_short, map_pts, options );
near_index = near_index( expand_map );
clear locations_short locations_collapsed;

% Variable for storing spatial weights.
spatial_map = cell( length(time_values), 1 );
sz = size(target_map);
for k = 1:length(time_values)
    spatial_map{k} = sparse( sz(1), sz(2) );
end

num_months = sum( occurence_table, 2 );
total_cnts = zeros( 1, length(correlation_table) );
for k = 1:length( expand_map )
    % Each data point counts for a duplication as the base values is
    % "repeated" according to the number of times it occurs.
    total_cnts( expand_map(k) ) = total_cnts( expand_map(k) ) + num_months( k );
end

% Determine baseline mixing weights
if options.FullBaselineMapping
    [ all_station_mix, completeness, global_completeness, coverage_map, ...
        base_weights_map, baseline_mapping_sites, baseline_mapping_map ] = ...        
        buildBaselineTable( correlation_table, target_map, occurence_table, ...
        expand_map, nugget, areal_weight, options, ...
        site_elev, site_lat, map_elev, map_lat );
    
    clear site_elev site_lat map_elev map_lat;
else
    [ all_station_mix, completeness, global_completeness, coverage_map, ...
        base_weights_map ] = ...
        buildBaselineTable( correlation_table, target_map, occurence_table, ...
        expand_map, nugget, areal_weight, options );
end

% Crop fit region if requested
if options.LimitEmpiricalFitRegion
    f = ( coverage_map < options.EmpiricalFitRegionCutoff ); 
    areal_weight(f) = 0;
end

% Perform numerical integral.
target = areal_weight'*target_map/sum(areal_weight);

% Spatial weights for the global average
spatial_table = buildSpatialMap( correlation_table, target, occurence_table, ...
    expand_map, nugget, options );

coverage_summary = sum( spatial_table, 1 ) * completeness;

% If local we need to generate the more complicated spatial mapping tables.
if options.LocalMode
    [spatial_maps, coverage_map] = ...
        buildSpatialMap( correlation_table, target_map, occurence_table, expand_map, nugget, options );
else
    spatial_maps = spatial_table;
end

% If working under a parallel processing environment, distribute the data
% to the different nodes.
if matlabPoolSize > 1
    if isdistributed( spatial_maps );
        spmd        
            distrib = getCodistributor( spatial_maps );
            data_array = codistributed( data_array, distrib );
            dates_array = codistributed( dates_array, distrib );
        end
    else
        data_array = distributed( data_array );
        dates_array = distributed( dates_array );
    end
end
        
sessionWriteLog( ['Total Network Land Completeness: ' num2str( completeness ) ] );
sessionWriteLog( ['Total Network All Surface Completeness: ' num2str( global_completeness ) ] );

results.network_completeness = completeness;

% Free up some memory
clear target target2 correlation_table target_map;

% Initialize variables for the actual fitting section
len_t = length(time_values);
len_s = length(data_array);

first = true;
done = false;
if options.UseIterativeReweighting
    window = find( sum( occurence_table, 1 ) >= options.PrecisionTargetMinStations );
end

sessionSectionBegin( 'Compute Temperature Fit' );

loop = 0;

% Various data storage variables
results_list = zeros( len_t + len_s, max_loop );
input_list = results_list;
map = [];
map_dist = [];

if options.FullBaselineMapping
    baseline_params_list = zeros( length(baseline_mapping_map(1,:)), max_loop );
end
    
% Used for the low-memory Jacobian approximation in Broyden's method
if options.UseIterativeReweighting && options.UseBroydenMethod
    target_list = zeros( len_t + len_s, max_loop );
    jac_cor_C = zeros( len_t + len_s, max_loop );
    jac_cor_D = zeros( len_t + len_s, max_loop );
    jac_cor_C2 = zeros( len_t + len_s, max_loop );
    jac_cor_D2 = zeros( len_t + len_s, max_loop );
end

local_misfit = zeros( max_loop, 1 );
global_misfit = local_misfit;
max_change = local_misfit;
    
t_res = NaN( len_t, 1 );
b_res = NaN( len_s, 1 );

% This loop is the main workhorse for the iterative reweighting
while ~done
    loop = loop + 1;
    if loop > 1 && ~options.UseIterativeReweighting
        % Break out if iterative process not requested
        break;        
    end
    
    if loop > max_loop
        % Break out if too many loops already executed
        sessionWriteLog( 'Max loops reached... Exiting.' );
        break;
    end
        
    if options.UseIterativeReweighting
        % Display loop number
        sessionSectionBegin( ['Averaging Loop: ' num2str( loop )] );
    end
    
    input_list(:, loop) = [t_res; b_res];
    
    if ~first
        % Determine the quality of the fit during the previous iteration
        
        [sigma, sigma_full] = computeMeanMisfit( ...
            data_array, dates_array, t_res, b_res, map_dist, near_index, options );
        
        if options.LocalMode
            sessionWriteLog( ['RMS Local Misfit: '  num2str( sigma ) ] );
            local_misfit( loop ) = sigma;
        else
            sigma = sigma_full;
        end
        sessionWriteLog( ['RMS Global Misfit: '  num2str( sigma_full ) ] );
        global_misfit( loop ) = sigma_full;
    else
        sigma = Inf;
        sigma_full = Inf;
        local_misfit( loop ) = NaN;
        global_misfit( loop ) = NaN;
    end
            
    % Compute the quality of fit for each record
    if ~first && options.UseSiteWeighting
        site_weight = computeSiteWeight( data_array, dates_array, ...
            t_res, b_res, new_spatial_dist, map_dist, near_index, first, ...
            sigma, sigma_full, options );
    else
        site_weight = ones( len_s, 1 );
    end
        
    if ~first && options.UseSiteWeighting && options.LocalMode
        % In local mode we perform a complicated reweighting of the spatial
        % maps table.  This produces a more accurate accounting of the
        % impact of site weighting, but is slow.
        clear new_spatial_table spatial_reweight;        
        [new_spatial_table, new_spatial_dist, spatial_reweight] = reweightSpatialTable( spatial_maps, ...
            site_weight, coverage_map, areal_weight );
    else
        % Without local mode, we simply scale station spatial weights by
        % the associated site weight.  This is an approximate solution that
        % avoids the difficult numerical integral issues.  It works well
        % enough in many cases, but the results are not as accurate as
        % those provided by the full relocalization process.
        new_spatial_table = bsxfun( @times, spatial_table, site_weight );
        if options.LocalMode
            spatial_reweight = ones( size( coverage_map ) )';
        end            
        if matlabPoolSize > 1
            if isdistributed( data_array );
                nst2 = fastClone( new_spatial_table );
                
                spmd
                    [a,b] = globalIndices( data_array, 1 );
                    sparse_fragment = nst2( a:b, : );
                    
                    old_dist = getCodistributor( data_array );
                    dist = codistributor1d( 1, old_dist.Partition, [len_s, len_t] );
                    new_spatial_dist = codistWrapper( sparse_fragment, dist );
                end
                
                clear nst2;
            else
                new_spatial_dist = distributed( new_spatial_table );
            end
        else
            new_spatial_dist = new_spatial_table;
        end
    end
    
    % Build the matrices used to solve the constraint problem.
    [base_weights, base_constants, temperature_map, ...
        temperature_constant, record_weight] = ...
        buildMatrices( data_array, dates_array, new_spatial_dist, map_dist, ...
        near_index, t_res, b_res, sigma, sigma_full, first, options );
    
    base_weights( base_weights == 0 ) = 1;
    base_map = bsxfun( @rdivide, sparse( occurence_table ), base_weights );
    if ~first
        % Times at which the original fit failed can't be considered
        % because there is no baseline comparison data.
        base_map( :, isnan( t_res ) ) = 0;
        new_spatial_table( :, isnan( t_res ) ) = 0;
        new_spatial_dist( :, isnan( t_res ) ) = 0;
    end
    base_constants = base_constants ./ base_weights;
        
    % Determine the temperature and baseline values
    [t_res, b_res] = performFit( base_map, base_constants, temperature_map, ...
        temperature_constant, new_spatial_table, all_station_mix );
    if options.FullBaselineMapping
        % Determine the climatology field from the baseline values
        [adj, params, baseline_map, b_geographical, b_local] = ...
            fullBaselineMap( b_res, ...
            baseline_mapping_sites, base_weights_map, ...
            baseline_mapping_map, all_station_mix, areal_weight, ...
            near_index, expand_map, num_months, total_cnts, site_weight );        
        b_res = b_res + adj;
        t_res = t_res - adj;
    end
    
    sessionSectionBegin( 'Score Resulting Fit' );

    % Replace solution with seeded values if requested.  We do this for
    % multiple iterations in order to allow the quality of fit parameters
    % to become consistent with this seed.
    if options.UseSeed && loop <= 3
        [~, I1, I2] = intersect( options.SeedMonthlyTimes, time_values' );
        t_vals = t_res(I2);
        t_vals( isnan( t_vals ) ) = [];
        s_vals = options.SeedMonthlyValues(I1);
        s_vals( isnan( s_vals ) ) = [];
        offset = mean( t_vals ) - mean( s_vals );
        t_res( I2 ) = options.SeedMonthlyValues( I1 ) + offset;

        select2 = ~isnan( t_res );
        b_res = base_constants - base_map( :, select2 )*t_res(select2);
        if options.FullBaselineMapping
            [adj, params, baseline_map, b_geographical, b_local] = ...
                fullBaselineMap( b_res, ...
                baseline_mapping_sites, base_weights_map, ...
                baseline_mapping_map, all_station_mix, areal_weight, ...
                near_index, expand_map, num_months, total_cnts, site_weight );        
            b_res = b_res + adj;
            t_res = t_res - adj;
        else
            b_res2 = collapseValues( b_res, expand_map, ...
                num_months, total_cnts );
            baseline_map = base_weights_map*b_res2;
        end
    end
    
    res2 = [t_res; b_res];

    % Measure the global quality of fit
    [ssd, base_adjustment_scale, data_points] = scoreFit( data_array, dates_array, ...
        t_res, b_res, new_spatial_dist, map_dist, near_index, ...
        first, sigma, sigma_full, options );
    
    results.quality_of_fit = ssd / (data_points - sum(~isnan(res2)));
    results.data_points = data_points;
    results.time_parameters = sum( ~isnan(t_res) );
    results.baseline_parameters = sum( ~isnan(b_res ) );
    
    sessionSectionEnd( 'Score Resulting Fit' );
    
    % This optional section backs out scalpel breaks if the associated
    % change in baseline is determined to be statistically insignificant.
    % While potentially desirable, this operation is computationally 
    % expensive and generally has no impact on large scale averages, since
    % the inclusion / exclusion of a statistically insignificant break can
    % be anticipated to have no statistically significant effect on the
    % outcome.
    if options.RemoveInsignificantBreaks

        sessionSectionBegin('Remove Unnecessary Breakpoints' );
        
        removal = false;
        new_parameters = sum( ~isnan(res2) );
        base_constants = base_constants .* base_weights;
        occurence_table2 = occurence_table;
        
        eff_data_points = data_points - sum( ~isnan(res2) );
        for k = 1:length(comparison_map)
            cc = comparison_map{k};
            if length(cc) <= 1
                continue;  % No comparisons to make
            end
            
            % This does the heavy lifting of determining which values
            % should be combined.
            groups = findBaselineGroups( b_res( cc ), ssd, base_adjustment_scale( cc, : ), base_weights( cc ), eff_data_points );
            
            un = unique( groups );
            for j = 1:length(un)
                f = (groups == un(j));
                if sum(f) == 1
                    continue;
                end
                
                base_new_weight = sum( base_weights( cc(f) ) );
                base_new_constant = sum( base_constants( cc(f) ) );
                
                base_constants( cc(f) ) = base_new_constant;
                base_weights( cc(f) ) = base_new_weight;
                template = any( occurence_table( cc(f), : ), 1 );
                
                occurence_table2( cc(f), : ) = repmat( template, sum(f), 1 );
                removal = true;
                new_parameters = new_parameters - sum(f) + 1;
            end
        end
        
        % Duplicate and rerun much of the fitting code from above.
        if removal
            base_map = bsxfun( @rdivide, sparse( occurence_table2 ), base_weights );
            if ~first
                % Times at which the original fit failed can't be considered
                % because there is no baseline comparison data.
                base_map( :, isnan( t_res ) ) = 0;
                new_spatial_table( :, isnan( t_res ) ) = 0;
                new_spatial_dist( :, isnan( t_res ) ) = 0;
            end
            base_constants = base_constants ./ base_weights;
            
            if ~options.UseSeed || loop > 3
                [t_res, b_res] = performFit( base_map, base_constants, temperature_map, ...
                    temperature_constant, new_spatial_table, all_station_mix );
            else
                select2 = ~isnan( t_res );
                b_res = base_constants - base_map( :, select2 )*t_res(select2);
            end                
            if options.FullBaselineMapping
                [adj, params, baseline_map, b_geographical, b_local] = ...
                    fullBaselineMap( b_res, ...
                    baseline_mapping_sites, base_weights_map, ...
                    baseline_mapping_map, all_station_mix, areal_weight, ...
                    near_index, expand_map, num_months, total_cnts, site_weight );
                b_res = b_res + adj;
                t_res = t_res - adj;
            else
                b_res2 = collapseValues( b_res, expand_map, ...
                    num_months, total_cnts );
                baseline_map = base_weights_map*b_res2;
            end
            
            ssd = scoreFit( data_array, dates_array, ...
                t_res, b_res, new_spatial_dist, map_dist, near_index, ...
                first, sigma, sigma_full, options );
        end
        clear occurence_table2;
        
        res2 = [t_res; b_res];
        
        sessionSectionEnd('Remove Unnecessary Breakpoints' );
        
        results.adjusted_quality_of_fit = ssd / (data_points - new_parameters);
        results.reduced_baseline_parameters = new_parameters - sum( ~isnan(t_res) );
    end
    
    clear temperature_map base_map
    
    if options.LocalMode
        % Create map of local anomaly field
        map = buildTemperatureField( data_array, dates_array, map_pts, ...
            spatial_maps, spatial_reweight, ...
            site_weight, t_res, b_res, sigma_full, options );
        
        % Enforce area-weighted mean equals zero on the anomaly maps.  This is
        % approximately true by design, but round-off errors and non-unitary
        % weightings can result in a non-zero average, especially when the
        % number of stations get large.  We want to transfer any residual mean
        % to the temperature record.
        global_mean = areal_weight'*map/sum(areal_weight);
        t_res = t_res + global_mean';
        map = bsxfun( @minus, map, global_mean );
        
        if matlabPoolSize > 1
            map_dist = fastClone( map );
        else
            map_dist = map;
        end
        
        res2 = [t_res; b_res];        
    end
       
    % Tests for result convergence
    if (loop >= 2 && ~options.UseSeed) || loop >= 4
        % Check for convergence
        DD = results_list( window, loop-1 ) - res2( window );

        DD( isnan(DD) ) = [];
        DD = DD - mean(DD);
        
        rem = max( abs( DD ) );
        if isempty(rem)
            rem = NaN;
        end
        max_change(loop) = rem;
        
        sessionWriteLog( ['Max global average change in convergence window: ' num2str(rem)] );
        if rem < precision_target
            done = true;
        end
    else
        first = false;
        max_change(loop) = NaN;
    end

    results_list(:, loop) = res2;
    if options.FullBaselineMapping
        baseline_params_list(:,loop) = params;
    end

    % Apply a modification of Broyden's method to determine the values for
    % temperature and baseline to use for the next iteration.
    %
    % We use two different approximations of the Jacobian and average the
    % predictions they make.  This eliminates a bifurcation instability,
    % though it may converge somewhat slower.
    if loop >= 3 && options.UseBroydenMethod
        results_diff_list = results_list(:, 2:loop) - input_list( :, 2:loop );
        dx = input_list( :, loop ) - input_list( :, loop-1 );
        dF = results_diff_list( :, loop-1 ) - results_diff_list( :, loop-2 );        
        
        dx( isnan(dx) ) = 0;
        dF( isnan(dF) ) = 0;
        
        % Broyden's "bad" method Jacobian update
        jac_cor_C( :, loop ) = ( dx + dF - jac_cor_C*(jac_cor_D'*dF) ) / sum( dF.^2 );
        jac_cor_D( :, loop ) = dF;
        
        % Broyden's "good" method Jacobian update
        jac_cor_C2( :, loop ) = ( dx + dF - jac_cor_C2*(jac_cor_D2'*dF) ) / ( dx'*( -dF + jac_cor_C2*(jac_cor_D2'*dF) ) );
        jac_cor_D2( :, loop ) = -dx + jac_cor_D2*(jac_cor_C2'*dx);
        
        % Alternate which Jacobian is used to improve stability
        if mod( loop, 2 ) == 0
            resx = input_list( :, loop ) + dF - jac_cor_C * (jac_cor_D' * dF );
            resx( isnan(resx) ) = res2( isnan(resx) );
        else
            resx = input_list( :, loop ) + dF - jac_cor_C2 * (jac_cor_D2' * dF );
            resx( isnan(resx) ) = res2( isnan(resx) );
        end
        target_list( :, loop ) = resx;
        
        % Average two predictions, much more stable (but possibly slower).
        if loop >= 5
            res2 = ( target_list( :, loop ) + target_list( :, loop-1 ) )/2;
        end
    end
    
    if options.UseIterativeReweighting
        sessionSectionEnd( ['Averaging Loop: ' num2str( loop )] );
    end
end
clear base_weights base_constants temperature_constant;
clear map_dist dates_array data_array;
clear new_spatial_table new_spatial_dist;
clear spatial_table spatial_reweight;

sessionSectionEnd( 'Compute Temperature Fit' );

% Store baseline and climatology anomaly information.
baseline = zeros( 1, orig_length ).*NaN;
baseline(orig_map) = res2( len_t+1:end );
if options.FullBaselineMapping
    baseline_geo = zeros( 1, orig_length ).*NaN;
    baseline_geo(orig_map) = b_geographical;
    baseline_local = zeros( 1, orig_length ).*NaN;
    baseline_local(orig_map) = b_local;
    
    clear b_geographical b_local;
end

% Store information on the total weight each record recieves
record_weights = zeros(orig_length, 1).*NaN;
record_weights(orig_map) = record_weight / sum(record_weight( ~isnan(record_weight) ) );
results.record_weights = record_weights;

site_weights = zeros(orig_length, 1).*NaN;
site_weights(orig_map) = site_weight;
results.site_weights = site_weights;

% Store results in result structure.
results.times_monthly = time_values';
results.values_monthly = t_res;

[times2, values2] = simpleAnnualMovingAverage( time_values', t_res );
results.times_annual = times2;
results.values_annual = values2;

[times2, values2] = simpleMovingAverage( time_values', t_res, 60 );
results.times_five_year = times2;
results.values_five_year = values2;

[times2, values2] = simpleMovingAverage( time_values', t_res, 120 );
results.times_ten_year = times2;
results.values_ten_year = values2;

[times2, values2] = simpleMovingAverage( time_values', t_res, 240 );
results.times_twenty_year = times2;
results.values_twenty_year = values2;

results.baselines = baseline;
if options.FullBaselineMapping
    results.geographic_anomaly = baseline_geo;
    results.local_anomaly = baseline_local;
end

results.coverage_summary = coverage_summary;
results.location_pts = locations;
results.occurence_table = zipMatrix( occurence_table );

% Store map data, if appropriate
if options.LocalMode
    results.map_pts = map_pts;
    results.map = map;
    results.coverage_map = coverage_map;
end
if options.FullBaselineMapping
    results.map_pts = map_pts;
    results.base_map = baseline_map;
    results.baseline_parameters = params;
end

% Information on the convergence process.
if options.UseIterativeReweighting
    results_list(:, loop+1:end) = [];
    input_list(:, loop+1:end) = [];
    global_misfit(loop+1:end) = [];
    local_misfit(loop+1:end) = [];
    max_change(loop+1:end) = [];
    
    results.convergence.iterations = loop;
    results.convergence.reached_target = done;
    
    results.convergence.temperature_fits = results_list(1:length(t_res),:);
    results.convergence.baseline_fits = results_list(length(t_res)+1:end,:);

    results.convergence.temperature_starts = input_list(1:length(t_res),:);
    results.convergence.baseline_starts = input_list(length(t_res)+1:end,:);
    if options.FullBaselineMapping
        results.convergence.baseline_param_fits = baseline_params_list;
    end
    results.convergence.global_misfit = global_misfit;
    if options.LocalMode
        results.convergence.local_misfit = local_misfit;
    end
    results.convergence.max_change = max_change;

end

% Add results to disk cache.
save( frc, cache_hash, results );

sessionSectionEnd( 'Berkeley Average Core Process' );



function [hash, options2] = getOptionsHash( options )
% Creates a hash of the options structure including only those elements
% that are actually necessary to determine whether the code will give the
% same results.

options2 = struct;

options2.LocalMode = options.LocalMode;

options2.GridSize = options.GridSize;
options2.GridApproximationDistance = options.GridApproximationDistance;
options2.MinMonths = options.MinMonths;
options2.MinStations = options.MinStations;

options2.UseIterativeReweighting = options.UseIterativeReweighting;
if options.UseIterativeReweighting
    options2.UseSiteWeighting = options.UseSiteWeighting;
    if options.UseSiteWeighting
        options2.SiteWeightingGlobalCutoffMultiplier = options.SiteWeightingGlobalCutoffMultiplier;
        options2.SiteWeightingCutoffMultiplier = options.SiteWeightingCutoffMultiplier ;
        options2.SiteWeightingLocalized = options.SiteWeightingLocalized;
        options2.SiteWeightingRemoveSelf = options.SiteWeightingRemoveSelf;
    end
    
    options2.UseOutlierWeighting = options.UseOutlierWeighting;
    if options.UseOutlierWeighting
        options2.OutlierWeightingGlobalCutoffMultiplier = options.OutlierWeightingGlobalCutoffMultiplier;
        options2.OutlierWeightingCutoffMultiplier = options.OutlierWeightingCutoffMultiplier ;
        options2.OutlierWeightingLocalized = options.OutlierWeightingLocalized;
        options2.OutlierWeightingRemoveSelf = options.OutlierWeightingRemoveSelf;
    end
    options2.PrecisionTarget = options.PrecisionTarget;
    options2.PrecisionTargetMinStations = options.PrecisionTargetMinStations;
    options2.MaxIterations = options.MaxIterations;   
    options2.UseBroydenMethod = options.UseBroydenMethod;
end

options2.SpatialMapsEmptyCellCut = options.SpatialMapsEmptyCellCut;
options2.SpatialMapsTrivialMaxCut = options.SpatialMapsTrivialMaxCut;
options2.SpatialMapsTrivialSumCut = options.SpatialMapsTrivialSumCut;

options2.LimitEmpiricalFitRegion = options.LimitEmpiricalFitRegion;
if options2.LimitEmpiricalFitRegion
    options2.EmpiricalFitRegionCutoff = options.EmpiricalFitRegionCutoff;
end

options2.LimitEmpiricalBaselineRegion = options.LimitEmpiricalBaselineRegion;
if options2.LimitEmpiricalBaselineRegion
    options2.EmpiricalBaselineRegionCutoff = options.EmpiricalBaselineRegionCutoff;
end

options2.BadFlags = options.BadFlags;
options2.UseLandMask = options.UseLandMask;

options2.RemoveInsignificantBreaks = options.RemoveInsignificantBreaks;

options2.CorrelationParameters = options.CorrelationParameters;
options2.CorrelationLimitDistance = options.CorrelationLimitDistance;

options2.UseSeed = options.UseSeed;
options2.SeedMonthlyTimes = options.SeedMonthlyTimes;
options2.SeedMonthlyValues = options.SeedMonthlyValues;

options2.FullBaselineMapping = options.FullBaselineMapping;
options2.FullBaselineTargetLats = options.FullBaselineTargetLats;
options2.FullBaselineAltitudeDegree = options.FullBaselineAltitudeDegree;

options2.ClusterMode = options.ClusterMode;

hash = md5hash( options2 );


function [adj, params, baseline_map, b_res_reduced, b_local] = ...
    fullBaselineMap( b_res, baseline_mapping_sites, base_weights_map, ...
    baseline_mapping_map, all_station_mix, areal_weight, nearest, ...
    expand_map, num_months, total_cnts, site_weight )

% Determines the climatology field from the baseline values when full
% climatology mapping is enabled

warning( 'off', 'MATLAB:rankDeficientMatrix' );
params = bsxfun( @times, all_station_mix'.*site_weight, baseline_mapping_sites ) \ ...
    (all_station_mix'.*b_res.*site_weight);
warning( 'on', 'MATLAB:rankDeficientMatrix' );

b_res_reduced = b_res - baseline_mapping_sites*params;
b_res_reduced2 = collapseValues( b_res_reduced, expand_map, ...
    num_months, total_cnts );

baseline_map = base_weights_map*b_res_reduced2;

b_local = b_res_reduced - baseline_map( nearest );

baseline_map = baseline_map + baseline_mapping_map*params;

% If the initially determined climatology field has no zero mean, then we
% want transfer the residual to the temperature history, since the
% climatology is required to have zero mean by definition.
adj = areal_weight'*baseline_map / sum(areal_weight);
baseline_map = baseline_map - adj;
        
    
function collapsed = collapseValues( values, expand_map, num_months, total_cnts )

% Helper function associated with combining adjacent baseline values if the
% RemoveInsignficantBreaks is selected

collapsed = zeros( length(total_cnts), 1 );
for k = 1:length( expand_map )
    collapsed( expand_map(k) ) = collapsed( expand_map(k) ) + ...
        values( k )*num_months(k);
end
collapsed = collapsed ./ total_cnts';

