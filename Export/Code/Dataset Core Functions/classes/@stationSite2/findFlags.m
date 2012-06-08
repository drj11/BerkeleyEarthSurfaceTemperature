function f = findFlags( ss, flags )
% indices = findFlags( stationSite, flag_list )
%
% Find data points having one or more of the flags listed in flag_list

if ischar( flags )
    flags = siteFlags( flags );
end

matched = zeros( length(ss), 1 );
parfor k = 1:length( ss )
    matched(k) = any(ismember( ss(k).flags, flags ))
end

f = find(matched);
