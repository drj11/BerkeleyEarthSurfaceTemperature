function B = uncompressLogical( A )

if ~isa( A, 'uint8' )
    error( 'Not a uint8 array' );
end

sz = zeros( 1, 2, 'int32' );
sz(1) = typecast( A(1:4), 'int32' );
sz(2) = typecast( A(5:8), 'int32' );
start = typecast( A(9:12), 'int32' );
stop = typecast( A(13:16), 'int32' );

if start == 0
    B = false( sz(1), sz(2) );
    return;
end

A = A(17:end);

B = false( 8, length(A) );

for k = 1:8
    B(k, :) = bitget( A, k );
end

B = reshape( B, [length(A)*8, 1] );
C = false( sz(1)*sz(2), 1 );
if stop-start+1 == length(B)
    C(start:stop) = B;
else
    C(start:stop) = B(1:(stop-start+1));
end
B = reshape( C, [sz(1), sz(2)] );