function r = correlate( A, B )

A = A(:) - mean(A);
B = B(:) - mean(B);

r = sum(A.*B)/sqrt(sum(A.^2)*sum(B.^2));