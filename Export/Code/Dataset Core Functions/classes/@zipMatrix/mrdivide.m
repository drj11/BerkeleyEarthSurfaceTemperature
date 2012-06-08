function v = mrdivide( a, b );

if isa( a, 'zipMatrix' )
    a = expand( a );
end
if isa( b, 'zipMatrix' )
    b = expand( b );
end

v = a \ b;