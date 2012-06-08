function ss = addFlag( ss, flag )
% stationSite = addFlag( stationSite, flag )
%
% Adds a flag to the StationSite record

if ischar( flag )
    flag = siteFlags( flag );
end

ss.flags = unique([ss.flags, flag]);

ss.hash = computeHash( ss );