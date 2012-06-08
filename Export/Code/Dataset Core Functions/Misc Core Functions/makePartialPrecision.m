function [a,b] = makePartialPrecision( X )

[a,b] = log2(X);
b = int8(b-15);
a = int16(a*2^15);
