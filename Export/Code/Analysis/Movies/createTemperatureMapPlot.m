function createTemperatureMapPlot( map_points, map, coverage_map, clim, ymark )

if nargin < 3
    coverage_map = ones( size( map ) );
end
if nargin < 4
    clim = [min(map), max(map)];
end
if nargin < 5
    ymark = clim(1):(clim(2)-clim(1))/10:clim(2);
end

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
C_index = low:(high-low)/(length(Y_index)-1):high;

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

F = TriScatteredInterp( X(:), Y(:), X(:).*0 );

Z2 = X2(:).*0;
C2 = X2(:).*0;
D2 = X2(:).*0;
VCa = [X2(:).*0];
VCa(~mask) = sz(1) + 2;

V = map;
C = coverage_map;

fa = ~isnan( C(:) );
if ~any(fa)
    fa = 1:length(C);
end
F.X(:,1:2) = [X(fa)', Y(fa)'];
F.V = double(C(fa));

C2(mask) = F(X2, Y2);
f1 = ( C2(mask) < 0.2 );

F.V = double(V(fa));
Z2(mask2(~f1)) = F(X2(~f1), Y2(~f1));
VCa(mask) = round(interp1( Y_index, C_index, Z2(mask) ));

VCa(mask2(f1)) = sz(1)+1;
f3 = isnan( VCa );
VCa(f3) = sz(1)+1;
VC = VCa;


CT(:,:,1) = reshape( cmap(VC(:),1), 751, 376 )';
CT(:,:,2) = reshape( cmap(VC(:),2), 751, 376 )';
CT(:,:,3) = reshape( cmap(VC(:),3), 751, 376 )';

image(-3:0.01:3,-1.5:0.01:1.5,CT);

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
set(h, 'ytick', tmark, 'yticklabel', ymark, 'fontsize', 12, 'linewidth', 1 );
ylabel( h, 'Temperature Anomaly ( \circ C)', 'fontsize', 12 );


        

        
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

