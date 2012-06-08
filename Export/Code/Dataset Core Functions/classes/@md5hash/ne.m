function res = ne( md1, md2 )

if ~isa( md1, 'md5hash' )
    md1 = md5hash( md1 );
end
if ~isa( md2, 'md5hash' )
    md2 = md5hash( md2 );
end

res = any( md1.val ~= md2.val );
