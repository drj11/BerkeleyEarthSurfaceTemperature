function v = subsasgn( a, S, value );

a = expand( a );
v = subsasgn( a, S, value );
v = zipMatrix( v );