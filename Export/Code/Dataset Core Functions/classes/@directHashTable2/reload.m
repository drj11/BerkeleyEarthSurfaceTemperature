function ht = reload( ht )

if nargout < 1
    error( 'Requires output' );
end

fname = [ht.dir 'index.mat'];
if ~exist( fname, 'file' ) 
    ht.next_index = 0;
    ht.index_list = [];
    ht.file_list = [];
    ht.last_partition = 0;
else
    data = load( [ht.dir 'index.mat'] );
    ht.next_index = data.next_index;
    ht.index_list = data.index_list;
    ht.file_list = data.file_list;
    if isfield( data, 'last_partition' )
        ht.last_partition = data.last_partition;
    else
        ht.last_partition = 0;
    end
end

if ~isCurrent( ht ) || isa( ht.index_list, 'md5hash' )
    ht = rebuild( ht );
end

if ht.last_partition > 5000
    ht = repartition( ht );
    ht.last_partition = 0;
end