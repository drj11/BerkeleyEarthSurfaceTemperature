function spat_unc = computeAlternativeSpatialUncertainty( times, locations, ...
    coverage_map, areal_weight, map, options )
% Helper function used to compute analytical spatial uncertainty.

temperatureGlobals;
session = sessionStart;

frc = sessionFunctionCache;

hash = collapse( [ md5hash(times), md5hash(locations), md5hash(coverage_map), ...
    md5hash(areal_weight), md5hash(map), ...
    md5hash( [options.CorrelationParameters, ...
        options.CorrelationLimitDistance ] ) ] );

results = get( frc, hash );
if ~isempty( results )
    spat_unc = results;
    return;
end
    
types = {'monthly', 'annual', 'five_year', 'ten_year', 'twenty_year'};
lengths = [1, 12, 60, 120, 240];

% Build Variance Map
[~, var_months, var_annual, var_five_year, var_ten_year, ...
    var_twenty_year] = buildVarianceMap( map, coverage_map );

var_list = [var_annual, var_five_year, var_ten_year, var_twenty_year];

% Missing values are not acceptable here, so we replace the missing
% variances with the average of the rest.
for j = 1:12
    f = isnan(var_months(:,j));
    var_months( f, j ) = mean( areal_weight( ~f )*var_months( ~f, j ) / sum( areal_weight( ~f ) ) );
end

for m = 1:length(var_list(1,:))
    f = isnan(var_list(:,m));
    var_list( f, m ) = mean( areal_weight( ~f )*var_list( ~f, m ) / sum( areal_weight( ~f ) ) );
end

sessionSectionBegin( 'Compute Analytic Spatial Uncertainty' );

areal_weight = areal_weight / sum(areal_weight);

% Locations for numerical integral grid
X = [locations(:).x];
Y = [locations(:).y];
Z = [locations(:).z];

% Precomputed monthly covariance information.
p = options.CorrelationParameters;
maxd = options.CorrelationLimitDistance;

lenR = length(locations);

sessionSectionBegin( 'Generate Cross-correlation Table' );

cross_correlation = zeros( lenR, lenR, 'single' );
for j = 1:lenR
    % Determine separation distance
    cross_correlation(:,j) = ((X(j) - X).^2 + (Y(j) - Y).^2 + (Z(j) - Z).^2).^(1/2);
    f = ( cross_correlation(:,j) <= maxd );
    
    % Map distances to covariance model
    % Note division by R(0), don't want the nugget contribution
    cross_correlation(f,j) = exp(polyval( p, cross_correlation(f,j) )) / exp(polyval(p,0));  
    f = ( cross_correlation(:,j) > maxd );
    cross_correlation(f,j) = 0;
end

sessionSectionEnd( 'Generate Cross-correlation Table' );
sessionSectionBegin( 'Compute Monthly Uncertainty' );

spatial_unc = zeros( length( coverage_map(1,:) ), 1 );
parfor k = 1:length(coverage_map(1,:))
    %timePlot( 'Compute Uncertainty', k / length( coverage_map(1,: ) ) );
    j = mod( k, 12 ) + 1;
    
    scale_factor = sum( coverage_map(:,k).*areal_weight' ) / sum( areal_weight );
    A = var_months(:, j).*(1 - coverage_map(:,k)/scale_factor).*areal_weight';
    spatial_unc(k) = sqrt( A'*cross_correlation*A );
end

spat_unc.alternative_times_monthly = times;
spat_unc.alternative_unc_monthly = spatial_unc;

sessionSectionEnd( 'Compute Monthly Uncertainty' );
  
sessionSectionBegin( 'Compute Long-term Uncertainty' );

for m = 2:length(types)

    sessionSectionBegin( ['Compute Long-term Uncertainty - ' types{m}] );
    
    times2 = zeros( length(times) - lengths(m) + 1, 1 );
    for j = 1:lengths(m)
        times2 = times2 + times(j:end-lengths(m)+j);
    end
    times2 = times2 / lengths(m);
    
    sz = size(coverage_map);
    coverage_map2 = zeros( sz(1), sz(2)-lengths(m)+1 );
    for j = 1:lengths(m)
        coverage_map2 = coverage_map2 + coverage_map(:, j:end-lengths(m)+j );
    end
    coverage_map2 = coverage_map2 / lengths(m);

    spatial_unc2 = zeros( length( times2 ), 1 );
    parfor k = 1:length( times2 )
        %timePlot( 'Compute Uncertainty', k / length( times2 ) );

        scale_factor = sum( coverage_map2(:,k).*areal_weight' ) / sum( areal_weight );
        A = var_list(:, m-1).*(1 - coverage_map2(:,k)/scale_factor).*areal_weight';
        spatial_unc2(k) = sqrt( A'*cross_correlation*A );
    end
    
    field_name = ['alternative_times_' types{m}];
    unc_name = ['alternative_unc_' types{m}];
    
    spat_unc.(field_name) = times2;
    spat_unc.(unc_name) = spatial_unc2;

    sessionSectionEnd( ['Compute Long-term Uncertainty - ' types{m}] );

end

sessionSectionEnd( 'Compute Long-term Uncertainty' );

sessionSectionEnd( 'Compute Analytic Spatial Uncertainty' );

save( frc, hash, spat_unc )
