function map = buildTemperatureField( data_array, dates_array, map_pts, ...
    spatial_maps, spatial_reweight, site_weights, ...
    t_mean, b_mean, sigma_full, options )

% Helper function that computes the temperature map when running in local
% mode from the previously computed Kriging coefficents, station data, 
% station baselines, and global averages.  Incorporates outlier weighting
% functionality.

temperatureGlobals;
session = sessionStart;

len_M = length(map_pts);
len_T = length(t_mean);

sessionSectionBegin( 'Build Temperature Map' );

% Wrappers to distinguish parallel processing case.
if matlabPoolSize > 1    
    spmd
        [A,B] = globalIndices( spatial_maps, 1 );
        maps = getLocalPart( spatial_maps );
        data = getLocalPart( data_array );
        dates = getLocalPart( dates_array );
        
        map_dist = reallyCreateMap( len_T, len_M, data, dates, ...
            sigma_full, spatial_reweight, t_mean, b_mean(A:B), ...
            site_weights(A:B), maps, options );
    end
    clear maps;
    map = fastSum( map_dist );
    
    clear map_dist;
    spmd; end;
else    
    map = reallyCreateMap( len_T, len_M, data_array, dates_array, sigma_full, ...
        spatial_reweight, t_mean, b_mean, site_weights, spatial_maps, options );
end

sessionSectionEnd('Build Temperature Map');



function map = reallyCreateMap( len_T, len_M, data_array, dates_array, ...
    sigma_full, spatial_reweight, t_mean, b_mean, site_weights, ...
    spatial_maps, options )

% Real function that creates the map.

len_S = length(spatial_maps);
map = zeros( len_T, len_M, 'single' );

for j = 1:len_S
    if isnan( b_mean(j) ) 
        continue;
    end    
    
    data_table = zeros( len_T, 1 );
    
    % Load data from station
    monthnum = dates_array{j};
    data = data_array{j};

    fs = isnan( t_mean( monthnum ) );
    monthnum(fs) = [];
    data(fs) = [];
    if isempty( monthnum )
        continue;
    end
    
    data_table( monthnum ) = single( data );
    
    f1 = uncompressLogical( spatial_maps{j}{1} );
    f2 = uncompressLogical( spatial_maps{j}{2} );
    
    s2 = expandPartialPrecision( spatial_maps{j}{3}, spatial_maps{j}{4} );
    ind = uncompressLogical( spatial_maps{j}{5} );
    
    s = zeros( sum(f1), sum(f2) );
    s(ind) = s2;
    
    % Rescale to deal with site reliability adjustments.
    sample = spatial_reweight( f1, f2 );
    sp_weights = s*site_weights(j) ./ sample;
    
    data_table(monthnum) = data_table( monthnum ) - b_mean(j) - t_mean( monthnum );
    
    if options.UseOutlierWeighting
        mult = options.OutlierWeightingGlobalCutoffMultiplier;
        
        fx = ( data_table(monthnum) > mult*sigma_full );
        data_table(monthnum(fx)) = mult*sigma_full;
        fx = ( data_table(monthnum) < -mult*sigma_full );
        data_table(monthnum(fx)) = -mult*sigma_full;
    end
    
    sp_weights = bsxfun( @times, sp_weights, data_table( f1 ) );
    map( f1, f2 ) = map( f1, f2 ) + sp_weights;
end

map = map';
