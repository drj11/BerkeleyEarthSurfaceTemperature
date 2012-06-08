function res = eq( md1, md2 )
% Checks if two hashes are identical.

if ~isa( md1, 'md5hash' )
    md1 = md5hash( md1 );
end
if ~isa( md2, 'md5hash' )
    md2 = md5hash( md2 );
end

if length(md1) == length(md2)
    res = all( md1.val == md2.val );
elseif length(md1) == 1
    sz = size(md2);
    res = zeros( sz(1), sz(2) );
    for k = 1:sz(1)*sz(2)
        res(k) = all( md1.val == md2(k).val );
    end
elseif length(md2) == 1
    sz = size(md1);
    res = zeros( sz(1), sz(2) );
    for k = 1:sz(1)*sz(2)
        res(k) = all( md1(k).val == md2.val );
    end
end
