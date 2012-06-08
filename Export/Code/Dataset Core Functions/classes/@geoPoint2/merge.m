function result = merge( gp )
% Takes a list of geoPoints with uncertainties meant to indicate a single
% point and attempts to derive the best estimate of the underlying truth.
%
% If all of the points in the set have overlapping uncertainties, the
% location estimate is the overlap region.  If not, it attempts to
% determine a set of disjoint subpopulation and construct a region large
% enough to encompass all of these.

if length( gp ) == 1
    result = gp;
    return;
end
if length( gp ) == 0
    result = geoPoint2( NaN, NaN, NaN );
    return;
end

result = overlapTiles( gp );
