function B = compressLogical( A )

if ~islogical(A)
    error( 'Not a logical array' );
end

sz = int32( size(A) );
A = reshape( A, [sz(1)*sz(2),1] );

start = int32( find(A,1) );
stop = int32( find(A,1,'last') );

head = zeros( 1, 16, 'uint8' );
head(1:4) = typecast( sz(1), 'uint8' );
head(5:8) = typecast( sz(2), 'uint8' );

if isempty( start ) || isempty(stop)
    B = head';
    return;
end
head(9:12) = typecast( start, 'uint8' );
head(13:16) = typecast( stop, 'uint8' );

inner_length = double( stop - start + 1 );
A = A(start:stop);

A(end+1:ceil(inner_length/8)*8) = false;

A = uint8( reshape( A, 8, length(A)/8 ) );

B = zeros( 1, ceil(inner_length/8), 'uint8' );

for k = 1:8
    B = B + bitshift( A(k,:), k-1 );
end

B = [head, B]';