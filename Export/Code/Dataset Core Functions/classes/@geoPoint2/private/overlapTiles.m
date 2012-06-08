function result = overlapTiles( pts )

lat = [pts.latitude]';
long = [pts.longitude]';
elev = [pts.elevation]';

offset = 0;
range = 1e6;
for k = 1:length(long)
    long2 = mod( long + long(k), 360 );
    range2 = max(long2) - min(long2);
    if range2 < range
        offset = long(k);
        range = range2;
    end
end

long = mod( long + offset, 360 );
    
lat_error = [pts.lat_uncertainty]';
long_error = [pts.long_uncertainty]';
elev_error = [pts.elev_uncertainty]';

f = isnan( elev ) | isnan( elev_error );
elev(f) = [];
elev_error(f) = [];

source_set = [long - long_error, lat - lat_error, ...
    long + long_error, lat + lat_error];

tiles = zeros(100,4);
tc = size(source_set,1);
tiles(1:tc,:) = source_set;

scales = zeros( tc, 2 );
for k = 1:tc
    scales( k, : ) = [tiles(k,3) - tiles(k,1), tiles(k,4) - tiles(k, 2)];
end

max_vals = zeros( tc, 1 );
rescale = zeros( tc, 2 );

tile_owners = cell( 100, 1 );
for k = 1:tc
    tile_owners{k} = k;
end

tile_start = 1;

while tile_start < tc
    tile_target = tile_start + 1;
    
    while tile_target <= tc
        tile1 = tiles( tile_start, : );
        tile2 = tiles( tile_target, : );
        
        if (tile1(1) < tile2(1) && tile1(3) <= tile2(1)) || ...
                (tile1(1) >= tile2(3) && tile1(3) > tile2(3)) || ...
                (tile1(2) < tile2(2) && tile1(4) <= tile2(2)) || ...
                (tile1(2) >= tile2(4) && tile1(4) > tile2(4)) 
            tile_target = tile_target + 1;
            continue;
        end                           
        
        [region1, region2, intersect] = ...
            breakOverlap( tiles(tile_start,:), tiles(tile_target,:) );
                
        new_tiles = [region1; region2; intersect];
        new_source = cell( size(new_tiles, 1), 1 );
        for k = 1:size(region1,1)
            new_source{k} = tile_owners{tile_start};
        end
        for k = 1:size(region2,1)
            new_source{k+size(region1,1)} = tile_owners{tile_target};
        end
        join = union( tile_owners{tile_start}, tile_owners{tile_target} );
        for k = 1:size(intersect,1)
            new_source{k+size(region1,1)+size(region2,1)} = ...
                join;
        end
        
        tiles( tile_start, : ) = new_tiles( 1, : );
        tile_owners{ tile_start } = new_source{1};
        
        if size( new_tiles, 1 ) > 1
            tiles( tile_target, : ) = new_tiles( 2, : );
            tile_owners{ tile_target } = new_source{2};
        else
            tiles( tile_target, : ) = [];
            tile_owners( tile_target ) = [];
            tc = tc - 1;            
            continue;
        end
        
        tiles( tc + 1:tc + size( new_tiles, 1 ) - 2, : ) = ...        
            new_tiles(3:end,:);
        tile_owners( tc + 1:tc + size( new_tiles, 1 ) - 2 ) = ...
            new_source(3:end);
        tc = tc + size( new_tiles, 1 ) - 2;
        
        if tc == size(tiles,1)
            tiles(end+1:end+100,:) = 0;
            tile_owners{end+100} = [];
        end
        
        tile_target = tile_start + 1;
    end
    
    tile_start = tile_start + 1;
end

tiles( tc+1:end, : ) = [];

for k = 1:tc
    to = tile_owners{k};
    cnt = length(to);
    f = ( max_vals( to ) < cnt );
    max_vals(to(f)) = cnt;
    rescale( k, : ) = min( scales( to, : ), [], 1 );
end
      
bad = false( tc, 1 );
for k = 1:tc
    to = tile_owners{k};
    cnt = length(to);
    if ~any( max_vals(to) == cnt )
        bad(k) = true;
    end
end

tiles(bad,:) = [];
rescale(bad,:) = [];

new_tiles = zeros( size(tiles) );
for k = 1:size( tiles, 1 )
    x = (tiles(k,1) + tiles(k,3))/2;
    y = (tiles(k,2) + tiles(k,4))/2;
    new_tiles(k,:) = [x - rescale(k,1)/2, y - rescale(k,2)/2, ...
        x + rescale(k,1)/2, y + rescale(k,2)/2];
end

intersect_set = [min(new_tiles(:,1)), min(new_tiles(:,2)), ...
    max(new_tiles(:,3)), max(new_tiles(:,4))];

new_long = (intersect_set(1) + intersect_set(3))/2;
new_lat = (intersect_set(2) + intersect_set(4))/2;
new_long_unc = (intersect_set(3) - intersect_set(1))/2;
new_lat_unc = (intersect_set(4) - intersect_set(2))/2;


if isempty( elev )
    new_elev = NaN;
    new_elev_unc = NaN;
elseif length( elev ) == 1
    new_elev = elev;
    new_elev_unc = elev_error;
else
    elev_list = [elev - elev_error, elev + elev_error];
    elev_pts = unique( elev_list(:) );
    usage = zeros( length(elev_pts) - 1, length(elev) );
        
    for k = 1:length(elev)
        for j = 1:length(elev_pts) - 1
            if elev_pts(j) >= elev_list(k,1) && elev_pts(j+1) <= elev_list(k,2)
                usage(j,k) = 1;
            end
        end
    end
    usage_max = sum(usage,2);
    
    used = zeros( length(elev), 1 );
    for k = 1:length(elev)
        items = ( usage( :, k ) == 1 );
        used(k) = max( usage_max( items ) );
    end
    
    needed = false( length(elev_pts) - 1, 1 );
    for k = 1:length(needed)
        items = ( usage( k, : ) == 1 );
        if any( used( items ) == usage_max( k ) )
            needed( k ) = true;
        end
    end
    
    f = find(needed);
    min_elev = elev_pts(f(1));
    max_elev = elev_pts(f(end)+1);
    
    new_elev = (max_elev + min_elev) / 2;
    new_elev_unc = (max_elev - min_elev) / 2;
    
    if new_elev_unc < min(elev_error)
        new_elev_unc = min(elev_error);
    end
end

result = geoPoint2( new_lat, new_long - offset, new_elev, ...
    new_lat_unc, new_long_unc, new_elev_unc );


function [region1, region2, intersect] = breakOverlap( tile1, tile2 )

xs = [tile1([1,3]), tile2([1,3])];
ys = [tile1([2,4]), tile2([2,4])];

xs = sort(xs);
ys = sort(ys);

new_tiles = [
    xs(1), ys(1), xs(2), ys(2);
    xs(1), ys(2), xs(2), ys(3);
    xs(1), ys(3), xs(2), ys(4);
    xs(2), ys(1), xs(3), ys(2);
    xs(2), ys(2), xs(3), ys(3);
    xs(2), ys(3), xs(3), ys(4);
    xs(3), ys(1), xs(4), ys(2);
    xs(3), ys(2), xs(4), ys(3);
    xs(3), ys(3), xs(4), ys(4);
    ];

region1 = zeros(9,4);
region2 = zeros(9,4);
intersect = zeros(9,4);

c1 = 0;
c2 = 0;
c3 = 0;

for k = 1:9
    tile = new_tiles(k,:);
    if tile(1) == tile(3) || tile(2) == tile(4)
        continue;
    end
        
    if tile(1) >= tile1(1) && tile(3) <= tile1(3) && ...
            tile(2) >= tile1(2) && tile(4) <= tile1(4)
        in1 = true;
    else
        in1 = false;
    end
        
    if tile(1) >= tile2(1) && tile(3) <= tile2(3) && ...
            tile(2) >= tile2(2) && tile(4) <= tile2(4)
        in2 = true;
    else
        in2 = false;
    end
    
    if in1 && in2 
        c3 = c3 + 1;
        intersect( c3,: ) = tile;
    elseif in1
        c1 = c1 + 1;
        region1( c1,: ) = tile;
    elseif in2
        c2 = c2 + 1;
        region2( c2,: ) = tile;
    end
    
end

intersect = intersect( 1:c3, : );
region1 = region1( 1:c1, : );
region2 = region2( 1:c2, : );

    
    