function res = lt( md1, md2 )
% Checks if two hashes are identical.

if ~isa( md1, 'md5hash' )
    md1 = md5hash( md1 );
end
if ~isa( md2, 'md5hash' )
    md2 = md5hash( md2 );
end

if length(md1) == length(md2)
    res = ( md1.val(1) < md2.val(1) ) | ...
        (( md1.val(1) == md2.val(1) ) & ( md1.val(2) < md2.val(2) ));
elseif length(md1) == 1
    sz = size(md2);
    res = zeros( sz(1), sz(2) );
    for k = 1:sz(1)*sz(2)
        res(k) = ( md1.val(1) < md2(k).val(1) ) | ...
            (( md1.val(1) == md2(k).val(1) ) & ( md1.val(2) < md2(k).val(2) ));
    end
elseif length(md2) == 1
    sz = size(md1);
    res = zeros( sz(1), sz(2) );
    for k = 1:sz(1)*sz(2)
        res(k) = ( md1(k).val(1) < md2.val(1) ) | ...
            (( md1(k).val(1) == md2.val(1) ) & ( md1(k).val(2) < md2.val(2) ));
    end
end
