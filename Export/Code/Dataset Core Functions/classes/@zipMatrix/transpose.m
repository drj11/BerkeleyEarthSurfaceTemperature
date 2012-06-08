function Z = transpose( A )

sz = A.size;
if sz(1) == 1 || sz(2) == 1
    sz = [sz(2), sz(1)];
    Z = A;
    Z.size = sz;
    return;
end

Z = zipMatrix( transpose( expand( A ) ) );