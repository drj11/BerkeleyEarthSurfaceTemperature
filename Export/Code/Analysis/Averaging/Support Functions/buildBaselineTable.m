function [ baseline_weights, completeness, global_completeness, cov_map, base_map, ...
    base_mapping_sites, base_mapping_map ] ...
    = buildBaselineTable( correlation_table, target_map, occ_table, expand_map, ...
    nugget, mask, options, sites_elev, sites_lat, map_elev, map_lat )
% This function uses a Kriging process to determine the optimal mix of 
% baseline values to be used in adjusting the global temperatures to a true
% average temperature.
%
% This function is an auxillary helper function to BerkeleyAverageCore, and
% is never expected to be called directly.

temperatureGlobals;
session = sessionStart;

sessionSectionBegin( 'Build Baseline Table' );

% Number of data points;
num_months = sum( occ_table, 2 );
len_R = length(correlation_table);
mask = double( mask' );

if options.ClusterMode
    correlation_table = double( distributed( correlation_table ) );
    target_map = double( distributed( target_map ) );
else
   correlation_table = double( correlation_table );
   target_map = double( target_map );
end

% Total mix
mix_term = 1 - nugget;
cnts = zeros( 1, len_R );
for k = 1:length( expand_map )
    % Each data point counts as a duplication as the base values is
    % "repeated" according to the number of times it occurs.
    cnts( expand_map(k) ) = cnts( expand_map(k) ) + num_months( k );
end
I = diagonalIndices( length(correlation_table) );
correlation_table(I) = (1 + (cnts-1)*mix_term)./cnts;

% Determine baseline mixing values at each grid point
base_map = (correlation_table' \ target_map')';
if options.ClusterMode
    base_map = gather( base_map );
end

cov_map = sum( base_map, 2 );

% Some additional diagnostic parameters
completeness = sum( mask*base_map ) / sum(mask);

% Limit empirical region for increased stability 
if options.LimitEmpiricalBaselineRegion
    f = ( cov_map >= options.EmpiricalBaselineRegionCutoff ); 
    mask( ~f ) = 0;
end

% Perform numerical integral to generate final baseline mixing coefficients 
baseline_weights = mask*base_map / sum( mask );
baseline_weights = baseline_weights ./ cnts;
baseline_weights = baseline_weights( expand_map ).*num_months';

target2 = sum(target_map, 1)/length(target_map);
global_completeness = sum( correlation_table' \ target2', 1 );
if options.ClusterMode
    global_completeness = gather( global_completeness );
end

clear correlation_table target_map target2;
spmd; end;

% If requested, determine the parameterization for full climatology mapping
% as a function of latitude and altitude.
if options.FullBaselineMapping
    sites_lat2 = sin(sites_lat*pi/180);

    target_lats = options.FullBaselineTargetLats;
    
    if min( target_lats )< 0 
        error( 'min( options.FullBaselineTargetLats ) < 0' );
    end
    if min(target_lats) == 0     
        E = eye( length(target_lats) );
        E = [E E(:,end-1:-1:1)];
        lats2 = [-target_lats(end:-1:1), target_lats(2:end)];
        W = spline( lats2, E, sites_lat2 );
    else
        E = eye( length(target_lats) );
        E = [E E(:,end:-1:1)];
        lats2 = [-target_lats(end:-1:1), target_lats(1:end)];
        W = spline( lats2, E, sites_lat2 );
    end

    base_mapping_sites = W';
    for k = 1:options.FullBaselineAltitudeDegree
        base_mapping_sites(:, end+1) = sites_elev.^k;
    end

    map_lat2 = sin(map_lat*pi/180);

    L = spline( lats2, E, map_lat2 );
    
    base_mapping_map = L';
    for k = 1:options.FullBaselineAltitudeDegree
        base_mapping_map(:, end+1) = map_elev.^k;
    end
end    

sessionSectionEnd( 'Build Baseline Table' );
