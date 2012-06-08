function [se2, sites2, back_map, start_pos] = splitStationTOBChange( se, sites, ...
    persistence, bf, min_difference )
% [se2, sites2, back_map, start_pos] = splitStationTOBChange( se, sites, persistence, badFlags )
%
% Break records at TOB changes lasting longer than "persistence" (default = 6 months)

if nargin < 3
    persistence = 0.5;
end
if nargin < 4
    bf = getBadFlags();
end
if nargin < 5
    min_difference = 4;
end

temperatureGlobals;
session = sessionStart;

%%%%%%
% Temporary Fix
% 
% There is an error with USSOD time of observation reports from October 1963
% to December 1981, causing both morning and afternoon measurements to report
% as 6 PM.  This is fixed in the dataset construction code, but as a
% temporary measure.

ussodc = stationSourceType( 'USSOD-C' );
ussodf = stationSourceType( 'USSOD-FO' );

for k = 1:length(se)
    I1 = findSources( se(k), [ussodc, ussodf] );
    if isempty( I1 )
        continue;
    end
    
    tob = se(k).tob;
    dates = se(k).dates;
    I2 = find( tob ~= 24 & dates > 1963 + 9/12 & dates < 1982 );
    
    I = intersect( I1, I2 );
    if isempty( I )        
        continue;
    end
    
    tob(I) = NaN;
    se(k) = setTOB( se(k), tob );
end

%%%%%%

sessionSectionBegin( 'Split Station TOB Changes' );
sessionWriteLog( ['Called with ' num2str( length(sites) ) ...
    ' stations and persistence ' num2str(persistence) ' years(s)'] );

frc = sessionFunctionCache;

hash = collapse( [collapse( md5hash( se ) ), collapse( md5hash( sites ) ), ...
    md5hash(persistence), md5hash(bf)] );
result = get( frc, hash );
if ~isempty( result )
    se2 = result{1};
    sites2 = result{2};
    back_map = result{3};
    start_pos = result{4};
    sessionWriteLog( [num2str( length(sites2) ) ' stations loaded from cache'] );
    sessionSectionEnd( 'Split Station TOB Changes' );
    return;
end

cnt = 1;
back_map = zeros(length(se), 1);
start_pos = ones(length(se), 1);

for k = 1:length(se)
    timePlot2( 'Spliting TOB changes', k / length(se) );    
    dates = se(k).dates;
    tob = se(k).tob;
    if all( isnan(tob) ) || max( tob ) == min( tob )
        se2(cnt) = se(k);
        sites2(cnt) = sites(k);
        back_map(cnt) = k;
        start_pos(cnt) = 1;
        cnt = cnt + 1;
        continue;
    end
    
    exc = findFlags( se(k), bf );
    group = dates.*0;
    
    last_pos = 1;
    cur_pos = 1;
    
    flagged = false( length(dates), 1 );
    flagged( exc ) = true;
    
    last_tob = tob(1);
    while cur_pos <= length(dates)
        if ~flagged( cur_pos )
            if ~isnan(last_tob) && ~flagged(last_pos) && ...
                    ~isnan( tob( cur_pos) ) && abs( tob( cur_pos ) - last_tob ) >= min_difference
                next_pos = cur_pos;
                good = true;
                while dates( next_pos ) - dates( cur_pos ) < persistence
                    next_pos = next_pos + 1;
                    if next_pos > length(dates)
                        good = false;                        
                        break;
                    end
                    if ~flagged( next_pos ) && ( isnan( tob(next_pos) ) || ...
                            abs( tob( next_pos ) - last_tob ) < min_difference )
                        good = false;
                        break;
                    end
                end
                if good
                    group( cur_pos:end ) = group( last_pos ) + 1;
                end
            end
            last_pos = cur_pos;
            last_tob = tob( cur_pos );
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

start_pos(cnt:end) = [];
back_map(cnt:end) = [];
        
parfor k = 1:length(se2)
    se2(k) = compress(se2(k));
end

save( frc, hash, {se2, sites2, back_map, start_pos} );
        
sessionWriteLog( [num2str( length(sites2) ) ' stations in result'] );
sessionSectionEnd( 'Split Station TOB Changes' );

    