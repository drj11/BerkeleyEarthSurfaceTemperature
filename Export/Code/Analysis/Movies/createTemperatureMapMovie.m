function createTemperatureMapMovie( results, start, step, name, type )

map_points = results.map_pts;
map = results.map;
coverage_map = results.coverage_map;
occ_table = results.occurence_table;
coverage_summary = results.coverage_summary;
switch lower(type)
    case 'monthly'
        times = results.times_monthly;
        mean_values = results.values_monthly;
        times2 = results.times_monthly;
        values2 = results.values_monthly;
        unc_values = results.uncertainty_monthly;
        avg_scale = 1;
        label1 = 'Monthly average';
        label2 = 'Stations';
        label3 = 'Moving';
        adj = 1;
        clim = [-10,10];
        ymark = [-10, -4, -2, -1, 0, 1, 2, 4, 10];
    case 'annual'
        times = results.times_monthly;
        mean_values = results.values_monthly;
        times2 = results.times_annual;
        values2 = results.values_annual;
        unc_values = results.uncertainty_annual;
        avg_scale = 12;
        label1 = '12-month moving average';
        label2 = 'Stations-Years';
        label3 = 'Annual moving';
        adj = 1;
        clim = [-6,6];
        ymark = [-6, -2, -1, -0.5, 0, 0.5, 1, 2, 6];
    case 'five_year'
        times = results.times_monthly;
        mean_values = results.values_monthly;
        times2 = results.times_five_year;
        values2 = results.values_five_year;
        unc_values = results.uncertainty_five_year;
        avg_scale = 60;
        label1 = '5-year moving average';
        label2 = 'Stations-Years';
        label3 = 'Five-year moving';
        adj = 5;
        clim = [-4,4];
        ymark = [-4, -2, -1, -0.5, 0, 0.5, 1, 2, 4];
    case 'ten_year'
        times = results.times_monthly;
        mean_values = results.values_monthly;
        times2 = results.times_ten_year;
        values2 = results.values_ten_year;
        unc_values = results.uncertainty_ten_year;
        avg_scale = 120;
        label1 = '10-year moving average';
        label2 = 'Stations-Decades';
        label3 = 'Ten-year moving';
        adj = 1;
        clim = [-6,6]/2;
        ymark = [-6, -2, -1, -0.5, 0, 0.5, 1, 2, 6]/2;
    case 'twenty_year'
        times = results.times_monthly;
        mean_values = results.values_monthly;
        times2 = results.times_twenty_year;
        values2 = results.values_twenty_year;
        unc_values = results.uncertainty_twenty_year;
        avg_scale = 240;
        label1 = '20-year moving average';
        label2 = 'Stations-Decades';
        label3 = 'Twenty-year moving';
        adj = 2;
        clim = [-6,6]/2;
        ymark = [-6, -2, -1, -0.5, 0, 0.5, 1, 2, 6]/2;
    otherwise
        error( 'Undefined type' );
end
unc_times = times2;

temperatureStartup;
session = sessionStart;

if ~exist( 'start', 'var' )
    start = min(times);
end
if ~exist( 'step', 'var' )
    step = 4;
end
if exist( 'name', 'var' )
    vidObj = VideoWriter([temperature_document_dir 'Private Documents' ...
        psep 'Animation' psep name '.avi'], 'Motion JPEG AVI');
    vidObj.FrameRate = 20;
    open(vidObj);
    
    save_video = true;
    %step = 1;
else
    save_video = false;
end

target_figure = gwFigure;
main_panel = subplot(2,1,1);

f1 = ( times > 1950 & times < 1980 & ~isnan(mean_values) );
baseline = mean(mean_values(f1));
ff = ( times2 > start );

if results.options.GridSize == 16000
    cache = load( 'mask16000' );
    areal_weight = cache.mask;
else
    areal_weight = makeLandMask( results.options.GridSize );
end

track_panel = subplot(2,1,2);

f = isnan(unc_values) | unc_times <= start;
unc_times(f) = [];
unc_values(f) = [];

[~, I1, I2] = intersect( times2, unc_times );
patch( [unc_times(I2); unc_times(I2(end:-1:1))], ...
    [values2(I1) + 2*unc_values(I2); values2(I1(end:-1:1)) - 2*unc_values(I2(end:-1:1))] - baseline, ...
    [0.8,0.8,0.8], 'edgecolor', 'none' );
hold on

plot(times2(ff), values2(ff) - baseline );
setxmax(2015);

swing = (max(values2(ff)) - min(values2(ff))) / 2;
setymax(  max(values2(ff) - baseline) + 0.15*swing );
setymin( min(values2(ff) - baseline) - 0.15*swing )
setxmin(start);

xlim = get( gca, 'xlim' );
ylim = get( gca, 'ylim' );
plot( [xlim(1), xlim(1), xlim(2), xlim(2), xlim(1)], ...
    [ylim(1), ylim(2), ylim(2), ylim(1), ylim(1)], 'k-' );
plot( [xlim(1), xlim(2)], [0,0], 'k:' );

dot = plot( times2(1), values2(1) - baseline, 'r.', 'markersize', 4 );
set(gca, 'yaxislocation', 'right', 'tickdir', 'out', 'box', 'off', 'fontsize', 12, ...
    'ticklength', [0.007, 0]);
ylabel( 'Anomaly (C)' );

ylim = get( gca, 'ylim' );
text( 2013, (ylim(2)-ylim(1))*0.15+ylim(1), [label3 ' land-surface average, 2-sigma uncertainty'], ...
    'horizontalalignment', 'right' );

set( gca, 'position', [0.04, 0.07, 0.88, 0.17] );
set( main_panel, 'position', [0.04, 0.28, 0.9, 0.60] );

axes(main_panel);

cmap = jet(200);

f = ( map > max(clim) );
map(f) = max(clim);
f = ( map < min(clim) );
map(f) = min(clim);

mask_color = [0.8, 0.8, 0.8];
outer_color = [0.6, 0.6, 0.6];


% Color scale remap
sz = size(cmap);
low = 1;
high = sz(1) - low;
corner = 0.4;
rate = -log(3)/(clim(1)*corner/2);

Y_index = clim(1):0.01:clim(2);
C_index = round(low + high./(1 + exp(-Y_index*rate)));

cmap( sz(1) + 1, :) = mask_color;
cmap( sz(1) + 2, : ) = outer_color;

% Data map
long = [map_points(:).long];
lat = [map_points(:).lat];

long = mod(long+180,360)-180;

th = 2*asin(2*lat*1/180);
for a = 1:100;
   th = th - (th + sin(th)-pi*sin(lat*pi/180))./(1+cos(th));
end
th = th/2;
X = 2*sqrt(2)*long/180.*cos(th);
Y = sqrt(2)*sin(th);

% Target map
[X2,Y2] = meshgrid(-3:0.008:3,-1.5:0.008:1.5);
X2 = X2';
Y2 = Y2';
mask = (X2(:).^2/4+Y2(:).^2 <= 2);
Z2 = X2(:).*0;
C2 = X2(:).*0;
D2 = X2(:).*0;
VC = [X2(:).*0];
VC(~mask) = sz(1) + 2;

X2 = X2(mask);
Y2 = Y2(mask);

mask2 = find(mask);

h_last = NaN;

start_k = findk( times2, start );
VC_field = cell( length( map( 1, : ) ), 1 );
for k = start_k:step:length( map( 1, : ) )-avg_scale+1
    if isempty( VC_field{k} )
        max_k = min( k + step*100, length( map( 1, : ) )-avg_scale+1 );
        for k2 = 1:k-1
            VC_field{k2} = [];
        end
        parfor k2 = k:max_k
            if mod( k2 - k, step ) ~= 0
                continue;
            end
            
            F = TriScatteredInterp( X(:), Y(:), X(:).*0 );

            Z2 = X2(:).*0;
            C2 = X2(:).*0;
            D2 = X2(:).*0;
            VCa = [X2(:).*0];
            VCa(~mask) = sz(1) + 2;
            
            V = mean(map( :, k2:k2+avg_scale - 1), 2 ) + mean(mean_values(k2:k2+avg_scale-1)) - baseline;
            C = mean(coverage_map( :, k2:k2+avg_scale - 1), 2 );
            D = sum( coverage_map( :, k2:k2+avg_scale - 1) > 0.1 , 2 );

            fa = ( C(:) > 0.01 ); 
            C = C.*areal_weight';
            if ~any(fa)
                fa = 1:length(C);
            end
            F.X(:,1:2) = [X(fa)', Y(fa)'];    
            F.V = double(C(fa));

            C2(mask) = F(X2, Y2);
            f1 = ( C2(mask) < 0.2 );

            F.V = double(D(fa));
            D2(mask2(~f1)) = F(X2(~f1), Y2(~f1));
            f2 = ( D2(mask) <= 8.5 * avg_scale/12 );

            F.V = double(V(fa));
            Z2(mask2(~f1 & ~f2)) = F(X2(~f1 & ~f2), Y2(~f1 & ~f2));
            VCa(mask) = round(interp1( Y_index, C_index, Z2(mask) ));

            VCa(mask2(f1 | f2)) = sz(1)+1;
            f3 = isnan( VCa );
            VCa(f3) = sz(1)+1;
            VC_field{k2} = VCa;
        end        
    end
    VC = VC_field{k};
        
    CT(:,:,1) = reshape( cmap(VC(:),1), 751, 376 )';
    CT(:,:,2) = reshape( cmap(VC(:),2), 751, 376 )';
    CT(:,:,3) = reshape( cmap(VC(:),3), 751, 376 )';
    
    if ~ishandle( h_last )
        h_last = image(-3:0.01:3,-1.5:0.01:1.5,CT);

        hold on
        MollweideCoastline(0);
        
        colormap(cmap);
        set(gca,'ytick',[], 'xtick',[], 'ydir', 'normal', 'clim', clim );

        th = 0:0.01:3*pi;
        x = 2*cos(th)*sqrt(2);
        y = sin(th)*sqrt(2);
        plot(x,y,'k-','linewidth',3);
        set(gca,'color','none');

        h = colorbar;
        set(h, 'ylim', [0.5, sz(1) + 0.5], 'tickdir', 'out', 'ticklength', [0.015, 0] );
        tmark = interp1( Y_index, C_index, ymark );
        set(h, 'ytick', tmark, 'yticklabel', ymark, 'fontsize', 14, 'linewidth', 2 );
        ylabel( h, 'Temperature Anomaly (C)', 'fontsize', 16 );
         
        tpos = interp1( Y_index, C_index, mean( mean_values(k:k+avg_scale-1) )-baseline );
        hold(h,'on');
        xlim = get( h, 'xlim' );
        marker = plot( xlim, [tpos, tpos], 'k', 'linewidth', 3, 'parent', h );
        
        text( -2.95, -1.35, { label1, 'Anomalies relative to 1950-1980 mean' }, 'fontsize', 10);
        text( -2.95, 1.82, label2, 'fontsize', 14 );
        text( 2.95, 1.82, 'Land Coverage', 'fontsize', 14, 'horizontalalignment', 'right');
        
        occ = sum( sum( occ_table( :, k:k+avg_scale-1 ) ) )/avg_scale*adj;
        per = mean( coverage_summary(k:k+avg_scale-1)*100 );
        
        occ_string = text( -2.95, 1.62, num2str(round(occ*10)/10), 'fontsize', 14 );
        per_string = text( 2.95, 1.62, [num2str(round(per*10)/10) '%'], 'fontsize', 14, 'horizontalalignment', 'right');
                
        tt = mean(times(k:k+avg_scale-1));
        yy = floor( tt );
        frac = tt - yy;
        tt_str = num2str(yy);
        frac_str = num2str( round(frac*100) / 100 );
        frac_str( 1 ) = [];
        if isempty( frac_str )
            frac_str = '.00';
        end
        if length( frac_str ) < 3
            frac_str(end+1:3) ='0';
        end
        
        yy_string = text( 0.2, 1.69, tt_str, 'fontsize', 28, 'horizontalalignment', 'right' );
        frac_string = text( 0.22, 1.66, frac_str, 'fontsize', 16 );       
        
        children = get( main_panel, 'children' );        
        
        pos = get( main_panel, 'position' );
        set( gcf, 'position', [200, 200, (6/0.008 + 1)/pos(3), (3/0.008 + 1)/pos(4)] );        
    else
        delete(h_last);
        h_last = image(-3:0.01:3,-1.5:0.01:1.5,CT, 'parent', main_panel);        
        children(end) = h_last;
        set( main_panel, 'children', children );

        tt = mean(times(k:k+avg_scale-1));
        yy = floor( tt );
        frac = tt - yy;
        tt_str = num2str(yy);
        frac_str = num2str( round(frac*100) / 100 );
        frac_str( 1 ) = [];
        if isempty( frac_str )
            frac_str = '.00';
        end
        if length( frac_str ) < 3
            frac_str(end+1:3) ='0';
        end
        
        set( yy_string, 'string', tt_str );
        set( frac_string, 'string', frac_str );       

        occ = sum( sum( occ_table( :, k:k+avg_scale-1 ) ) )/avg_scale*adj;
        per = mean( coverage_summary(k:k+avg_scale-1)*100 );

        set( occ_string, 'string', num2str(round(occ*10)/10) );
        set( per_string, 'string', [num2str(round(per*10)/10) '%']);

        tpos = interp1( Y_index, C_index, mean( mean_values(k:k+avg_scale-1) )-baseline );
        set( marker, 'ydata', [tpos,tpos] );

        delete( dot );
        dot = plot( times2(k), values2(k)-baseline, 'r.', 'markersize', 20, 'parent', track_panel );       
    end    
    
    drawnow;
    if save_video
        cur_frame = getframe( target_figure );
        writeVideo( vidObj, cur_frame );
        
        if k == start_k || k == length( map( 1, : ) )-avg_scale+1
            for m = 1:50
                writeVideo( vidObj, cur_frame );
            end
        end
    end
end
    
if save_video
    close( vidObj );
end

function MollweideCoastline(center)

persistent seg;
if isempty( seg )
    seg = loadCoastlineCoarse;
end
hold on        

persistent contour_list;
if isempty( contour_list )
    cnt = 1;
    contour_list = cell( length(seg), 1 );

    for k = 1:length(seg)
        if (seg(k).level == 1 && seg(k).area > 10000) || (seg(k).level == 2 && seg(k).area > 100000 && ~seg(k).river)
            points = seg(k).points;
            points(end+1,:) = points(1,:);

            points(:,1) = mod(points(:,1) - center + 180,360) - 180;        

            f = find(abs(diff(points(:,1))) > 100, 1);
            if seg(k).id == 4
                points = seg(k).points;
                points(:,1) = points(:,1) + mod(-center + 180,360) - 180;
                points2 = points;
                points3 = points;
                points2(:,1) = points2(:,1) + 360;
                points3(:,1) = points3(:,1) - 360;
                points = [points2; points; points3];

                points = clip(points);
                [X,Y] = MollweideContour(points);
                contour_list{ cnt } = [X,Y];
                cnt = cnt + 1;
            elseif isempty(f)
                points = clip(points);
                [X,Y] = MollweideContour(points);
                contour_list{ cnt } = [X,Y];
                cnt = cnt + 1;
            else
                for div = -180:180
                    if min(abs(points(:,1)-div)) > 20
                        break;
                    end
                end

                points2 = points;
                f = find(points2(:,1) > div);
                points2(f,1) = points2(f,1) - 360;
                points2 = clip(points2);
                [X1,Y1] = MollweideContour(points2);
                contour_list{ cnt } = [X1,Y1];
                cnt = cnt + 1;

                points2 = points;
                f = find(points2(:,1) < div);
                points2(f,1) = points2(f,1) + 360;
                points2 = clip(points2);
                [X2,Y2] = MollweideContour(points2);
                contour_list{ cnt } = [X2,Y2];
                cnt = cnt + 1;
            end
        end
    end
    contour_list( cnt:end ) = [];
end

for k = 1:length(contour_list)
    plot( contour_list{k}(:,1), contour_list{k}(:,2), 'k' );
end


function points = clip(points)

f = (points(:,1) > 180);
points(f,1) = 180;
%f = find(points(1:end-2,1) == 180 & points(2:end-1,1) == 180 & points(3:end,1) == 180);
%points(f+1,:) = [];

f = (points(:,1) < -180);
points(f,1) = -180;
%f = find(points(1:end-2,1) == -180 & points(2:end-1,1) == -180 & points(3:end,1) == -180);
%points(f+1,:) = [];


function [X,Y] = MollweideContour( path )

th = 2*asin(2*path(:,2)*1/180);
f = (cos(th) == -1);
th(f) = acos(-0.999);

for a = 1:100
   th = th - (th + sin(th)-pi*sin(path(:,2)*pi/180))./(1+cos(th));
end
th = th/2;
X = 2*sqrt(2)*path(:,1)/180.*cos(th);
Y = sqrt(2)*sin(th);


function name = monthName( m )

switch m
    case 1
        name = 'Jan';
    case 2 
        name = 'Feb';
    case 3
        name = 'Mar';
    case 4
        name = 'Apr';
    case 5
        name = 'May';
    case 6
        name = 'Jun';
    case 7 
        name = 'Jul';
    case 8 
        name = 'Aug';
    case 9 
        name = 'Sep';
    case 10 
        name = 'Oct';
    case 11
        name = 'Nov';
    case 12 
        name = 'Dec';
end

