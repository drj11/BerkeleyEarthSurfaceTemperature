function [v, s] = get( ht, md5 )

if ~isCurrent( ht )
    ht = reload( ht );
end

if isa( md5, 'md5hash' )
    key = md5(:).key;
else
    error( 'Bad Accessor' );
end

[key2, sort_order] = sortrows( key );
md5 = md5(sort_order);

v2 = cell(length(key2(:,1)),1);
s2 = v2;

indices = findIndices( ht, md5 );
files = NaN( length(indices), 1 );
f = ~isnan( indices );

files(f) = ht.file_list( indices(f) );

un = unique( files( ~isnan(files) ) );

groups = cell( length(un), 1 );
for k = 1:length(un)
    f = find( files == un(k) );
    groups{k} = f;
end

res = cell(length(groups),1);
argout = nargout;
lc = length(groups);

for blocks = 1:40:lc
    next = min( lc, blocks+39 );

    parfor ps = blocks:next
        lg = length( groups{ps} );

        v_req = [ones(lg,1)*('v_'), key2(groups{ps},:)];
        if argout > 1
            v_req(end+1:end+lg,:) = [ones(lg,1)*('s_'), key2(groups{ps},:)];
        end
        v_req = cellstr( v_req );

        res{ps} = getSingleFile( ht, un(ps), v_req );
    end

    for ps = blocks:next
        if argout <= 1
            v2(groups{ps}) = res{ps};
        else
            v2(groups{ps}) = res{ps}(1:end/2);
            s2(groups{ps}) = res{ps}(end/2+1:end);
        end
    end
end

if argout > 1
    s(sort_order) = s2;
    v(sort_order) = v2;
else
    v(sort_order) = v2;
end

if length(v) == 1
    v = v{1};
    if argout > 1
        s = s{1};
    end
end