function X = mrdivideWithParitalInverse( M, T, f, Ai )
% X = mldivideWithParitalInverse( M, T, indices, Ai )
%
% Computes X = T / M where M is square and M( indices, indices )^-1 = Ai
%
% This function can be very efficient if the partial matrix comprises most
% of M;

X = mldivideWithParitalInverse( M', T', f, Ai' )';