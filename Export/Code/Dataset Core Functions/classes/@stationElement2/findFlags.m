function f = findFlags( se, flags )
% indices = findFlags( stationElement, flag_list )
%
% Find data points having one or more of the flags listed in flag_list

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
