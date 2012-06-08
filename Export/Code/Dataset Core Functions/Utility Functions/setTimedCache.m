function setTimedCache( name, file_hash, value, days )
% setTimedCache( name, generator_id, value, days )
%
% Send a value to the timed cache.  
%
% name is the identifer to use in storing the value
% generator_id is a version identifer for the cached object (optional)
% value is the object to store
% days is the length of time in days that the cache is considered valid.
%
% days defaults to 15 if omitted.

if nargin < 3
    error( 'Needs at least 3 parameters' );
end
if nargin == 3
    days = 15;
end

if isnan( file_hash )
    file_hash = [];
end

temperatureGlobals;

name = strrep( name, '/', '_');
name = strrep( name, '\', '_');
name = strrep( name, ' ', '_');
name = strrep( name, ':', '-');

name = [name '.mat'];

pth = [temperature_data_dir 'Timed Cache' psep name];
checkPath( pth );

expires = now + days;

save( pth, 'value', 'expires', 'file_hash' );