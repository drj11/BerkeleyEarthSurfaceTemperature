function res = uncertaintyScale( gp )

temperatureGlobals;

res = zeros( length(gp), 2 );
for k = 1:length( gp )
    res(k, 1) = 2*pi*earth_radius * [gp(k).lat_uncertainty]'/360;
    res(k, 2) = 2*pi*earth_radius * [gp(k).long_uncertainty]'/360 .* ...
        cos( [gp(k).latitude]' * pi/180 );
end