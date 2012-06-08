function save( dt, varargin )
% save( function cache, input arguments ..., result )
% 
% Stores the result of inputs in the function cache.

if nargin < 2
    error( 'No input parameters given.' );
end

hash = collapse( [dt.dep_hash md5hash( varargin(1:end-1) )] );
add( dt.lookup_table, hash, varargin{end} );
