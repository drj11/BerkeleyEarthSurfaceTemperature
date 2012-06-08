function pts = rotate( pts, rot )

X = [pts(:).x];
Y = [pts(:).y];
Z = [pts(:).z];

new_pos = rot*[X;Y;Z];

dist = sqrt(sum( new_pos.^2 ));

lat = asin( new_pos(3,:)./dist )*180/pi;
long = atan2( new_pos(2,:)./dist, new_pos(1,:)./dist )*180/pi;

pts = geoPoint( lat, long, [pts(:).elevation] );
