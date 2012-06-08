function addArray( ht, hash, val )

if isempty(val)
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


key = hash(:).key;

[key2, sort_order] = sortrows( key );
val = val(sort_order);

key_stem = key2(:,1:2);

cuts = findCuts(key_stem);

s = size(cuts);
lc = s(1);
val_list = cell( lc, 1 );
key_list = cell( lc, 1 );
path_list = cell( lc, 1 );
for ps = 1:lc
    k = cuts(ps, 1);
    j = cuts(ps, 2);
    val_list{ps} = val(k:j);
    key_list{ps} = key2(k:j, : );
    path_list{ps} = [ht.dir key_stem(k,:) '_data.mat'];
end
parfor ps = 1:lc
    saveBlock( path_list{ps}, key_list{ps}, cell_mode, val_list{ps} );
end



function saveBlock( pth, key2, cell_mode, val )

num = length(val);

v_req = cell( num, 1 );
for m = 1:num
    if ~cell_mode
        eval( ['v_' key2(m,:) ' = val( m );'] );
        v_req{m} = ['v_' key2(m,:)];
    else
        eval( ['v_' key2(m,:) ' = val{ m };'] );
        v_req{m} = ['v_' key2(m,:)];
    end
end

if exist( pth, 'file' )
    v_req{end+1} = '-append';
end
save(pth, v_req{:}, '-v6');
