function A = makeHalfPrecision( X )

A = zeros( size(X), 'uint16' );
A = bitset( A, 16, X < 0 );
[F, E] = log2( abs(X) );

f = ( E > 15 );
E(f) = 16;
F(f) = 0;

f = ( E < -14 );
E(f) = -15;
F(f) = 0;

f = isnan( F );
E(f) = 16;
F(f) = 1;

E = uint16(E + 15);
A = bitor( A, bitshift( E, 10 ) );

F = uint16( F*2^9 );

A = bitor( A, F );
