function val = saveArray( dt, varargin )
% val = saveArray( function cache, input arguments ..., results )
%
% Same behavior as save, but assumes every argument is a cell array, with
% each line equivalent to a unique call to save.

vars = varargin;

lv = length(vars);
lv2 = length(vars{1});
hash = md5hash;
hash(1:lv2) = md5hash;

dep_hash = dt.dep_hash;

var3 = cell( lv2, 1 );
for k = 1:lv2
    var2 = cell(1,lv-1);
    for j = 1:lv - 1
        var2{j} = vars{j}{k};
    end
    var3{k} = var2;
end

parfor k = 1:lv2
    hash(k) = collapse( [dep_hash md5hash( var3{k} )] );
end

addArray( dt.lookup_table, hash, vars{end} );