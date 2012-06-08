function H = gwFigure()

H = figure;
set(H,'color',[0.95,0.95,0.95],'InvertHardcopy','off');
colormap(jet(256));

set(H,'paperpositionmode','auto','paperunits','normalized');
set(H,'paperunits','points');
set(H,'papersize',[1000,1000]);
set(H,'paperunits','normalized');
p = get(H,'position');
p(3:4) = [600*1.3,600];
if p(1) + p(3)+100 > 1920
    p(1) = 1920-p(3)-100;
end
if p(2) + p(4)+100 > 1080
    p(2) = 1080-p(4)-100;
end

set(H,'position',p);