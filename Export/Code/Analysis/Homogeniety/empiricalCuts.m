function [se2, sites2, back_map, start_pos] = empiricalCuts( se, sites, options )
% [se2, sites2, back_map, start_pos] = empiricalCuts( se, sites, options )
%
% Algorithm to make breakpoints by looking at neighbors

temperatureGlobals;
session = sessionStart;

if nargin < 3
    options = BerkeleyAverageOptions;
end

sessionSectionBegin( 'Scalpel Method Empirical Cuts' );
sessionWriteLog( ['Called with ' num2str( length(sites) ) ' stations'] );

frc = sessionFunctionCache;

pts = [sites(:).location];

% Load options
selected = options.ScalpelEmpiricalBestPairs;
consider = options.ScalpelEmpiricalMaxPairs;
max_dist = options.ScalpelEmpiricalMaxDistance;
primary_cut = options.ScalpelEmpiricalCut; 
segment_length = options.ScalpelEmpiricalMaxSegment;

% Attempt to load results from cache
hash = collapse( [collapse( md5hash( se ) ), collapse( md5hash( sites ) ), ...
    md5hash( [selected, consider, max_dist, primary_cut, segment_length] )] );
result = get( frc, hash );
if ~isempty( result )
    se2 = result{1};
    sites2 = result{2};
    back_map = result{3};
    start_pos = result{4};
    sessionWriteLog( [num2str( length(sites2) ) ' stations loaded from cache'] );
    sessionSectionEnd( 'Scalpel Method Empirical Cuts' );
    return;
end

bf = options.BadFlags;

data_struct = struct();
data_struct.dates = [];
data_struct.data = [];
data_struct.lims = [0,0];
data_struct(length(se)) = data_struct(1);

truly_bad = false( length(se), 1 );
parfor k = 1:length(se)
    [dates, data] = getData( se(k), bf );
    if length( dates ) < 12 % Minimum comparison
        truly_bad(k) = true;
    end
    
    dates_c = zipMatrix( dates );
    data_c = zipMatrix( data );
    
    if memSize( dates_c )*5 > 8*length(dates)
        dates_c = dates;
    end
    if memSize( data_c )*5 > 8*length(data)
        data_c = data;
    end
    data_struct(k).data = data_c;
    data_struct(k).dates = dates_c;
    data_struct(k).lims = [min(dates), max(dates)];
end
    
% Build distance map
if ~options.ClusterMode
    block_size = 1000;
else
    block_size = 50000;
end

x = [pts(:).x];
y = [pts(:).y];
z = [pts(:).z];

sessionSectionBegin( 'Distance Mapping' );

neighbor_list = cell( length(pts), 1 );
for block = 1:block_size:length(pts) - 1
    timePlot2( 'Distance Mapping', block / length(pts) );
    max_block = min( block + block_size - 1, length(pts) - 1 );
    parfor k = block:max_block
        % Flat Earth Approximation is computationally faster and makes an
        % error of only ~1% at 2500 km
        distances = ((x-x(k)).^2 + ...
            (y-y(k)).^2 + (z-z(k)).^2).^(1/2);
        
        distances( k ) = NaN; % Don't match on yourself
    
        neighborhood = find(distances < max_dist & ~truly_bad');
        
        [~, I] = sort( distances(neighborhood) );
        neighborhood = neighborhood(I);

        % For computational simplicity, only consider a limited selection of
        % the nearby station.
        if length(neighborhood) > consider
            neighborhood = neighborhood( 1:consider );
        end

        neighbor_list{k} = neighborhood;
    end
end
timePlot2( 'Distance Mapping', 1 );

sessionSectionEnd( 'Distance Mapping' );

% Store break points
breaks = cell( length(pts), 1 );
step_size = 1000; 

sessionSectionBegin( 'Determine Cuts' );

for block = 1:step_size:length(pts)
    timePlot2( 'Determine Cuts', block/length(pts) );
    
    max_block = min( length(pts), block+step_size - 1 );
    
    % Loop over each location, find neighbors, and check from inhomogenuity.
    neighbor_group = cell( length( pts ), 1 );
    for k = block:max_block
        neighbor_group{k} = data_struct( neighbor_list{k} );
    end
    
    parfor k = block:max_block
        neighbors = length(neighbor_group{k});
        
        % Dates we are making comparison to
        [target_dates, target_data] = getData( se(k) );
        
        near_map = zeros( length(target_dates), neighbors ).*NaN;
        bad = zeros(neighbors, 1);
        r = zeros(neighbors, 1);
        
        tmin = min(target_dates);
        tmax = max(target_dates);
        
        % Loop over neighbors and determine quality of relationship.
        for j = 1:neighbors
            dmin = neighbor_group{k}(j).lims(1);
            dmax = neighbor_group{k}(j).lims(2);
                       
            if dmin > tmax || dmax < tmin
                bad(j) = 1;
                continue;
            end
            
            dates = expand( neighbor_group{k}(j).dates );
            [~,IA,IB] = intersect( dates, target_dates );
            
            if length(IA) < 12 % Minimum comparison threshold.
                bad(j) = 1;
            else
                data = expand( neighbor_group{k}(j).data );                
                near_map( IB, j ) = data(IA); % Store data in comparison structure.
                r(j) = correlate( diff(data(IA)), diff(target_data(IB)) );
                if r < 0 
                    bad(1) = 1;
                end
            end
        end
        r( logical(bad) ) = [];
        
        near_map(:,logical(bad)) = [];
        good = neighbors - sum(bad);
        if good < 3
            continue;  % No useful neighbors, exit early.
        end
        
        % Organize comparisons by correlation, high correlation first.
        [~,I] = sort(r);
        near_map = near_map(:, I(end:-1:1));

        weights = (r(I(end:-1:1)).^2)';
        
        % Perform local diff and difference to target series.
        near_map2 = bsxfun( @minus, near_map, target_data );
        near_map2(:, end+1) = -target_data;
        alignment = alignData(near_map2);
        near_map2 = bsxfun( @minus, near_map2, alignment);
        nominal = near_map2(:, end);
        near_map2 = near_map2(:, 1:end-1);
        
        access_map = ~isnan( near_map2 );
        expectation = target_data.*NaN;
        for j = 1:length(target_data)
            f = find(access_map( j, : ));
            if length(f) < 3
                expectation(j) = nominal(j);
                continue; % Require at least 3 pairwise comparisons be available.
            end
            
            [~, I] = sort( near_map2(j,f) );
            ll = floor( length(I)/3 )+1;
            ul = ceil( length(I)*2/3 );                        
            f = f(I( ll:ul ) );
            
            expectation(j) = sum(weights(f).*near_map2(j,f))./sum(weights(f));
        end        
                
        index_map = 1:length( expectation );
        mask = isnan( expectation );
        
        expectation( mask ) = [];
        index_map( mask ) = [];
                
        breaks{k} = index_map( changePointDetection( expectation, primary_cut, segment_length ) );
    end
end
timePlot2( 'Determine Cuts', 1 );
sessionSectionEnd( 'Determine Cuts' );

total = 0;
for k = 1:length(se)
    if isempty( breaks{k} )
        total = total + 1;
    else
        total = total + length(breaks{k}) + 1;
    end
end

% Perform the actual cutting.
cnt = 1;
se2 = stationElement2;
sites2 = stationSite2;
se2(1:total) = se2;
sites2(1:total) = sites2;
back_map = zeros( total, 1 );
start_pos = back_map;

sessionSectionBegin( 'Make Cuts' );

for k = 1:length(se)
    if mod( k, 20 ) == 0
        timePlot2('Make Cuts', k / length(se) );
    end
    if isempty( breaks{k} )
        se2(cnt) = se(k);
        sites2(cnt) = sites(k);
        back_map(cnt) = k;
        start_pos(cnt) = 1;
        cnt = cnt + 1;
    else
        last = 1;
        start = cnt;
        for j = 1:length(breaks{k})
            if breaks{k}(j) - last + 1 >= 6
                se2(cnt) = select( se(k), last:breaks{k}(j) );
                start_pos(cnt) = last;
                last = breaks{k}(j) + 1;
                cnt = cnt + 1;
            end
        end
        if numItems(se(k)) >= last
            se2( cnt ) = select( se(k), last:numItems( se(k) ) );
            start_pos(cnt) = last;
            back_map(start:cnt) = k;            
            sites2( start:cnt ) = sites(k);
            cnt = cnt + 1;
        else
            sites2( start:cnt-1 ) = sites(k);
            back_map( start:cnt - 1 ) = k;
        end            
    end
end
timePlot2('Make Cuts', 1 );

se2(cnt:end) = [];
sites2(cnt:end) = [];
back_map(cnt:end) = [];
start_pos(cnt:end) = [];

sessionSectionEnd( 'Make Cuts' );

parfor k = 1:length(se2)
    se2(k) = compress(se2(k));
end

save( frc, hash, {se2, sites2, back_map, start_pos} );
        
sessionWriteLog( [num2str( length(sites2) ) ' records in result'] );
sessionSectionEnd( 'Scalpel Method Empirical Cuts'  );

