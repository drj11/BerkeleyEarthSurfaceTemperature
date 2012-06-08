function ht = rebuild( ht )

pos = 0;
fname = [ht.dir num2str(pos) '_contents.mat'];

ht.index_list = [];
ht.file_list = [];

while exist(fname, 'file' );
    data = load( fname );
    ht.index_list = [ht.index_list; data.contents(:).val];
    ht.file_list = [ht.file_list; ones(length(data.contents),1)*pos];
    
    pos = pos + 1;
    fname = [ht.dir num2str(pos) '_contents.mat'];
end

[ht.index_list, I] = sortrows( ht.index_list );
ht.file_list = ht.file_list(I);

ht.next_index = pos;

index_list = ht.index_list;
file_list = ht.file_list;
next_index = ht.next_index;
last_partition = ht.last_partition;

save( [ht.dir 'index.mat'], 'index_list', 'file_list', 'next_index', ...
    'last_partition' );
