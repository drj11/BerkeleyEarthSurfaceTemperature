function ht = add( ht, md5, val, sup )

if ~isCurrent( ht );
    ht = reload( ht );
end

if ischar(md5)
    md5_e = md5hash(md5);
    if md5_e ~= md5
        error('Second parameter is not a hash value');
    end
elseif ~isa( md5, 'md5hash' )
    error('Second parameter is not a hash value');
end

index = findIndices( ht, md5 );
if ~isnan( index );
    return;
end

key = md5.key;

pth = [ht.dir filesep num2str(ht.next_index) '_data.mat'];
checkPath(pth);

eval( ['v_' key ' = val;'] );
v{1} = ['v_' key];

if nargin > 3
    eval( ['s_' key ' = sup;'] );
    v{2} = ['s_' key];
end

pth2 = [pth(1:end-9) '_contents.mat'];

contents = md5(:);

save(pth, v{:}, '-v6');
save(pth2, 'contents', '-v6');        


ht.index_list = [ht.index_list; contents(:).val];
ht.file_list = [ht.file_list; ones(length(contents),1)*ht.next_index];
ht.next_index = ht.next_index + 1;
ht.last_partition = ht.last_partition + 1;

[ht.index_list, I] = sortrows( ht.index_list );
ht.file_list = ht.file_list(I);

index_list = ht.index_list;
file_list = ht.file_list;
next_index = ht.next_index;
last_partition = ht.last_partition;

save( [ht.dir 'index.mat'], 'index_list', 'file_list', 'next_index', 'last_partition' );

