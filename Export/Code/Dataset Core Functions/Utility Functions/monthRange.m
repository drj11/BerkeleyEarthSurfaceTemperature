function [min_month, max_month] = monthRange( se )
% [min_month, max_month] = monthRange( stationElement )
%
% Compute time range for stationElements
%
% The return values are canonical month numbers.  These can be converted to
% actual dates via:  year = (monthnum / 12) - 1/24 + 1600.

maxs = zeros(length(se),1);
mins = maxs + 1e6;

parfor k = 1:length(se)
    monthnum = se(k).monthnum;

    if ~isempty( monthnum )
        mins(k) = min(monthnum);
        maxs(k) = max(monthnum);
    end
end

min_month = min(mins);
max_month = max(maxs);