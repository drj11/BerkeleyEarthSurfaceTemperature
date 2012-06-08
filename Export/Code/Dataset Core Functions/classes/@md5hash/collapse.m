function res = collapse( md5s )
% Computes a hash over a group of hashes

res = md5hash( [md5s(:).val] );