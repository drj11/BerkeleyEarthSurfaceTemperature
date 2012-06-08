function ht = primitiveHashTable2( varargin )

temperatureGlobals;

ht.name = '';
ht.dir = '';

if nargin == 0    
    ht = class( ht, 'primitiveHashTable2' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'primitiveHashTable2' )
        ht = v;
        return;
    elseif ischar( v )
        ht.name = v;
        nm = strrep( ht.name, ' ', '_' )  ;      
        nm = strrep( nm, '\', filesep ) ;       
        nm = strrep( nm, '/', filesep );    
        ht.dir = [temperature_data_dir 'Hash Table' filesep nm filesep];        
        checkPath( ht.dir );
        ht = class( ht, 'primitiveHashTable2' );
    else
        error('Unable to process input')
    end
else
    error('Too Many Parameters');
end
        
