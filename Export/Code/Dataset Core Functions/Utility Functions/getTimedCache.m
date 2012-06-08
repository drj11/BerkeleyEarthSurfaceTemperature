function result = getTimedCache( name, file_hash )
% Retrieve a value from the timed cache

if nargin < 2
    file_hash = [];
end

temperatureGlobals;

name = strrep( name, '/', '_');
name = strrep( name, '\', '_');
name = strrep( name, ' ', '_');
name = strrep( name, ':', '-');

name = [name '.mat'];

pth = [temperature_data_dir 'Timed Cache' psep name];

if ~exist( pth, 'file' )
    result = [];
else
    V = load( pth );
    
    if V.expires < now
        result = [];
    else
        if ~isempty( file_hash )
            if file_hash == V.file_hash
                result = V.value;
            else
                result = [];
            end
        else
            result = V.value;
        end
    end
end