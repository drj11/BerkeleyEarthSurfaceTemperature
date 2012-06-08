function [se2, sites2, back_map, start_pos] = splitStationBreaks( se, sites, gap, bf )
% [se2, sites2, back_map, start_pos] = splitStationBreaks( se, sites, gap, badFlags )
%
% Break records over gaps longer than "gap" (default = 1 year)

if nargin < 3
    gap = 1;
end
if nargin < 4
    bf = getBadFlags();
end

temperatureGlobals;
session = sessionStart;

sessionSectionBegin( 'Split Station Gaps' );
sessionWriteLog( ['Called with ' num2str( length(sites) ) ...
    ' stations and gap length ' num2str(gap) ' year(s)'] );

frc = sessionFunctionCache;

hash = collapse( [collapse( md5hash( se ) ), collapse( md5hash( sites ) ), ...
    md5hash(gap), md5hash(bf)] );
result = get( frc, hash );
if ~isempty( result )
    se2 = result{1};
    sites2 = result{2};
    back_map = result{3};
    start_pos = result{4};
    sessionWriteLog( [num2str( length(sites2) ) ' stations loaded from cache'] );
    sessionSectionEnd( 'Split Station Gaps' );
    return;
end

cnt = 1;
back_map = zeros(length(se), 1);
start_pos = ones(length(se), 1);

for k = 1:length(se)
    timePlot2( 'Spliting Breaks', k / length(se) );    
    dates = se(k).dates;
    exc = findFlags( se(k), bf );
    group = dates.*0;
    
    last_pos = 1;
    cur_pos = 1;
    
    flagged = false( length(dates), 1 );
    flagged( exc ) = true;
    
    while cur_pos <= length(dates)
        if ~flagged( cur_pos )
            if ~flagged( last_pos )
                if dates( cur_pos ) - dates( last_pos ) > gap
                    group( cur_pos:end ) = group( last_pos ) + 1;
                end
            end
            last_pos = cur_pos;
        end
        cur_pos = cur_pos + 1;
    end
    
    un = unique( group );
    if length(un) == 1
        se2(cnt) = se(k);
        sites2(cnt) = sites(k);
        back_map(cnt) = k;
        start_pos(cnt) = 1;
        cnt = cnt + 1;
    else
        cnt_start = cnt;
        for j = 1:length(un)
            f = find( group == un(j) );
            se2(cnt) = compress( select( se(k), f ) );
            start_pos(cnt) = f(1);
            cnt = cnt + 1;
        end
        sites2(cnt_start:cnt-1) = sites(k);
        back_map(cnt_start:cnt-1) = k;
    end
end
        
back_map(cnt:end) = [];
start_pos(cnt:end) = [];

parfor k = 1:length(se2)
    se2(k) = compress(se2(k));
end

save( frc, hash, {se2, sites2, back_map, start_pos} );
        
sessionWriteLog( [num2str( length(sites2) ) ' stations in result'] );
sessionSectionEnd( 'Split Station Gaps' );

    