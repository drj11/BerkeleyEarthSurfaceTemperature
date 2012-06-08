function [mask, elev] = makeLandMask( resolution, second )
% mask = makeLandMask( resolution )
% mask = makeLandMask( latitude, longitude )
%
% Creates a latitude-longitude map reporting the fraction of each cell
% that is land.

temperatureGlobals;
session = sessionStart;

frc = sessionFunctionCache();
if nargin == 1
    A = get( frc, resolution );
    if ~isempty(A)
        mask = A{1};
        elev = A{2};
        return;
    end
else
    hash = collapse( [md5hash( resolution ), md5hash( second )] );
    A = get( frc, hash );
    if ~isempty(A)
        mask = A{1};
        elev = A{2};
        return;
    end
end
   
seg = loadCoastline( which( 'gshhs_l.b' ) );

if nargin > 1
    latitude = resolution;
    longitude = mod( second, 360 );
    
    step = round( 45 / (sqrt( 360*180 / length(latitude) ) ) )*40;
    resolution = 360 / step;
end
    
lat = 90-resolution/2:-resolution:-90+resolution/2;
long = resolution/2:resolution:360-resolution/2;

[LAT, LONG] = meshgrid( lat, long );

mask = zeros( size(LAT), 'single' );

handle = figure;
set(handle, 'MenuBar', 'none', 'ToolBar', 'none' );

center = 0;

step = 10;
sz = [360/resolution, 180/resolution];

if sz(1) < 100
    sz = sz*5;
    step = 50;
elseif sz(1) < 200
    sz = sz*2;
    step = 20;
elseif sz(1) > 2000
    sz = sz / 5;
    step = 2;
elseif sz(1) > 1000
    sz = sz / 2;
    step = 5;
end

set( handle, 'position', [200,200, sz(1), sz(2)] );

set(gcf, 'color', [1,1,1]);

levels = [seg(:).level];
[~,I] = sort(levels);
seg = seg(I);

for k = 1:length(seg)
    if (seg(k).level == 1 && seg(k).area > 1000) || (seg(k).level == 2 && seg(k).area > 10000) ...
            || (seg(k).level == 3 && seg(k).area > 1000)
        if seg(k).level == 1 || seg(k).level == 3
            col = [0, 0, 0];
        else
            col = [1,1,1];
        end
        points = seg(k).points;
        points(end+1,:) = points(1,:);
        
        points(:,1) = mod(points(:,1) - center,360);
        
        f = find(abs(diff(points(:,1))) > 100);
        if seg(k).id == 4
            points = seg(k).points;
            points2 = points;
            points3 = points;
            points2(:,1) = points2(:,1) + 360;
            points3(:,1) = points3(:,1) - 360;
            points2(1,2) = -90;
            points3(end,2) = -90;
            points = [points2; points; points3];
            points(:,1) = points(:,1) + mod(-center,360);
            
            points = clip(points);
            patch(points(:,1),points(:,2),col, 'edgecolor', 'none');
            hold on            
        elseif isempty(f)
            points = clip(points);
            patch(points(:,1),points(:,2),col, 'edgecolor', 'none');
            hold on
        else
            for div = 1:359
                if min(abs(points(:,1)-div)) > 20
                    break;
                end
            end
            
            points2 = points;
            f = find(points2(:,1) > div);
            points2(f,1) = points2(f,1) - 360;
            points2 = clip(points2);
            patch(points2(:,1),points2(:,2),col, 'edgecolor', 'none');
            hold on
            
            points2 = points;
            f = find(points2(:,1) < div);
            points2(f,1) = points2(f,1) + 360;
            points2 = clip(points2);
            patch(points2(:,1),points2(:,2),col, 'edgecolor', 'none');
            hold on
        end
    end
end

set(gca, 'position', [0,0,1,1], 'visible', 'off');
setxmax(360);
setxmin(0);
setymax(90);
setymin(-90);


for m = 1:100/step
    for n = 1:100/step
        set(gca, 'position', [(1-m), (1-n), 100/step, 100/step]);
        I = getframe( handle );
        im = frame2im( I );
        im = squeeze( ~any( im, 3 ) )';
        
        sz2 = size(im);
        xselect = ceil( (1:10:sz2(1))/10 ) + floor( sz2(1)*(m-1)/10 );
        yselect = ceil( (1:10:sz2(2))/10 ) + floor( sz2(2)*((100/step)-n)/10 );        
                
        for k = 1:10
            for j = 1:10
                mask(xselect, yselect) = mask(xselect, yselect) + im(k:10:end,j:10:end);
            end
        end
    end
end
mask = mask / 100;

close(handle);

load simpleDem;

if nargin > 1
    map_pts = geoPoint2( LAT(:), LONG(:) );
    map_pts2 = geoPoint2( latitude, longitude );
    
    X = [map_pts(:).x];
    Y = [map_pts(:).y];
    Z = [map_pts(:).z];
        
    X2 = [map_pts2(:).x];
    Y2 = [map_pts2(:).y];
    Z2 = [map_pts2(:).z];
    index = 1:length(map_pts2);    
    
    F = TriScatteredInterp( X2', Y2', Z2', index', 'nearest' );
    N = round( F( X, Y, Z ) );
    
    mask2 = zeros( length( map_pts2 ), 1 );
    for k = 1:length( map_pts2 )
        f = ( N == k );
        mask2(k) = mean( mask(f) );
    end
    
    mask = mask2';

    width = floor( length(sd_lat) / length(lat) );

    lat2 = zeros( length(sd_lat)/width, 1 );
    long2 = zeros( length(sd_long)/width, 1 );
        
    for k = 1:width
        lat2 = lat2 + sd_lat(k:width:end);
        long2 = long2 + sd_long(k:width:end);
    end
    lat2 = lat2 / width;
    long2 = long2 / width;

    means2 = zeros( size(sd_means) / width, 'single' );

    for k = 1:width
        for j = 1:width
            A = sd_means(k:width:end, j:width:end);
            means2 = means2 + single(A);
        end
    end
    
    means2 = means2 / width.^2;
    
    [LAT2, LONG2] = meshgrid( lat2, long2 );
    map_pts = geoPoint2( LAT2(:), LONG2(:) );
    
    X = [map_pts(:).x];
    Y = [map_pts(:).y];
    Z = [map_pts(:).z];
            
    N = round( F( X, Y, Z ) );
    
    means2  = means2'+0;
    elev = zeros( length( map_pts2 ), 1 );
    for k = 1:length( map_pts2 )
        f = ( N == k );
        elev(k) = mean( means2(f) );
    end
    
    elev = elev';    
    
    save( frc, hash, {mask, elev} );
else
    mask = mask';
    mask = mask( end:-1:1, : );
    
    sd_long = mod( sd_long, 360 );
    
    lat_map = sd_lat.*0;
    long_map = sd_long.*0;
    for k = 1:length(sd_lat)
        lat_map(k) = findk( sd_lat(k), lat );
    end
    for k = 1:length(sd_long)
        long_map(k) = findk( sd_long(k), long );
    end
    cnt = mask.*0;
    elev = mask.*0;
    for k = 1:length(sd_lat)
        for j = 1:length(sd_long)
            elev( lat_map(k), long_map(j) ) = elev( lat_map(k), long_map(j) ) + sd_means( k,j );
            cnt( lat_map(k), long_map(j) ) = cnt( lat_map(k), long_map(j) ) + 1;
        end
    end
    elev = elev ./ cnt;
    elev = elev( end:-1:1, : );
    
    save( frc, resolution, {mask, elev} );
end



function points = clip(points)

f = find(points(:,1) > 360);
points(f,1) = 360;
f = find(points(1:end-2,1) == 360 & points(2:end-1,1) == 360 & points(3:end,1) == 360);
points(f+1,:) = [];

f = find(points(:,1) < 0);
points(f,1) = 0;
f = find(points(1:end-2,1) == 0 & points(2:end-1,1) == 0 & points(3:end,1) == 0);
points(f+1,:) = [];