function ht = reindex( ht )

pos = 0;
fname = [ht.dir num2str(pos) '_data.mat'];
fname2 = [ht.dir num2str(pos) '_contents.mat'];

ht.index_list = [];
ht.file_list = [];

while exist(fname, 'file' );
    S = whos( '-file', fname );
    names = {S.name};
    
    hashes = md5hash;
    hashes(1:length(names)) = md5hash;
    for k = 1:length(names)
        hashes(k) = md5hash( names{k}(3:end) );
    end
    contents = unique( hashes );
    
    save( fname2, '-v6', 'contents' );
    
    pos = pos + 1;
    fname = [ht.dir num2str(pos) '_data.mat'];
    fname2 = [ht.dir num2str(pos) '_contents.mat'];
end

ht = rebuild( ht );
