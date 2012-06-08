function val = getArray( dt, varargin )
% val = getArray( function cache, input arguments ... )
%
% Same behavior as get but assumes each input parameter is a cell array of
% values.

vars = varargin;

if dt.disable_read
    val = cell( length(vars{1}), 1 );
    return;
end

if nargin < 2
    error( 'No input parameters given.' );
end

hash = md5hash;

parfor k = 1:length(vars{1})
    var2 = cell(1, length(vars));
    for j = 1:length(vars)
        var2{j} = vars{j}{k};
    end
    hash(k) = collapse( [dt.dep_hash md5hash( var2 )] );
end

try
    warning('OFF', 'directHashTable:get');
    val = get( dt.lookup_table, hash );
    if length( hash ) == 1
        val = {val};
    end    
    warning('ON', 'directHashTable:get');
catch
    val = cell( length(vars{1}), 1 );
end

if isempty( val )
    val = cell( length(vars{1}), 1 );
end