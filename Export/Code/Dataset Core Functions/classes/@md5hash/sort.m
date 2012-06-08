function [s, I] = sort( md5s )
%Sorts the hashes

val = [md5s.val]';
[~,I] = sortrows( val );
s = md5s(I);
