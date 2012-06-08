function dt = typedHashTable( varargin )

dt.class = '';
dt.table = '';

if nargin == 0
    error( 'Too few parameters' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'typedHashTable' )
        dt = v;
        return;
    elseif ischar( v )
        dt.class = v;
        dt.table = primitiveHashTable2( ['Typed Hash' filesep v] );
        
        dt = class( dt, 'typedHashTable' );
    elseif isobject( v ) 
        v = class(v);
        dt.class = v;
        dt.table = primitiveHashTable2( ['Typed Hash' filesep v] );

        dt = class( dt, 'typedHashTable' );
    else
        error('Unable to process input')
    end
else
    error( 'Too Many Parameters' );
end
        
