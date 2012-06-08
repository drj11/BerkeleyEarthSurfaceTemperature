function cv = zipMatrix( varargin )

cv.size = uint32( [0, 0] );
cv.increment = 0;
cv.type = uint8(0);
cv.data = [];

if nargin == 0    
    cv = class( cv ,'zipMatrix' );
elseif nargin == 1
    v = varargin{1};
    if isa( v, 'compactVector' )
        v = expand( v );
    end    
    if isa(v, 'zipMatrix')
        cv = v;
    else
        cv.size = uint32( size(v) );
        cv.increment = 0;
        cv.data = reshape( v, numel(v), 1 );     

        c = class( cv.data );
        cv.type = uint8( strmatch( c, getDataTypeCodes() ) );
        
        if isempty( cv.type )
            error( 'Not supported data type' );
        end
        
        cv = class( cv, 'zipMatrix' );        
        cv = compress( cv );        
    end
else
    error( 'Too many arguments given to zipMatrix' );
end