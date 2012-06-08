function [LAT, LONG] = idealGrid( num )

target_area = 4*pi / num;

d_length = (target_area)^(1/2);

ysteps = round( pi / d_length );

ylength = pi / ysteps;
ypos = ylength/2:ylength:pi-ylength/2;

xwidth = 2*pi*sin( ypos );
xsteps = round( xwidth / d_length );

% Determining latitude divisions to enforce the equal area requirement 
% depends on solving a linear algebra problem outlined below
A = zeros(length(xsteps), length(xsteps)+1);
for k = 1:length(xsteps)
    A(k,k) = 1/xsteps(k);
    A(k,k+1) = -1/xsteps(k);
end
A = A*2*pi;
O = A(:,[1,end]);

A(:,1) = [];
A(:,end) = [];

B = ones(length(xsteps),1) * 2*pi / sum(xsteps);
C = B - O*[sin(pi/2); sin(-pi/2)];
X = A\C;

% X2 stores the latitudes defining grid cell boundaries.
X2 = [sin(pi/2); X; sin(-pi/2)];

% Generate grid centers from the grid boundaries.  Currently this found 
% using the simple average of the bounding latitudes.  Arguably we should 
% determine the area weighted center, but the error involved is small.
LAT = zeros( sum(xsteps), 1 );
LONG = LAT;

cnt = 1;
for k = 1:length(X2) - 1
    LAT(cnt:cnt+xsteps(k)-1) = (asin(X2(k)) + asin(X2(k+1)))/2 * 180/pi;
    LONG(cnt:cnt+xsteps(k)-1) = -180 + 360/(2*xsteps(k)):360/xsteps(k):180-360/(2*xsteps(k));
    cnt = cnt + xsteps(k);
end
