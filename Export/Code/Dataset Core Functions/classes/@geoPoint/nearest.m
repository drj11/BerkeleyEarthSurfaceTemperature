function index = nearest( target_pt, pts, n )
%NEAREST( target_pt, pts [, n] ): Finds the nearest point(s).
%
%Finds the index in pts corresponding to the location that is nearest to
%target_pt.  If n is specified then the n closest indices are returned,
%otherwise the single closest is returned.

if nargin < 2
    error( 'Insufficient inputs.' );
end
if nargin < 3
    n = 1;
end

if n > length(pts)
    error( 'Requested number of outputs is longer than input array.' );
end

x = [pts(:).x] - target_pt.x;
y = [pts(:).y] - target_pt.y;
z = [pts(:).z] - target_pt.z;

d = x.^2+y.^2+z.^2;

[s, I] = sort(d);

index = I(1:n);