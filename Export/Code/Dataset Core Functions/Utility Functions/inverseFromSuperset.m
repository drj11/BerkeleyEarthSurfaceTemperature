function Ai = inverseFromSuperset( Mi, f )
% Ai = inverseFromSuperset( Mi, f )
%
% Determines inv( M(f,f) ), given that Mi = inv(M).  This will be fast if f
% encompasses most of the rows of M.

sz = size( Mi );
if sz(1) ~= sz(2)
    error( 'Source matrix must be square' );
end

if ~islogical(f)
    fa = false( sz(1), 1 );
    fa(f) = true;
    f = fa;
end

E = Mi(f, f);
F = Mi(f, ~f);
G = Mi(~f, f);
H = Mi(~f, ~f);

Ai = E - F*inv(H)*G;
