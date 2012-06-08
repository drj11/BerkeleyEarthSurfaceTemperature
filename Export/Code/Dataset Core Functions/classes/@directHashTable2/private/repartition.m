function ht = repartition( ht )

pos = 0;
fname = [ht.dir num2str(pos) '_contents.mat'];
dname = [ht.dir num2str(pos) '_data.mat'];
sz = 0;

max_bytes = 10e6;

blocks = zeros( 20000, 2 );
cnt = 1;
blocks( 1, 1 ) = pos;

while exist(dname, 'file' ) && exist(fname, 'file' );
    dd = dir( dname );    
    sz = sz + dd.bytes;        
        
    if sz > max_bytes
        blocks( cnt, 2 ) = pos;
        blocks( cnt+1, 1 ) = pos + 1;
        cnt = cnt + 1;
        pos = pos + 1;
        sz = 0;
    end
    
    pos = pos + 1;
    fname = [ht.dir num2str(pos) '_contents.mat'];
    dname = [ht.dir num2str(pos) '_data.mat'];
end
blocks( cnt, 2 ) = pos - 1;
blocks( cnt+1:end, : ) = [];

for k = 1:cnt
    fname2 = [ht.dir num2str(k-1) '_contents.mat'];
    dname2 = [ht.dir num2str(k-1) '_data.mat'];
    if blocks(k,1) == blocks(k,2)
        pos = blocks(k, 1);
        
        fname1 = [ht.dir num2str(pos) '_contents.mat'];
        dname1 = [ht.dir num2str(pos) '_data.mat'];

        if exist( fname2, 'file' )
            delete( fname2 );
            delete( dname2 );
        end
        
        movefile( fname1, fname2 );
        movefile( dname1, dname2 );
    elseif blocks(k,1) < blocks(k,2)           
        data = struct();
        contents = [];

        for m = blocks(k,1) : blocks(k,2)
            fname1 = [ht.dir num2str(m) '_contents.mat'];
            dname1 = [ht.dir num2str(m) '_data.mat'];
        
            dat = load( dname1 );
            cc = load( fname1 );

            names = fieldnames( dat );
            for m = 1:length(names)
                data.(names{m}) = dat.(names{m});
            end
            contents = [contents; cc.contents];
        end            
        save( fname2, 'contents', '-v6' );
        save( dname2, '-struct', 'data', '-v6' );
    end
end            
    
for k = cnt+1:max(max(blocks))+1
    fname2 = [ht.dir num2str(k-1) '_contents.mat'];
    dname2 = [ht.dir num2str(k-1) '_data.mat'];
    if exist(dname2, 'file' ) && exist(fname2, 'file' );
        delete( fname2 );
        delete( dname2 );
    end
end

ht.last_partition = 0;
ht = rebuild( ht );