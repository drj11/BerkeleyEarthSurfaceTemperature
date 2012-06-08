function [new_spatial_table, new_spatial_dist, new_spatial_weights] = reweightSpatialTable( spatial_maps, ...
    site_weights, coverage_map, areal_weights )
% Helper function that reweights the spatial Kriging coefficient to account
% for previously determined quality of fit information.

temperatureGlobals;
session = sessionStart;

sessionSectionBegin( 'Reweight Spatial Table' );

areal_weights = areal_weights/sum(areal_weights);

sz = size( coverage_map );
len_T = sz(2);

sz = sz([2,1]);
if matlabPoolSize > 1
    spmd
        [a,b] = globalIndices( spatial_maps, 1 );
        new_weights = reallyReweightSpatialTable( sz, site_weights(a:b), ...
            getLocalPart( spatial_maps ) );        
    end    
    
    new_weights = fastSum( new_weights );
    
    new_spatial_weights = (1 - coverage_map)';
    new_spatial_weights = new_spatial_weights + new_weights;
    clear new_weights;
    spmd; end;
else
    new_spatial_weights = reallyReweightSpatialTable( sz, site_weights, ...
        spatial_maps );
    new_spatial_weights = new_spatial_weights + (1 - coverage_map)';
end

sessionSectionEnd( 'Reweight Spatial Table' );
sessionSectionBegin( 'Collapse Spatial Table' );
len_S = length( spatial_maps );

if matlabPoolSize > 1
    new_spatial_weights = fastClone( new_spatial_weights );
    
    spmd
        [a,b] = globalIndices( spatial_maps, 1 );
        [oa, ob, os] = reallyCollapseSpatial( new_spatial_weights, ...
            getLocalPart( spatial_maps ), site_weights(a:b), areal_weights );    
        
        sparse_fragment = sparse( oa, ob, os, b - a + 1, len_T );
        
        old_dist = getCodistributor( spatial_maps );
        dist = codistributor1d( 1, old_dist.Partition, [len_S, len_T] );
        new_spatial_dist = codistWrapper( sparse_fragment, dist );
        
        oa = oa + a - 1;
        oa = gcat( oa, 2, 1 );
        ob = gcat( ob, 2, 1 );
        os = gcat( os, 2, 1 );
    end        
    new_spatial_table = sparse( oa{1}, ob{1}, os{1}, len_S, len_T );
    
    clear oa ob os dist old_dist sparse_fragment;
    spmd; end
else
    [oa, ob, os] = reallyCollapseSpatial( new_spatial_weights, ...
        spatial_maps, site_weights, areal_weights );
    new_spatial_table = sparse( oa, ob, os, len_S, len_T );
    new_spatial_dist = new_spatial_table;
end

sessionSectionEnd( 'Collapse Spatial Table' );


function new_spatial_weights = reallyReweightSpatialTable( sz, site_weights, ...
    spatial_maps )

len_S = length( spatial_maps );
new_spatial_weights = zeros( sz );

for j = 1:len_S    
    % Load data from station
    if isempty( spatial_maps{j} )
        continue;
    end
    
    f1 = uncompressLogical( spatial_maps{j}{1} );
    f2 = uncompressLogical( spatial_maps{j}{2} );
    
    s2 = expandPartialPrecision( spatial_maps{j}{3}, spatial_maps{j}{4} );
    ind = uncompressLogical( spatial_maps{j}{5} );
    
    s = zeros( sum(f1), sum(f2) );
    s(ind) = s2;
    
    new_spatial_weights( f1, f2 ) = new_spatial_weights( f1, f2 ) + s*site_weights( j );
end


function [a,b,s] = reallyCollapseSpatial( new_spatial_weights, ...
    spatial_maps, site_weights, areal_weights )

len_S = length(spatial_maps);

a_cell = cell(len_S,1);
b_cell = cell(len_S,1);
s_cell = cell(len_S,1);

for j = 1:len_S
    % Load data from station
    if isempty( spatial_maps{j} )
        continue;
    end
    
    f1 = uncompressLogical( spatial_maps{j}{1} );
    f2 = uncompressLogical( spatial_maps{j}{2} );
    
    s2 = expandPartialPrecision( spatial_maps{j}{3}, spatial_maps{j}{4} );
    ind = uncompressLogical( spatial_maps{j}{5} );
    
    s = zeros( sum(f1), sum(f2) );
    s(ind) = s2;

    sample = new_spatial_weights( f1, f2 );
    dat = s*site_weights(j) ./ sample;
    data = dat*areal_weights(f2);
    
    a_cell{j} = j*ones(1, length(data));
    b_cell{j} = find(f1)';
    s_cell{j} = double( data' );
end

a = [a_cell{:}];
b = [b_cell{:}];
s = [s_cell{:}];
