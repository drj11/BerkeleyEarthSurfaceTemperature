function [s, I, J] = unique( md5s ) 
%Unique hashes

val = [md5s.val]';

if nargout > 2
    [~,I,J] = unique( val, 'rows' );
else
    [~,I] = unique( val, 'rows' );
end    
s = md5s(I);
