function A = expandHalfPrecision( X )

if ~isa( X, 'uint16' )
    error( 'Not a uint16 array' );
end

A = -2*double(bitget( X, 16 ))+1;
E = double( bitand( bitshift( X, -10 ), uint16(31) ) );
F = double( bitand( X, uint16(1023) ) );

E = E - 24;

A = A.*pow2(F, E);

Ef = (E == 7);
if any( Ef )
    fF = logical(F);
    f = Ef & ~fF;
    A(f) = Inf;
    f = Ef & fF;
    A(f) = NaN;
end