function [dist, dist2] = distance( pt1, pt2 )
%DISTANCE( pt1, pt2 ): Computes the distance between the points.
%
%Distance is computed as a great circle on a spherical Earth.  Elevation
%changes are not considered.  One of the inputs may be an array, in which
%case an array of distances is returned with respect to the single valued
%point.

temperatureGlobals;

if isempty(earth_radius)
    earth_radius = 6.371009000000000e+003;
end

if length(pt1) > 1 && length(pt2) == 1
    t = pt2;
    pt2 = pt1;
    pt1 = t;
end

if length(pt1) > 1
    error( 'At least one of the inputs must be a single valued.');
end

lat1 = pt1.latitude * pi/180;
lat2 = [pt2.latitude] * pi/180;

long1 = pt1.longitude * pi/180;
long2 = [pt2.longitude] * pi/180;

dL = long2 - long1;

% Application of the Vincenty formula for spheres: 

A = cos(lat2);
B = sin(lat2);
C = cos(lat1);
D = sin(lat1);
E = A.*cos(dL);
Y = sqrt( ( A.*sin(dL) ).^2 + ( C.*B - ...
    D.*E ).^2);
X = D.*B + C.*E;

dist = earth_radius*atan2(Y,X);
