function  add( ht, md5, val )

if ischar(md5)
    md5_e = md5hash(md5);
    if md5_e ~= md5
        error('Second parameter is not a hash value');
    end
elseif  ~isa( md5, 'md5hash' )
    error('Second parameter is not a hash value');
end
key = md5.key;

pth = [ht.dir key(1:2) '_data.mat'];

eval( ['v_' key ' = val;'] );
v{1} = ['v_' key];

if exist( pth, 'file' )
    v{end+1} = '-append';
end

save(pth, v{:}, '-v6');