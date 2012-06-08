function ht = purge( ht )

pos = 0;
fname = [ht.dir num2str(pos) '_data.mat'];
fname2 = [ht.dir num2str(pos) '_contents.mat'];

ht.index_list = [];
ht.file_list = [];

name_list = {};

while exist(fname, 'file' );
    S = whos( '-file', fname );
    names = {S.name};
        
    f = ( ismember( names, name_list ) );
    if any(f)
        data = load( fname );
        names = fieldnames( data );
        f = find( ismember( names, name_list ) );
        
        for m = 1:length(f)
            data = rmfield( data, names{f(m)} );
        end
        save( fname, '-v6', '-struct', 'data' );
        
        names = fieldnames( data )';
    end
    name_list = [name_list, names];

    pos = pos + 1;
    fname = [ht.dir num2str(pos) '_data.mat'];
    fname2 = [ht.dir num2str(pos) '_contents.mat'];
end

ht = reindex( ht );
