function pt = computeXYZ( pt )

persistent radius;
if isempty( radius )
    temperatureGlobals;
    radius = earth_radius;
end

R(1:length(pt)) = radius;

f  = ~isnan([pt.elevation]);
if any( f )
    elev = [pt.elevation];
    R(f) = radius + elev(f) / 1000;
end

phi = [pt.longitude] * pi / 180;
theta = (-[pt.latitude] + 90) * pi / 180;

x = R .* sin( theta ) .* cos( phi );
y = R .* sin( theta ) .* sin( phi );
z = R .* cos( theta );

for k = 1:length(x)
    pt(k).x = x(k);
    pt(k).y = y(k);
    pt(k).z = z(k);
end    