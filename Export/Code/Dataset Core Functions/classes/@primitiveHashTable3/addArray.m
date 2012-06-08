function [hash, ht] = addArray( ht, val, sup )
% Same as add but treats each arrray element seperately.

if length( val ) == 0
    hash = md5hash;
    hash(1) = [];
    return;
end

if iscell(val)
    cell_mode = 1;
else
    cell_mode = 0;
end

md5(1:length(val)) = md5hash;
parfor k = 1:length(val)
    if isa( val(k), 'md5hash' )
        md5(k) = md5hash( ['HASH:' val(k).key] );
    else
        if cell_mode
            md5(k) = md5hash(val{k});
        else
            md5(k) = md5hash(val(k));
        end            
    end
end

hash = md5;
if nargin > 2
    ht = addArray@directHashTable2( ht, hash, val, sup );
else
    ht = addArray@directHashTable2( ht, hash, val );
end    