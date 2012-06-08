function v = get( ht, md5 )

if ischar( md5 )
    key = md5;
elseif iscell( md5 )
    key = strvcat( md5 );
elseif isa( md5, 'md5hash' )
    key = md5(:).key;
else
    error( 'Bad Accessor' );
end

[key2, sort_order] = sortrows( key );

key_stems = key2(:,1:2);
v2 = cell(length(key2(:,1)),1);
s2 = v2;

cuts = findCuts(key_stems);

res = cell(length(cuts(:,1)),1);
sz = size(cuts);
lc = sz(1);

warn = warning('query', 'directHashTable:get');
parfor ps = 1:lc
    warning( warn.state, 'directHashTable:get' );
    k = cuts(ps,1);
    j = cuts(ps,2);
    v_req = [ones(j-k+1,1)*['v_'], key2(k:j,:)];
    v_req = cellstr( v_req );
        
    res{ps} = getSingleFile( ht, key_stems(j,:), v_req );
end

for ps = 1:lc
    k = cuts(ps,1);
    j = cuts(ps,2);
    v2(k:j) = res{ps};
end

v(sort_order) = v2;

if length(v) == 1
    v = v{1};
end


function res = getSingleFile( ht, stem, keys )

pth = [ht.dir stem '_data.mat'];

ks = unique(keys);

warning('off', 'MATLAB:load:variableNotFound');
vals = load( pth, ks{:} );
warning('on', 'MATLAB:load:variableNotFound');

res = cell(length(keys),1);

for k = 1:length(res)
    try
        res{k} = vals.(keys{k});
    catch e
        if strcmp (e.identifier, 'MATLAB:nonExistentField' )
            warning( 'directHashTable:get', ...
                ['Key ' keys{k}(3:end) ' not found']);
            res{k} = [];
        else
            throw(e);
        end
    end
end


