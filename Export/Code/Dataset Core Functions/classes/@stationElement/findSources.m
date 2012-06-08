function f = findSources( se, sources )

if ischar( sources )
    sources = stationSourceType( sources );
end

ss = expand( se.source );

if isempty(ss)
    f = [];
    return;
end

res = ismember( ss, sources );
res = any(res,2);
f = find(res);
