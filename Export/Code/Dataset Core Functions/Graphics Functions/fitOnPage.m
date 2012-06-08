function fitOnPage( handle )
% Take a figure, maximize its position it on the printed page while
% preserving aspect ratio

un = get( handle, 'units' );
un2 = get( handle, 'paperunits' );

set( handle, 'units', 'inches' );
set( handle, 'paperunits', 'inches' );
pos = get( handle, 'position' );
sz = get( handle, 'papersize' );

paper_min = 0.25; %inches at edge

sz2 = sz - 2*paper_min;
w = pos(3);
h = pos(4);

h2 = sz2(1)*h/w;
w2 = sz2(2)*w/h;

if w2 > sz2(1)
    w2 = sz2(1);
else
    h2 = sz2(2);
end

pos2 = [(sz(1) - w2)/2, (sz(2)-h2)/2, w2, h2];
set( handle, 'paperposition', pos2 );

set( handle, 'units', un );
set( handle, 'paperunits', un2 );

