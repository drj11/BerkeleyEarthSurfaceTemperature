function res = invWithPartial( M, f, Ai )
% Mi = invWithPartial( M, f, Ai )
%
% Compute inv(M) given that inv( M(f,f) ) = Ai.  This will be fast if f
% encompases most of M.

s = size(M);
if s(1) ~= s(2)
    error( 'Matrix must be square' );
end
s2 = size( Ai );
if s2(1) ~= s2(2)
    error( 'Partial result matrix must be square' );
end

if ~islogical( f )
    t = false( s(1), 1 );
    t( f ) = true;
    f = t;
end

M_B = M(f, ~f);
M_C = M(~f, f);
M_D = M(~f, ~f);

SS = Ai*M_B;
SP = M_D - M_C*SS;
SPi = inv(SP);

RR = (SPi*M_C)*Ai;

res_A = Ai + SS*RR;
res_B = -SS*SPi;
res_C = -RR;
res_D = SPi;

res = zeros( size(M) );
res(f, f) = res_A;
res(f, ~f) = res_B;
res(~f, f) = res_C;
res(~f, ~f) = res_D;