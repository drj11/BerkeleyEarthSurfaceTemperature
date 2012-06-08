function createTemperatureMapPoints( lat, long )

long = mod(long+180,360)-180;

th = 2*asin(2*lat*1/180);
for a = 1:100;
    th = th - (th + sin(th)-pi*sin(lat*pi/180))./(1+cos(th));
end
th = th/2;
X = 2*sqrt(2)*long/180.*cos(th);
Y = sqrt(2)*sin(th);

plot( X, Y, 'r.' );

hold on
MollweideCoastline(0);

set(gca,'ytick',[], 'xtick',[], 'ydir', 'normal' );

th = 0:0.01:3*pi;
x = 2*cos(th)*sqrt(2);
y = sin(th)*sqrt(2);
plot(x,y,'k-','linewidth',3);
set(gca,'color','none');


setymax(1.6)
setymin(-1.6);
setxmax(3.2);
setxmin(-3.2);
        

        
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

