function ht = directHashTable( varargin )

temperatureGlobals;

ht.name = '';
ht.dir = '';

if nargin == 0    
    ht = class( ht, 'directHashTable' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'directHashTable' )
        ht = v;
        return;
    elseif ischar( v )
        ht.name = v;
        nm = strrep( ht.name, '\', filesep ) ;       
        nm = strrep( nm, '/', filesep );    
        
        f = find( nm == filesep );
        if f(1) == 1
            f(1) = [];
        end
        stem = nm(1:f(1));
    
        if ~exist( stem, 'dir') 
            nm = strrep( nm, ' ', '_' )  ;      
            ht.dir = [temperature_data_dir 'Hash Table' filesep nm filesep];        
            checkPath( ht.dir );
        else
            ht.dir = [nm filesep];        
            checkPath( ht.dir );
        end
        ht = class( ht, 'directHashTable' );
    else
        error('Unable to process input')
    end
else
    error('Too Many Parameters');
end
        
