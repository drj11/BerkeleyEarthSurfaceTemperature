function f = findFlags( se, flags )

if ischar( flags )
    flags = dataFlags( flags );
end

fl = expand( se.flags );

if isempty(fl)
    f = [];
    return;
end

res = ismember( fl, flags );
res = any(res,2);
f = find(res);
