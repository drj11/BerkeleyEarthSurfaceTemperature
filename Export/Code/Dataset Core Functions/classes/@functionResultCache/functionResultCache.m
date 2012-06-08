function dt = functionResultCache( varargin )
% frc = functionResultCache( function name );
% frc = functionResultCache( function name, function path );
%
% Creates an accessor for the function result cache with specified name

dummy = false;
temperatureGlobals;

if nargin == 0
    if exist( 'getCurrentWorker', 'file' )
        vv = getCurrentWorker();
        if ~isempty( vv )
            dummy = true;
        end
    end    
    [name, pth] = parentFunction;
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'functionResultCache' )
        dt = v;
        return;
    elseif ischar( v )
        pth = which( v );
        if isempty( pth )
            error( 'Unable to locate function source from name' );
        end
    else
        error( 'Unable to interpret argument 1 as function name' );
    end
elseif nargin == 2
    name = varargin{1};
    pth = varargin{2};
    if ~ischar( name ) || ~ischar( pth )
        error( 'Requires string input' );
    end
else
    error( 'Too many argument' );
end

if sessionActive
    [file_hash, dep_hash] = sessionFileHash( pth );
else    
    file_hash = saveMFile( pth );
    
    [~, hashes] = functionDependencies( pth );
    hashes = sort(hashes);
    dep_hash = collapse( hashes );
end

dt.name = name;
dt.path = pth;
dt.file_hash = file_hash;
dt.dep_hash = collapse( [file_hash dep_hash] );

dt.lookup_table = [];
dt.disable_read = 0;
        
dt = class( dt, 'functionResultCache' );

if ~dummy 
    if exist( 'temperature_cache_dir', 'var' )
        dt.lookup_table = directHashTable( [ temperature_cache_dir filesep ...
            name ] );        
    else
        dt.lookup_table = directHashTable( [ 'Function Cache' filesep ...
            name ] );
    end
end
