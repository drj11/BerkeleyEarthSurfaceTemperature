function ht = addArray( ht, hash, val, sup )
% Same as add but treats each arrray element seperately.

if ~isCurrent( ht );
    ht = reload( ht );
end

if length( val ) == 0
    return;
end

if ~isa( hash, 'md5hash' )
    error('Second parameter does not contain hash values');
end

if iscell(val)
    cell_mode = 1;
else
    cell_mode = 0;
end

md5 = hash;

indices = findIndices( ht, md5 );
f = ~isnan( indices );

md5(f) = [];
val(f) = [];
if isempty( val )
    return;
end

key = md5(:).key;

[key2, sort_order] = sortrows( key );
val = val(sort_order);
md5 = md5(sort_order);

lc = matlabPoolSize();
if lc == 0 
    lc = 1;
end
val_list = cell( lc, 1 );
sup_list = cell( lc, 1 );
md5_list = cell( lc, 1 );
key_list = cell( lc, 1 );
path_list = cell( lc, 1 );

for ps = 1:lc    
    val_list{ps} = val(ps:lc:end);
    if nargin > 3
        sup_list{ps} = sup(ps:lc:end);
    end 
    key_list{ps} = key2(ps:lc:end,:);
    md5_list{ps} = md5(ps:lc:end);
    path_list{ps} = [ht.dir filesep num2str(ht.next_index + ps - 1) '_data.mat'];
end
parfor ps = 1:lc
    if ~isempty( md5_list{ps} )
        if nargin > 3
            saveBlock( path_list{ps}, md5_list{ps}, key_list{ps}, cell_mode, val_list{ps}, sup_list{ps} );
        else
            saveBlock( path_list{ps}, md5_list{ps}, key_list{ps}, cell_mode, val_list{ps} );
        end            
    end
end

for ps = 1:lc
    if ~isempty( md5_list{ps} )
        ht.index_list = [ht.index_list; md5_list{ps}(:).val];
        ht.file_list = [ht.file_list; ones(length(md5_list{ps}),1)*ht.next_index];
        ht.next_index = ht.next_index + 1;
        ht.last_partition = ht.last_partition + 1;
    end
end

[ht.index_list, I] = sortrows( ht.index_list );
ht.file_list = ht.file_list(I);

index_list = ht.index_list;
file_list = ht.file_list;
next_index = ht.next_index;
last_partition = ht.last_partition;

save( [ht.dir 'index.mat'], 'index_list', 'file_list', 'next_index', ...
    'last_partition');