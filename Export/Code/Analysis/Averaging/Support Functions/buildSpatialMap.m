function [spatial_map, coverage_map] = buildSpatialMap( weight, target_map, ...
    occurence_table, expand_map, nugget, options )
% This helper function determines the Kriging coefficients necessary to
% give each station an appropriate weight at each location and time given
% the presense of other stations.
%
% This function can be run in two different modes.  It is used both to
% compute the Kriging coefficients at specific locations used for numerical
% integration and to compute the global integral of those coefficents.  In
% the former case, very small values are truncated to zero to conserve
% memory, but wehn called in the global mode no truncation occurs.

temperatureGlobals;
session = sessionStart;

% Compute hashes used for caching.
frc = sessionFunctionCache();
base_hash = collapse( [md5hash(weight), md5hash(target_map), ...
    md5hash(occurence_table), md5hash(expand_map), md5hash(nugget) ] );
[~, file_hash] = sessionFileHash( which(mfilename) );
base_hash = collapse( [base_hash, file_hash] );

% If called without options use default option set
if nargin < 6
    options = BerkeleyAverageOptions;
end

weight = double(weight);
target_map = single(target_map);

pool_size = matlabPoolSize();
if pool_size == 0
    pool_size = 1;
end

mix_term = 1 - nugget;

sz = size( occurence_table );
len_T = sz(2);
len_S = sz(1);

sz = size( target_map );
len_M = sz(1);

if len_M == 1
    table_mode = true;
    sessionSectionBegin( 'Generate Spatial Table' );
else
    table_mode = false;
    sessionSectionBegin( 'Generate Spatial Map' );
end

% Load from disk cache if possible
res = get( frc, base_hash );
if ~isempty( res )
    if table_mode
        spatial_map = res;
        sessionWriteLog( 'Loaded from Cache' );
        sessionSectionEnd( 'Generate Spatial Table' );
        return;
    else
        coverage_map = res;
        try
            if ~exist( 'temperature_cache_dir', 'var' )
                temperature_cache_dir = temperature_data_dir;
            end
            
            root = [temperature_cache_dir 'Spatial Maps'];
            spatial_map = loadSpatialMap( root, base_hash );
            sessionWriteLog( 'Loaded from Cache' );
            sessionSectionEnd( 'Generate Spatial Map' );
            return;
        catch ME
            % Not found, continue with process;
        end
    end
end

% The following describes an elaborate process by which results associated 
% with time t_i are used to accelerate the computation of the coefficients 
% at time t_i+1.  As the station network changes very little between times 
% steps, the coefficients are very similar and this approach provides a 
% very large performance enhancement; however, the algorithm required to
% implement this makes the resulting code considerably more opaque.

% Break the spatial network changes into multiple blocks that share most of
% their stations in common.
common_list = false( size(occurence_table) );
common_index = zeros( len_T, 1 );

for j = 1:len_T
    if sum( occurence_table(:,j) ) < 50
        common_index(j) = 0;
    elseif common_index(j) == 0
        m = j;
        while m <= len_T
            common = all( occurence_table( :, j:m ), 2);
            base = any( occurence_table(:, j:m ), 2 );
            if sum(common) < 0.7*sum(base)
                m = m - 1;
                break;
            end
            m = m + 1;
        end
        
        if m > len_T
            m = len_T;
        end
        common_index(j:m) = max(common_index(1:j-1)) + 1;
        
        common = all( occurence_table( :, j:m ), 2 );
        common_list( :, common_index(j) ) = common;
    end
end
common_list( :, max(common_index)+1:end ) = [];

exports1 = cell( len_T, 1 );
exports2 = cell( len_T, 1 );
exports3 = cell( len_T, 1 );
entries = 0;

if matlabPoolSize > 1
    spatial_map = distributed.cell( len_S, 1 );
else
    spatial_map = cell( len_S, 1 );
end

for n = 0:pool_size:max(common_index)
    timePlot2( 'Build Spatial Maps', n / max(common_index) );

    % Preallocate exchange variable used for communicating with parallel
    % nodes (when available).
    if pool_size > 1
        B_pass = Composite();
        B_copy = Composite();
        common_cnts = Composite();
        remap_pass = Composite();
        remap_s_pass = Composite();
        weight2_pass = Composite();
        weight2_copy = Composite();
        target_map2_pass = Composite();
        target_map2_copy = Composite();
        occ_fragment = Composite();
        occ_copy = Composite();
        need_inv = Composite();
    else
        B_pass = {};
        B_copy = {};
        common_cnts = {};
        remap_pass = {};
        remap_s_pass = {};
        weight2_pass = {};
        weight2_copy = {};
        target_map2_pass = {};
        target_map2_copy = {};
        occ_fragment = {};
        occ_copy = {};
        need_inv = {};
    end
    
    for k = 1:pool_size
        B_pass{k} = [];
        B_copy{k} = [];
        weight2_pass{k} = [];
        weight2_copy{k} = [];
        target_map2_pass{k} = [];
        target_map2_copy{k} = [];
        occ_fragment{k} = [];
        occ_copy{k} = [];
    end        
   
    for j = n:n+pool_size-1
        f = ( common_index == j );
        if ~any(f)
            continue;
        end
        
        % This breaks the dataset into packets of time and removes values 
        % not related to the current time slice in order to conserve memory
        % during the parallel operations.
        occ_fragment{j-n+1} = occurence_table(:,f);
        
        needed = any( occurence_table( :, f ), 2 );
        needed = unique( expand_map( needed ) );
        list = 1:max(needed);
        list = list( needed );
        remap = zeros( max(needed), 1 );
        remap( list ) = 1:length(list);
        
        common_set = j;
        if common_set ~= 0
            needed_s = any( occurence_table( :, f ), 2 ) & ...
                ~common_list(:, j);
            needed_s = unique( expand_map( needed_s ) );
        else
            needed_s = [];
        end
        if isempty( needed_s )
            needed_s = needed;
        end
        list = 1:max(needed_s);
        list = list( needed_s );
        remap_s = zeros( max(needed_s), 1 );
        remap_s( list ) = 1:length(list);

        weight2 = weight( needed, needed_s );
        target_map2 = target_map( :, needed );
        
        remap_pass{j-n+1} = remap;
        remap_s_pass{j-n+1} = remap_s;
        weight2_pass{j-n+1} = weight2;
        target_map2_pass{j-n+1} = target_map2;
        
        if j ~= 0
            % Prepare information on the common submatrix used to
            % accelerate the computational performance.
            
            common = common_list( :, j );
            weight3 = weight( needed, needed );
            
            cnts = zeros( length(remap), 1 );
            expanded = expand_map( common );
            for m = 1:length(expanded)
                cnts(expanded(m)) = cnts(expanded(m)) + 1;
            end
            selection = ( cnts > 0 );
            
            B = weight3( remap( selection ), remap( selection ) );
            I = diagonalIndices( length(B) );
            B(I) = (1 + (cnts(selection)-1)*mix_term)./cnts(selection); % mixing corrections
            
            if numel(B)*8 > 100e6 && ~options.ClusterMode
                need_inv{j-n+1} = false;
                B = inv( double(B) );
            else
                need_inv{j-n+1} = true;
            end
            
            B_pass{j-n+1} = B;
            common_cnts{j-n+1} = cnts;
            clear weight3;
        else
            B_pass{j-n+1} = [];
            common_cnts{j-n+1} = [];
        end
        
        % This passes the large arrays to the workers and clears them out
        % of the memory on the main node.  This is necessary to avoid out
        % of memory faults on the master node while building up the various
        % pieces.
        if mod( j - n, 4 ) == 3
            if pool_size > 1
                spmd
                    if ~isempty( B_pass )
                        B_copy = B_pass;
                        B_pass = [];
                    end
                    if ~isempty( weight2_pass )
                        weight2_copy = weight2_pass;
                        weight2_pass = [];
                    end
                    if ~isempty( target_map2_pass )
                        target_map2_copy = target_map2_pass;
                        target_map2_pass = [];
                    end
                    if ~isempty( occ_fragment )
                        occ_copy = occ_fragment;
                        occ_fragment = [];
                    end
                end
                for k = 1:pool_size
                    B_pass{k} = [];
                    weight2_pass{k} = [];
                    target_map2_pass{k} = [];
                    occ_fragment{k} = [];
                end                        
            end
        end        
    end
    clear weight2 target_map2 B;
    
    if pool_size > 1
        spmd
            if ~isempty( B_pass )
                B_copy = B_pass;
            end
            if ~isempty( weight2_pass )
                weight2_copy = weight2_pass;
            end
            if ~isempty( target_map2_pass )
                target_map2_copy = target_map2_pass;
            end
            if ~isempty( occ_fragment )
                occ_copy = occ_fragment;
            end
        end
    else
        B_copy = B_pass;
        target_map2_copy = target_map2_pass;
        occ_copy = occ_fragment;
        weight2_copy = weight2_pass;
    end
    clear B_pass target_map2_pass weight2_pass occ_fragment
    
    len_W = length(weight);
    items = n:min( n+pool_size-1, max(common_index) );
    
    if pool_size > 1
        spmd % Seperate memory intensive B_pass from others
            if labindex <= length(items)
                pos = items(labindex);
                
                f = ( common_index == pos );
                index = find( f );
                
                if pos > 0
                    common = common_list(:, pos );
                    if need_inv
                        B_copy = double( B_copy );
                        B_copy = inv( B_copy );
                    end
                else
                    common = [];
                    B_copy = [];
                end
            end
        end
        
        spmd
            if labindex <= length(items)
                % Actual computation of a block of Kriging coefficients
                [exports1_dist, exports2_dist, exports3_dist] = ...
                    computeSpatialMapBlock( common, ...
                    common_cnts, B_copy, occ_copy, expand_map, remap_pass, ...
                    remap_s_pass, weight2_copy, target_map2_copy, ...
                    len_M, len_W, index, mix_term, options );
            end
        end
        clear common occ_fragment index B B_pass;
        clear remap_pass remap_s_pass weight2_pass target_map2_pass;
        spmd; end;
        
        for j = 1:length(items)
            f = ( common_index == items(j) );
            exports1(f) = exports1_dist{j};
            exports2(f) = exports2_dist{j};
            exports3(f) = exports3_dist{j};
            entries = entries + sum(f);
            
            exports1_dist{j} = [];
            exports2_dist{j} = [];
            exports3_dist{j} = [];
            spmd; end;
        end
        clear exports1_dist exports2_dist exports3_dist;
        spmd; end;
    else
        % Version of the above for single threaded computation.
        
        f = ( common_index == n );
        index = find( f );
        
        if n > 0
            common = common_list(:, n);
            common_cnts = common_cnts{1};
            if need_inv{1}
                Bi = inv( double( B_copy{1} ) );
            else
                Bi = B_copy{1};
            end
        else
            common = [];
            common_cnts = [];
            Bi = [];
        end
                
        [exports1(f), exports2(f), exports3(f)] = ...
            computeSpatialMapBlock( common, ...
            common_cnts, Bi, occ_copy{1}, expand_map, remap_pass{1}, ...
            remap_s_pass{1}, weight2_copy{1}, ...
            target_map2_copy{1}, len_M, len_W, index, mix_term, options );
        
        entries = entries + sum(f);
        clear remap_pass remap_s_pass weight2_pass target_map2_pass;
    end
    
    % Periodically consolidate and compress the returned values to save
    % memory.
    if (entries > 100 || max(items) == max(common_index)) && ~table_mode
        good = false( len_T, 1 );
        
        for m = 1:length( exports1 )
            if ~isempty( exports1{m} ) && max( exports1{m}(:,2) ) > 0
                good(m) = true;
            end
        end
        
        A = cat( 1, exports1{good} );
        exports1 = cell( len_T, 1 );
        B = cat( 1, exports2{good} );
        exports2 = cell( len_T, 1 );
        C = cat( 1, exports3{good} );
        exports3 = cell( len_T, 1 );
        
        if matlabPoolSize() > 1
            spmd
                [a,b] = globalIndices( spatial_map, 1 );
            end
            
            Ac = Composite( length(a) );
            Bc = Composite( length(a) );
            Cc = Composite( length(a) );
            for k = 1:length(a)
                f = ( B >= a{k} & B <= b{k} );
                Ac{k} = A(f,:);
                Bc{k} = B(f) - a{k} + 1;
                Cc{k} = C(f);
            end
            clear A B C;
            
            spmd
                local_map = getLocalPart( spatial_map );
                local_map = attachSpatialMap( Ac, Bc, Cc, local_map );
                spatial_map = codistWrapper( local_map, getCodistributor( spatial_map ) );
            end
            clear local_map Ac Bc Cc;
            spmd; end;
        else
            [B, I] = sort( B );
            A = A(I,:);
            C = C(I);
            
            spatial_map = attachSpatialMap( A, B, C, spatial_map );
            clear A B C;
        end
        
        entries = 0;
    end
end
timePlot2( 'Build Spatial Maps', 1 );

clear weight target_map

if ~table_mode
    % Operations needed for numerical integration map
    
    sessionSectionBegin( 'Compress Spatial Map' );
    
    if matlabPoolSize > 1
        spmd
            maps = getLocalPart( spatial_map );
            maps = reallyCompressSpatialMap( len_T, len_M, maps );
            spatial_map = codistWrapper( maps, getCodistributor( spatial_map ) );
        end
        clear maps;
    else
        spatial_map = reallyCompressSpatialMap( len_T, len_M, spatial_map );
    end
    
    sessionSectionEnd( 'Compress Spatial Map' );
    
    coverage_map = buildCoverageField( len_M, len_S, len_T, spatial_map );
    
    % Rescale any excess.  This is a side effect of truncating small negative
    % values.
    
    sessionSectionBegin( 'Normalize Scale' );
    
    if matlabPoolSize > 1
        spmd
            maps = getLocalPart( spatial_map );
            maps = reallyNormalizeScale( coverage_map', maps );
            spatial_map = codistWrapper( maps, getCodistributor( spatial_map ) );
        end
        clear maps;
    else
        spatial_map = reallyNormalizeScale( coverage_map', spatial_map );
    end
    
    sessionSectionEnd( 'Normalize Scale' );
    
    % This is a big deal.  Truncation error tends lead to values greater than
    % one in dense regions, so this correction is necessary.  However, it also
    % tends to hide numerical and other problems.  So, it can be useful to
    % disable this during debugging.
    f = ( coverage_map > 1 );
    coverage_map(f) = 1;
    
    sessionSectionEnd( 'Generate Spatial Map' );
else
    % Operations for values that are already globally integrated
    
    for k = 1:length(exports1)
        if isempty( exports1{k} ) || length( exports1{k} ) == 2
            exports1{k} = sparse( len_S, 1 );
        else
            exports1{k} = sparse( exports1{k} );
        end
    end
    spatial_map = [exports1{:}];
    
    sessionSectionEnd( 'Generate Spatial Table' );
end

if ~exist( 'temperature_cache_dir', 'var' )
    temperature_cache_dir = temperature_data_dir;
end

root = [temperature_cache_dir 'Spatial Maps'];

% Save results to disk cache
if ~table_mode
    save( frc, base_hash, coverage_map );
    saveSpatialMap( root, base_hash, spatial_map );
else
    save( frc, base_hash, spatial_map );
end


function spatial_map = reallyNormalizeScale( coverage_map, spatial_map )
% A side effect of the small value truncation in computeSpatialMapBlock is
% that dropping too many small negative terms can sometimes lead to integrated
% values slightly greater than one.  This procedure rescales the remaining
% values to eliminate this effect.  This helps with the computational 
% stability and speed of convergence of later processes.

warning( 'off', 'MATLAB:intConvertOverflow' );
warning( 'off', 'MATLAB:intConvertNonIntVal' );

len_S = length(spatial_map);

for j = 1:len_S
    f1 = uncompressLogical( spatial_map{j}{1} );
    f2 = uncompressLogical( spatial_map{j}{2} );
    
    s2 = expandPartialPrecision( spatial_map{j}{3}, spatial_map{j}{4} );
    ind = uncompressLogical( spatial_map{j}{5} );
    
    s = zeros( sum(f1), sum(f2) );
    s(ind) = s2;
    
    coverage_subset = coverage_map( f1, f2 );
    f = ( coverage_subset > 1 );
    if any(f)
        s(f) = s(f)./coverage_subset(f);
        
        [C, D] = makePartialPrecision( s(ind) );
        spatial_map{j}{3} = C;
        spatial_map{j}{4} = D;
    end
end

warning( 'on', 'MATLAB:intConvertOverflow' );
warning( 'on', 'MATLAB:intConvertNonIntVal' );


function spatial_map = reallyCompressSpatialMap( len_T, len_M, spatial_map )
% Changes the representation of the spatial Kriging coefficients to the
% format required for future work.

warning( 'off', 'MATLAB:intConvertOverflow' );
warning( 'off', 'MATLAB:intConvertNonIntVal' );
for k = 1:length( spatial_map )
    a = expand( spatial_map{k}{1}(:,1) );    
    t_access = zeros( len_T, 1 );
    f1 = false( len_T, 1 );
    f1(a) = true;
    t_access( f1 ) = 1:sum(f1);
    ind = t_access(a);
    clear a;
    
    b = expand( spatial_map{k}{1}(:,2) );
    m_access = zeros( len_M, 1 );
    f2 = false( len_M, 1 );
    f2(b) = true;
    m_access( f2 ) = 1:sum(f2);
    ind = ind + (m_access(b)-1)*sum(f1);
    clear b;
    
    template = false( sum(f1), sum(f2) );
    template( ind ) = true;
    
    C = expand( spatial_map{k}{2} );
    [~, I] = sort( ind );
    C = C(I);
    
    template = compressLogical( template );
    [D, E] = makePartialPrecision( C );
    
    f1 = compressLogical( f1 );
    f2 = compressLogical( f2 );
    
    spatial_map{k} = { f1, f2, D, E, template };
end
warning( 'on', 'MATLAB:intConvertNonIntVal' );
warning( 'on', 'MATLAB:intConvertOverflow' );


function res = invWithPartial2( M_B, M_D, Ai )

% Helper function for computing an inverse matrix given an known partial
% inverse.  

M_C = M_B';

SS = Ai*M_B;
SP = M_D - M_C*SS;
SPi = inv(SP);

RR = (SPi*M_C)*Ai;

res = [Ai + SS*RR, -SS*SPi; -RR, SPi];


function X = mldivideWithParitalInverse2( M_C, M_D, T, Ai )

% Helper function for detemining a matrix division solution given a known 
% partial inverse.  

M_B = M_C';

T1 = T(1:length(M_B));
T2 = T(length(M_B)+1:end);

if isempty(M_D)
    X = Ai*T;
    return;
end

Y = Ai*T1;

X2 = (M_D - M_B*Ai*M_C)\(T2 - M_B*Y);

szA = size(Ai);
sz2 = size(X2);

if szA(1) > sz2(2)
    X1 = Y - Ai*(M_C*X2);
else
    X1 = Y - (Ai*M_C)*X2;
end

X = [X1; X2];


function [exports1, exports2, exports3] = computeSpatialMapBlock( common, ...
    common_cnts, Bi, occ_fragment, expand_map, remap, remap_s, weight, ...
    target_map, len_M, len_W, index, mix_term, options )

% Heavy lifting function for computing the correlation matrix inverse.

if len_M == 1
    table_mode = true;
else
    table_mode = false;
end

Bi = double( Bi );
loops = length( occ_fragment(1,:) );

exports1 = cell( loops, 1 );
exports2 = cell( loops, 1 );
exports3 = cell( loops, 1 );

for j = 1:loops
    f = occ_fragment(:,j);
    if ~any(f)
        % No records exist at this time.
        exports1{j} = [0,0];
        exports2{j} = 0;
        exports3{j} = 0;
        continue;
    end
    
    if ~isempty( common )
        f = f & ~common;
    end
    
    cnts = zeros( length(remap), 1 );
    expanded = expand_map( f );
    for m = 1:length(expanded)
        cnts(expanded(m)) = cnts(expanded(m)) + 1;
    end
    selection = ( cnts > 0 );
    
    % Select rows of weight function corresponding to active stations and
    % add in the nugget.
    re_select = remap( selection );
    re_select_s = remap_s( selection );
    if ~isempty( common )
        B_b = weight( remap( common_cnts >= 1 ), re_select_s );
    else
        B_b = [];
    end
    
    B_d = weight( re_select, re_select_s );
    I = diagonalIndices( length(B_d) );
    B_d(I) = (1 + (cnts(selection)-1)*mix_term)./cnts(selection); % mixing corrections
    
    % Target weights for active stations
    fx = [find( common_cnts ); find(selection)];
    A1 = target_map( :, remap( fx ) );
    A1 = double( A1 );
    B_b = double( B_b );
    B_d = double( B_d );
    
    if ~table_mode
        % Compute A1*inv(B).
        if ~isempty( common )
            Bi2 = invWithPartial2( B_b, B_d, Bi );
        else
            Bi2 = inv( B_d );
        end
        f_weights_map = A1*Bi2;    
        clear Bi2;
    else        
        % Compute A1/B.
        if ~isempty( Bi )
            % Quick division with known partial inverse
            f_weights_map = mldivideWithParitalInverse2( B_b, ...
                B_d, A1', Bi' )';
        else
            % We do direct division when the common portion is too small to
            % be worth worrying about.
            f_weights_map = A1/B_d;
        end
    end
    clear A1 B_b B_d;
    
    if ~table_mode       
        tot1 = sum( f_weights_map, 2 );
        rem = (1 - tot1);
        fr = ( tot1 < options.SpatialMapsEmptyCellCut ); % Remove locations with negligible data
        f_weights_map(fr, :) = 0;        
    end
    
    cnts = [common_cnts( common_cnts >= 1 )', cnts( selection )'];
    f_weights_map = bsxfun( @rdivide, double( f_weights_map ), cnts );
    
    if ~table_mode
        ss = abs(f_weights_map);
        mx = max( ss, [],  2 );
        sm = sum( ss, 2 );
        sm( sm > 1 ) = 1;
        mx( mx < rem ) = rem( mx < rem );
        ct = min( [options.SpatialMapsTrivialMaxCut*mx, ...
            options.SpatialMapsTrivialSumCut*sm], [], 2 );
        clear mx rem;
        
        ll = bsxfun( @lt, ss, ct );  % Cut level to remove low significance terms
        f_weights_map( ll ) = 0;
        clear ct ll;
        
        tot2 = f_weights_map*cnts';
        needed = tot1 - tot2;
        ss = abs(f_weights_map);
        sm = sum( ss, 2 );
        sm( sm == 0 ) = 1;
        
        adj = bsxfun( @times, ss, needed./sm );
        f_weights_map = f_weights_map + adj; % renormalize
        clear tot1 tot2 ss sm adj;
    end
    
    if ~table_mode
        % Store in spatial table
        temp_reduced = sparse( len_M, len_W );
        indices = [find( common_cnts >= 1 ); find( selection )];
        temp_reduced( :, indices ) = f_weights_map;
        clear f_weights_map;
        
        temp_full = sparse( len_M, length(expand_map) );
        temp_full(:, f) = temp_reduced( :, expanded );
        temp_full(:, common) = temp_reduced( :, expand_map( common ) );
        clear temp_reduced;
        
        [a,b,s] = find( temp_full );
        clear temp_full;
        
        t = ones( size(a), 'uint16' )*(index(j));
        a = uint16( a );
        b = uint32( b );
        s = single( s );
        
        exports1{j} = [t,a];
        exports2{j} = b;
        exports3{j} = s;
    else
        % Store in spatial table
        temp_reduced = zeros( len_M, len_W );
        indices = [find( common_cnts >= 1 ); find( selection )];
        temp_reduced( :, indices ) = f_weights_map;
        
        temp_full = zeros( len_M, length(expand_map) );
        temp_full(:, f) = temp_reduced( :, expanded );
        temp_full(:, common) = temp_reduced( :, expand_map( common ) );
        
        exports1{j} = temp_full';
        exports2{j} = [];
        exports3{j} = [];
    end
end


function spatial_map = attachSpatialMap( A, B, C, spatial_map )

% Converts Kriging coefficients indexed by time to a system indexed by
% station and compresses the result.

[B, I] = sort( B );

len_C = length(C);
if len_C == 0
    return;
end

breaks = find( diff(B) > 0 );
breaks = unique([1,breaks'+1,len_C]);

min_size = memSize( zipMatrix );

for k = 1:length(breaks)-1
    pos2 = breaks(k);
    next_pos2 = breaks(k+1)-1;
    if B(pos2) == 0
        continue;
    end
    
    % Perform A and C sections separately to avoid having both expanded at
    % the same time.
    if isempty( spatial_map{ B(pos2) } )
        A2 = A(I(pos2:next_pos2), 1:2);
    else
        A2 = [expand( spatial_map{B(pos2)}{1} ); A(I(pos2:next_pos2), 1:2)];
    end
    if length(A2)*2 > min_size
        A2x = zipMatrix( A2 );
        if memSize(A2x) < length(A2)*2
            A2 = A2x;
        else
            clear A2x;
        end
    end
    
    if isempty( spatial_map{ B(pos2) } )
        C2 = C(I(pos2:next_pos2));
    else
        C2 = [expand( spatial_map{B(pos2)}{2} ); C(I(pos2:next_pos2))];
    end
    if length(C2)*4 > min_size
        C2x = zipMatrix( C2 );
        if memSize(C2x) < length(C2)*4
            C2 = C2x;
        else
            clear C2x;
        end
    end
    
    spatial_map{B(pos2)}(1:2) = { A2, C2 };
end


function parSave( fname, item )
% Parallel save function wrapper
checkPath( fname );
save( fname, '-v7.3', 'item' );


function item = parLoad( fname )
% Parallel load function wrapper
if ~exist( fname, 'file' )
    error('File doesn''t exist');
end
item = load( fname, 'item' );
item = item.item;


function saveSpatialMap( dir, hash, map )
% Caching of map mode result

if matlabPoolSize > 1
    spmd
        if labindex == 1
            fname = [dir filesep() num2str( hash ) '.par.mat'];
            parSave( fname, getCodistributor( map ) );
        end
        fname = [dir filesep() num2str( hash ) '.' num2str( labindex ) '.mat'];
        checkPath( fname );
        
        parSave( fname, getLocalPart( map ) );
    end
else
    fname = [dir filesep() num2str( hash ) '.all.mat'];
    save( fname, '-v7.3', 'map' );
end


function map = loadSpatialMap( dir, hash )
% Load map mode result from cache.

if matlabPoolSize > 1
    fname = [dir filesep() num2str( hash ) '.par.mat'];
    distrib = parLoad( fname );
    spmd
        fname = [dir filesep() num2str( hash ) '.' num2str( labindex ) '.mat'];
        localPart = parLoad( fname );
        
        map = codistWrapper( localPart, distrib );
    end
else
    fname = [dir filesep() num2str( hash ) '.all.mat'];
    A = load( fname, '-v7.3', 'map' );
    map = A.map;
end
