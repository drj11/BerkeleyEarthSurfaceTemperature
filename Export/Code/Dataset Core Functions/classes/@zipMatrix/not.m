function v = not( a );

if isa( a, 'zipMatrix' )
    a = expand( a );
end

v = ~a;