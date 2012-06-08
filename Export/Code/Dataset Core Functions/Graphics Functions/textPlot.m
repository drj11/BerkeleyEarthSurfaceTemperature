function textPlot( st, title )

H = gwFigure;
pos = get(H, 'position');
pos(4) = pos(4) + 200;
pos(3) = pos(3) - 100;
pos(2) = pos(2) - 200;

set(H, 'position', pos);

h = axes('position', [0,0,1,1], 'visible', 'off' );
patch([0,0,1,1], [0,1,1,0], [0.9,0.9,0.9], 'edgecolor', 'none');
st = char(st);
text( 0.05, 0.9, st, 'fontsize', 12, 'fontname', 'Courier',...
    'verticalalignment', 'top' );

if nargin > 1
    text( 0.5, 0.95, title, 'fontsize', 16, 'horizontalalignment', 'center' );
end
