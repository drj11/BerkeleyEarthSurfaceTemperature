function locations = randLocations( num )
% locations = randLocations( num )
%
% Returns num random geoPoints from a distribution uniformly distributed
% over a sphere;

R = randn( num, 3 );

norm = sum( R.^2, 2 ).^(1/2);
R = bsxfun( @rdivide, R, norm );

lat = 90 - acos( R(:,3) ) * 180/pi;
long = atan2( R(:,2), R(:,1) ) * 180/pi;

locations = geoPoint2( lat, long );