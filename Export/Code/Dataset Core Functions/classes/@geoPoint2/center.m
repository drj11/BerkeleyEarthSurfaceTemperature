function center_pos = center( pos )
%CENTER( pos ): Computes the center of positions in list pos

temperatureGlobals;

X = [pos.x];
Y = [pos.y];
Z = [pos.z];

f = find( ~isnan(X) );
if length(f) == 0
    center_pos = geoPoint2();
    return
end

X = mean(X(f));
Y = mean(Y(f));
Z = mean(Z(f));

D = (X.^2 + Y.^2 + Z.^2)^(1/2);

X = X / D;
Y = Y / D;
Z = Z / D;

lat = 90 - acos( Z ) * 180/pi;
long = atan2( Y, X ) * 180/pi;

elev = mean( [pos.elevation] );

center_pos = geoPoint2( lat, long, elev );