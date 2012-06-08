function val = get( dt, varargin )
% val = get( function cache, input arguments ... )

if dt.disable_read
    val = [];
    return;
end

if nargin < 2
    error( 'No input parameters given.' );
end

hash = collapse( [dt.dep_hash, md5hash( varargin )] );

try
    warning('OFF', 'directHashTable:get');
    val = get( dt.lookup_table, hash );
    warning('ON', 'directHashTable:get');
catch
    val = [];
end




