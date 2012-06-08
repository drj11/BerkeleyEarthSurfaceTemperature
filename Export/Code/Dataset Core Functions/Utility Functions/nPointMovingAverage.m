function B = nPointMovingAverage( A, n )
%Simple N-point moving average;

B = A(1:end-n+1);
for k = 2:n
    B = B + A(k:end-n+k);
end
B = B / n;