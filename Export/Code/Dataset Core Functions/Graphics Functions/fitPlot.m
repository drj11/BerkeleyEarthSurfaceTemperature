function fitPlot(ax);

p = get(ax,'position');
t = get(ax,'tightinset');

t = t + 0.03;

p2(1:2) = t(1:2);
p2(3:4) = 1 - t(3:4) - t(1:2);

set(ax,'position',p2);