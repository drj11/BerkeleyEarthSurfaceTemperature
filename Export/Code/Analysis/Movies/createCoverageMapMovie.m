function createCoverageMapMovie( map_points, coverage_map, times, ...
    start, step, occ_table, loc_pts, coverage_summary, name )

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
    vidObj.FrameRate = 12;
    open(vidObj);
    
    save_video = true;
    %step = 1;
else
    save_video = false;
end

target_figure = gwFigure;
main_panel = axes;

set( main_panel, 'position', [0.02, 0.04, 0.92, 0.82] );

cmap = gray(200);

clim = [0,1];
f = ( coverage_map > max(clim) );
map(f) = max(clim);
f = ( coverage_map < min(clim) );
map(f) = min(clim);

mask_color = [0.8, 0.8, 0.8];
outer_color = [0.6, 0.6, 0.6];


% Color scale remap
sz = size(cmap);
Y_index = clim(1):0.001:clim(2);
C_index = 1:199/(length(Y_index)-1):200;

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

start_k = findk( times, start );

VC_field = cell( length( coverage_map( 1, : ) ), 1 );
for k = start_k:step:length( coverage_map( 1, : ) )
    if isempty( VC_field{k} )
        max_k = min( k + step*100, length( coverage_map( 1, : ) ) );
        for k2 = 1:k-1
            VC_field{k2} = [];
        end
        parfor k2 = k:max_k
            if mod( k2 - k, step ) ~= 0
                continue;
            end
            
            C = coverage_map( :, k2);
            F = TriScatteredInterp( X(:), Y(:), double(C(:)) );

            C2 = X2(:).*0;
            VCa = [X2(:).*0];
            VCa(~mask) = sz(1) + 2;
            
            C2(mask) = F(X2, Y2);
            VCa(mask) = round(interp1( Y_index, C_index, C2(mask) ));

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
        plot(x,y,'-','linewidth',4, 'color', [0.4,0.4,0.4]);
        set(gca,'color','none');

        h = colorbar;
        set(h, 'ylim', [0.5, sz(1) + 0.5], 'tickdir', 'out', 'ticklength', [0.015, 0] );
        ymark = 0:.1:1;
        tmark = interp1( Y_index, C_index, ymark );
        set(h, 'ytick', tmark, 'yticklabel', ymark*100, 'fontsize', 14, 'linewidth', 2 );
        ylabel( h, 'Variance Capture Expected (%)', 'fontsize', 16 );
         
        tpos = coverage_summary(k);
        hold(h,'on');
        xlim = get( h, 'xlim' );
        marker = plot( xlim, [tpos, tpos], 'k', 'linewidth', 3, 'parent', h );
        
        text( -2.95, 1.82, 'Stations', 'fontsize', 14 );
        text( 2.95, 1.82, 'Land Coverage', 'fontsize', 14, 'horizontalalignment', 'right');
        
        occ = sum( occ_table( :, k ) );
        per = coverage_summary(k)*100;
        
        occ_string = text( -2.95, 1.62, num2str(round(occ*10)/10), 'fontsize', 14 );
        per_string = text( 2.95, 1.62, [num2str(round(per*10)/10) '%'], 'fontsize', 14, 'horizontalalignment', 'right');

        pts = [[loc_pts(occ_table(:,k)).long]', [loc_pts(occ_table(:,k)).lat]'];
        [pX,pY] = MollweideContour( pts );
        points_plot = plot( pX, pY, 'o' , 'markeredgecolor', [0.5,0,0], ...
            'markerfacecolor', [1,0,0], 'markersize', 4);

        children = get( main_panel, 'children' );        
        
        m1 = round( (times(k) - floor(times(k)) + 1/24)*12 );
        y1 = floor( times(k) );
        
        n1 = monthName( m1 );
        
        title_str = [n1 ' ' num2str(y1)];
        t_string = title( main_panel, title_str, 'fontsize', 18 );
        
        pos = get( main_panel, 'position' );
        set( gcf, 'position', [200, 200, (6/0.008 + 1)/pos(3), (3/0.008 + 1)/pos(4)] );        
    else
        delete(h_last);
        delete(points_plot);
        h_last = image(-3:0.01:3,-1.5:0.01:1.5,CT, 'parent', main_panel);        

        pts = [[loc_pts(occ_table(:,k)).long]', [loc_pts(occ_table(:,k)).lat]'];
        [pX,pY] = MollweideContour( pts );
        points_plot = plot( pX, pY, 'o' , 'markeredgecolor', [0.5,0,0], ...
            'markerfacecolor', [1,0,0], 'markersize', 4);
        
        children(1) = points_plot;
        children(end) = h_last;
        set( main_panel, 'children', children );
        
        m1 = round( (times(k) - floor(times(k)) + 1/24)*12 );
        y1 = floor( times(k) );
        
        n1 = monthName( m1 );
        
        title_str = [n1 ' ' num2str(y1)];
        set( t_string, 'string', title_str );

        occ = sum( occ_table( :, k ) );
        per = coverage_summary(k)*100;

        set( occ_string, 'string', num2str(round(occ*10)/10) );
        set( per_string, 'string', [num2str(round(per*10)/10) '%']);

        tpos = coverage_summary(k);
        set( marker, 'ydata', [tpos,tpos] );
    end    
    
    drawnow;
    if save_video
        cur_frame = getframe( target_figure );
        writeVideo( vidObj, cur_frame );

        if k == 1 || k == length( coverage_map( 1, : ) )
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
    plot( contour_list{k}(:,1), contour_list{k}(:,2), 'color', [0, 1, 0] );
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

