function k = findk(value,vector);
% function k = findk(value,vector);
% finds the k such that vector(k) is closest to value

[val,k] = min(abs(vector-value));
