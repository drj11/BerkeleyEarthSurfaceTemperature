function plotTemperatureBoth( x, y )

plot( x, y );
h = gca;

set(h, 'tickdir', 'out', 'yaxislocation','right', 'box','off' );
ylabel( 'Celsius' );

position = get( h, 'position' );
xlim = get( h, 'xlim' );
ylim = get( h, 'ylim' );

h2 = axes( 'position', position, 'xlim', xlim, 'ylim', (ylim*9/5 + 32), ...
    'color', 'none', 'yaxislocation', 'left', 'tickdir', 'out', ...
    'xtick', [], 'box','off', 'xaxislocation', 'top' );

ylabel( 'Fahrenheit' );
