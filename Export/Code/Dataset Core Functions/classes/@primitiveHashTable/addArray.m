function hash = addArray( ht, val, sup )
% Same as add but treats each arrray element seperately.

if length( val ) == 0
    hash = md5hash;
    hash(1) = [];
    return;
end

if iscell(val)
    cell_mode = 1;
else
    cell_mode = 0;
end

if nargin <= 2
    sup = [];
end

md5(1:length(val)) = md5hash;
parfor k = 1:length(val)
    if isa( val(k), 'md5hash' )
        md5(k) = md5hash( ['HASH:' val(k).key] );
    else
        md5(k) = md5hash(val(k));
    end
end

key = md5(:).key;

[key2, sort_order] = sortrows( key );
val = val(sort_order);
if nargin > 2
    sup = sup(sort_order);
end

key_stem = key2(:,1:2);

cuts = findCuts(key_stem);

s = size(cuts);
lc = s(1);
val_list = cell( lc, 1 );
sup_list = cell( lc, 1 );
key_list = cell( lc, 1 );
path_list = cell( lc, 1 );
for ps = 1:lc
    k = cuts(ps, 1);
    j = cuts(ps, 2);
    val_list{ps} = val(k:j);
    if isempty(sup)
        sup_list{ps} = [];
    else
        sup_list{ps} = sup(k:j);
    end
    key_list{ps} = key2(k:j, : );
    path_list{ps} = [ht.dir key_stem(k,:) '_data.mat'];
end
parfor ps = 1:lc
    saveBlock( path_list{ps}, key_list{ps}, cell_mode, val_list{ps}, sup_list{ps} );
end

hash = md5;



function saveBlock( pth, key2, cell_mode, val, sup )

num = length(val);

v_req = cell( length(val), 1);
for m = 1:num
    if ~cell_mode
        eval( ['v_' key2(m,:) ' = val( m );'] );
        v_req{m} = ['v_' key2(m,:)];
        if ~isempty( sup )
            eval( ['s_' key2(m,:) ' = sup( m );'] );
            v_req{m+num} = ['s_' key2(m,:)];
        end
    else
        eval( ['v_' key2(m,:) ' = val{ m };'] );
        v_req{m} = ['v_' key2(m,:)];
        if isempty( sup )
            eval( ['s_' key2(m,:) ' = sup{ m };'] );
            v_req{m+num} = ['s_' key2(m,:)];
        end
    end
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
    
    v_req = setdiff( v_req, contents );
    
    if isempty(v_req)
        return;
    end
    v_req{end+1} = '-append';
else
    contents = {};
end     

attempts = 0;
done = 0;

% If system is very busy, too many disk requests can result in temporary
% failure.  This is especially likely if the system is using the disk for
% paging.  Temporarily delay the commit and hope the condition clears.
while ~done
    try
        save(pth, v_req{:}, '-v6');
        done = 1;
        contents( end+1:end+length(v_req) ) = v_req;
        save(pth2, 'contents', '-v6');        
    catch ME
        attempts = attempts + 1;
        if attempts > 20
            error( 'Save failed despite many attempts.' );            
        end
        pause( 10 ); % Wait 10 seconds for conflicts to clear
    end
end

