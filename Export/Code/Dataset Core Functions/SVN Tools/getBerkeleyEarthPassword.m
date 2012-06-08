function password = getBerkeleyEarthPassword( reload )
% Retrieves user password and stores it in masked global variable.  Future
% calls are retrieved from memory.

temperatureGlobals;

if nargin < 1
    reload = false;
end

persistent mask;

if isempty( BerkeleyEarth_password ) || reload || isempty( mask )
    if strcmp( BerkeleyEarth_username, 'installer' );
        password = 'temperature';
    else
        password = input( ['Please enter password for username "' BerkeleyEarth_username '": '], 's' );
    end
    
    mask = uint8(rand( length( password ), 1 )*256);
    BerkeleyEarth_password = bitxor( uint8(password), mask' );
else
    password = char( bitxor( BerkeleyEarth_password, mask' ) );
end
