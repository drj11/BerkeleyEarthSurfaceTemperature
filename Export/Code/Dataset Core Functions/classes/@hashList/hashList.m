function dt = hashList( varargin )
% frc = functionResultCache( function name );
% Creates an accessor for the function result cache with specified name

dt.name = '';
dt.created = [];
dt.creator = '';
dt.creatorHash = md5hash;
dt.type = '';
dt.hashes = md5hash;

if nargin == 0    
    dt = class( dt, 'hashList' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'hashList' )
        dt = v;
    end
elseif nargin == 4 || nargin == 3
    dt.name = varargin{1};
    [dt.creator, pth] = parentFunction();
    dt.creatorHash = saveMFile( pth );
    dt.created = now;
    
    v = varargin{3};
    if ischar( v )
        dt.type = v;
    else
        dt.type = class( v );
    end
    dt.hashes = varargin{4};

    dt = class( dt, 'hashList' );
else
    error( 'Wrong number of parameters' );
end