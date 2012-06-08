function lookups = findIndices( ht, hashes )

if ~isCurrent( ht )
    ht = reload( ht );
end

lookups = NaN( length(hashes), 1 );
if isempty( ht.index_list )
    return;
end

vals = [ht.index_list];
lh = length(hashes);

vv = hashes(:).val;
pv = quickSearch( vv(:,1), vals(:,1) );

for k = 1:lh    
    p = pv(k);
    v = vv(k,:);
    if ~isnan(p)
        cnt = 0;
        while v(1) == vals( p + cnt, 1 ) && v(2) < vals( p+cnt, 2 )
            cnt = cnt - 1;
            if cnt < 1
                cnt = 1;
                break;
            end
        end
        while v(1) == vals( p + cnt, 1 ) && v(2) > vals( p+cnt, 2 )
            cnt = cnt + 1;
            if cnt > lh
                cnt = lh;
                break;
            end
        end
        if all( v == vals( p+cnt, : ) )
            lookups(k) = p+cnt;
        end
    end
end

    