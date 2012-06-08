function hash = add( ht, val, sup )

if isa( val, 'md5hash' )
    if length(val) > 1
        val2 = collapse(val);
    else
        val2 = val;
    end
    md5 = md5hash( ['HASH:' val2.key] );
else
    md5 = md5hash(val);
end

key = md5.key;

pth = [ht.dir key(1:2) '_data.mat'];

eval( ['v_' key ' = val;'] );
v{1} = ['v_' key];
if nargin > 2
    eval( ['s_' key ' = sup;'] );
    v{2} = ['s_' key];
end

pth2 = [pth(1:end-9) '_contents.mat'];

if exist( pth, 'file' )
    if exist( pth2, 'file' )
        A = load( pth2, 'contents' );
        contents = A.contents;
    else
        contents = who( '-file', pth );
        save( pth2, 'contents', '-v6');
    end
    
    v = setdiff( v, contents );
    if isempty(v)
        hash = md5;
        return;
    end
    v{end+1} = '-append';
else
    contents = {};
end

save(pth, v{:}, '-v6');
contents( end+1:end+length(v) ) = v;
save(pth2, 'contents', '-v6');        

hash = md5;