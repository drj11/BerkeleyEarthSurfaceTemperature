function worldMapOutline(center, weight)

if nargin < 1
    center = 0;
end
if nargin < 2
    weight = 0.5;
end

seg = loadCoastlineCoarse;

set(gca,'color',[0.6,0.6,1]);
set(gca,'box','on','xtick',[],'ytick',[]);
hold(gca, 'on');

for k = 1:length(seg)
    if (seg(k).level == 1 && seg(k).area > 10000) || (seg(k).level == 2 && seg(k).area > 100000)
        if seg(k).level == 1
            col = [0.6,0.5,0.4];
        else
            col = [0.8,0.8,1];
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
            plot(points(:,1),points(:,2),'k','linewidth', weight);
            hold on            
        elseif isempty(f)
            points = clip(points);
            plot(points(:,1),points(:,2),'k','linewidth', weight);
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
            plot(points2(:,1),points2(:,2),'k','linewidth', weight);
            hold on
            
            points2 = points;
            f = find(points2(:,1) < div);
            points2(f,1) = points2(f,1) + 360;
            points2 = clip(points2);
            plot(points2(:,1),points2(:,2),'k','linewidth', weight);
            hold on
        end
    end
end

rectangle('position',[0,-90,360,180],'edgecolor',[0,0,0]);

setxmin(0);
setxmax(360);
setymax(90);
setymin(-90);


function points = clip(points)

f = find(points(:,1) > 360);
points(f,1) = 360;
f = find(points(1:end-2,1) == 360 & points(2:end-1,1) == 360 & points(3:end,1) == 360);
points(f+1,:) = [];

f = find(points(:,1) < 0);
points(f,1) = 0;
f = find(points(1:end-2,1) == 0 & points(2:end-1,1) == 0 & points(3:end,1) == 0);
points(f+1,:) = [];