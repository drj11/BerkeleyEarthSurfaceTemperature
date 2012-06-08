function frc = sessionFunctionCache( name, pth )
% FRC = sessionFunctionCache( name, path )
%
% Returns functionResultCache for function "name" located at "path".  If both
% parameters are omitted, a cache is returned for the calling function.  If
% path is omitted, it attempts to located the appropritate file.

sessionParallelCheck;
global SESSION_DATA

if isempty( SESSION_DATA ) 
    error( 'Session has not be started.' );
end

if nargin == 0
    [name, pth] = parentFunction;
elseif nargin == 1
    pth = which( name );
end

hash = md5hash( [name ':' pth] );

try
    frc = SESSION_DATA.function_cache( hash );
catch
    frc = functionResultCache( name, pth );
    SESSION_DATA.function_cache( hash.hash ) = frc;
end
