function [LAT, LONG] = createGISSGrid()
% Private function that return the grid centers for the GISS equal area
% grid.

% Each hemisphere is divided into four band.  The number of equal area
% superblocks in each band is determined by the following.
fundementals = [4, 8, 12, 16];

% Each superblock is divided into an equal area grid having 
% subblocks-by-subblocks elements.
subblocks = 10;

% Number of gird cells per row
rows = [];
for k = 1:length(fundementals)
    rows(subblocks*(k-1) + (1:subblocks)) = fundementals(k)*subblocks;
end

% Determining latitude divisions to enforce the equal area requirement 
% depends on solving a linear algebra problem outlined below
A = zeros(length(rows), length(rows)+1);
for k = 1:length(rows)
    A(k,k) = 1/rows(k);
    A(k,k+1) = -1/rows(k);
end
A = A*2*pi;
O = A(:,[1,end]);

A(:,1) = [];
A(:,end) = [];

B = ones(length(rows),1) * 2*pi / sum(rows);
C = B - O*[sin(pi/2); sin(0)];
X = A\C;

% X2 stores the latitudes defining grid cell boundaries.
X2 = [sin(pi/2); X; sin(0)];

% Generate grid centers from the grid boundaries.  Currently this found 
% using the simple average of the bounding latitudes.  Arguably we should 
% determine the area weighted center, but the error involved is small.
LAT = zeros( sum(rows), 1 );
LONG = LAT;

cnt = 1;
for k = 1:length(X2) - 1
    LAT(cnt:cnt+rows(k)-1) = (asin(X2(k)) + asin(X2(k+1)))/2 * 180/pi;
    LONG(cnt:cnt+rows(k)-1) = -180 + 360/(2*rows(k)):360/rows(k):180-360/(2*rows(k));
    cnt = cnt + rows(k);
end

% Flip the northern hemisphere grid for use in the southern hemisphere.
LAT = [LAT; -LAT];
LONG = [LONG; LONG];
