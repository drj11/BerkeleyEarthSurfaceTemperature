function spatial_unc = computeSpatialUncertainty( times, locations, map, ...
    coverage_map, areal_weight, options )

% Function to compute empirical spatial uncertainty.

temperatureGlobals;
session = sessionStart;

types = {'monthly', 'annual', 'five_year', 'ten_year', 'twenty_year'};
lengths = [1, 12, 60, 120, 240];

spatial_unc = struct;

% If using analytic supplements, compute that first.
if options.SupplementEmpiricalSpatialWithAnalytic
    spatial_unc2 = computeAlternativeSpatialUncertainty( times, locations, ...
        coverage_map, areal_weight, map, options );
    
    fn = fieldnames( spatial_unc2 );
    for m = 1:length(fn)
        spatial_unc.(fn{m}) = spatial_unc2.(fn{m});
    end    
end

sessionSectionBegin( 'Compute Spatial Uncertainty' );

if nargin < 5
    options = BerkeleyAverageOptions;
end

frc = sessionFunctionCache;

areal_weight = areal_weight / sum(areal_weight);

hash = collapse( [ md5hash(times), md5hash(map), md5hash(coverage_map), ...
    md5hash(areal_weight), md5hash( [options.SpatialUncertaintyBenchmarkMinDate, ...
    options.SpatialUncertaintyBenchmarkMaxDate] ) ] );

% Load from disk cache, if possible.
results = get( frc, hash );
if ~isempty( results )
    spatial_unc = results;
    sessionWriteLog( 'Loaded from cache' );
    sessionSectionEnd( 'Compute Spatial Uncertainty' );
    return;
end

% Loop over times
for k = 1:length(lengths)
    
    sz = size( coverage_map );
    coverage2 = zeros( sz(1), sz(2) - lengths(k) + 1 );
    map2 = coverage2;
    times2 = zeros( sz(2) - lengths(k) + 1, 1 );

    for j = 1:lengths(k)
        map2 = map2 + map(:, j:end-lengths(k)+j );
        coverage2 = coverage2 + coverage_map(:, j:end-lengths(k)+j );
        times2 = times2 + times(j:end-lengths(k)+j);
    end
    map2 = map2 / lengths(k);
    times2 = times2 / lengths(k);
    coverage2 = coverage2 / lengths(k);

    added_unc = zeros( length(times2), 1 );
        
    if options.SupplementEmpiricalSpatialWithAnalytic
        ftimes = ['alternative_times_' types{k}];
        fname = ['alternative_unc_' types{k}];
        for j = 1:length(times2)
            p = quickSearch( times2(j), spatial_unc.(ftimes) );
            added_unc(j) = spatial_unc.(fname)(p);
        end
    end    

    target_times = find( times2 >= options.SpatialUncertaintyBenchmarkMinDate & ...
        times2 <= options.SpatialUncertaintyBenchmarkMaxDate );

    sessionSectionBegin( ['Compute Spatial Uncertainty - ' types{k}] );
    truth = zeros( length(target_times), 1 );
    for j = 1:length(target_times)
        k2 = target_times(j);
        truth(j) = areal_weight*(coverage2(:,k2).*map2(:,k2)) / sum(areal_weight*coverage2(:,k2));
    end

    % Compute empirical uncertainty by applying coverage field to other
    % times and estimating the resulting measurement error.
    sp_unc = zeros( length(times2), 1 );
    for m = 1:length(times2)
        if mod( m, 20 ) == 0
            timePlot2( 'Compute Uncertainty', m/length(times2) );
        end

        base_m = sum(areal_weight*coverage2(:,m));

        j = mod( m, 12 ) + 1;
        tm = target_times;
        if k == 1
            fx = ( mod( tm, 12 ) + 1 == j );
            tm = tm( fx );
            truth2 = truth( fx );
        else
            truth2 = truth;
        end            

        est = zeros( length(truth2), 1 );
        for kk = 1:length(tm)
            k2 = tm(kk);
            est(kk) = areal_weight*(coverage2(:,m).*map2(:,k2)) / base_m;
        end
        sp_unc(m) = sqrt( sum( (truth2 - est).^2 + added_unc(tm).^2 ) / length(tm) );
    end
    timePlot2( 'Compute Uncertainty', 1 );

    ftimes = ['times_' types{k}];
    fname = ['unc_' types{k}];
    
    spatial_unc.(ftimes) = times2;
    spatial_unc.(fname) = sp_unc;

    sessionSectionEnd( ['Compute Spatial Uncertainty - ' types{k}] );
end

save( frc, hash, spatial_unc );

sessionSectionEnd( 'Compute Spatial Uncertainty' );



