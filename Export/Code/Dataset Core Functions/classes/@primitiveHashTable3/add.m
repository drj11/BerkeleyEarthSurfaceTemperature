function [hash, ht] = add( ht, val, sup )

if isa( val, 'md5hash' )
    if length(val) > 1
        val2 = collapse(val);
    else
        val2 = val;
    end
    md5 = md5hash( ['HASH:' val2.key] );
else
    md5 = md5hash(val);
end

hash = md5;
if nargin > 2
    ht = add@directHashTable2( ht, hash, val, sup );
else
    ht = add@directHashTable2( ht, hash, val );
end    