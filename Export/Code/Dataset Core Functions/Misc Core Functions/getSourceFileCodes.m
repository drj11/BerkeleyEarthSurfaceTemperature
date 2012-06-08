function [sources, monthly] = getSourceFileCodes()

sources = {'USSOD_fo', 'USSOD_coop', 'GSOD', 'GHCN-D', ...
    'GHCN-M', 'HadCRU', 'SCAR', 'USHCN-M', 'USSOM', 'WMSSC', ...
    'Daily_Merged', 'Monthly_Merged', ...
    'Daily', ...
    'Monthly'};

monthly = [0,0,0,0,1,1,1,1,1,1,0,1,...
    0,1];

sources2 = sources;

for k = 1:length(sources)
    if ~monthly(k)
        sources2{end+1} = ['Monthly_Averaged_' sources{k}];
        monthly(end+1) = 1;        
    end
end

sources = sources2;