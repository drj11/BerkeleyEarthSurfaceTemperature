function coverage_map = buildCoverageField( len_M, len_S, len_T, spatial_maps )
% This helper function determines the total coverage (a measure of sampling
% completeness) at each location and time on the numerical grid by summing the
% contributions from each station.

temperatureGlobals;
session = sessionStart;

frc = sessionFunctionCache;

% If running a parallel processing configuration, distribute data across
% nodes accordingly.
if matlabPoolSize >= 1
    spmd
        maps = getLocalPart( spatial_maps );
        hashes(1:length(maps)) = md5hash;
        for k = 1:length(maps)
            hashes(k) = md5hash( maps{k} );
        end
    end
    clear maps;
    hashes = [hashes{:}];
else
    hashes(1:length(spatial_maps) ) = md5hash;
    for k = 1:length(spatial_maps)
        hashes(k) = md5hash( spatial_maps{k} );
    end
end
hash = collapse( [md5hash( [len_M, len_S, len_T] ), hashes ] );

result = get( frc, hash );
if ~isempty( result )
    coverage_map = result;
    return;
end

sessionSectionBegin( 'Build Coverage Map' );

if matlabPoolSize <= 1
    coverage_map = reallyBuildCoverageMap( len_M, len_T, spatial_maps );
else
    spmd
        coverage_piece = reallyBuildCoverageMap( len_M, len_T, getLocalPart( spatial_maps ) );
        coverage_piece = gplus( coverage_piece, 1 );
    end
    coverage_map = coverage_piece{1};
    clear coverage_piece;
    spmd; end
end

sessionSectionEnd( 'Build Coverage Map' );

save( frc, hash, coverage_map );


function coverage_map = reallyBuildCoverageMap( len_M, len_T, spatial_maps )
% Subfunction to permit more efficient parallel behavior.

coverage_map = zeros( len_M, len_T, 'single' );
len_S = length( spatial_maps );

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
    
    coverage_map( f2, f1 ) = coverage_map( f2, f1 ) + s';
end
