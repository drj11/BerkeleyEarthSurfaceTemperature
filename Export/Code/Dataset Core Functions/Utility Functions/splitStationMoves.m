function [se2, sites2, back_map, start_pos] = splitStationMoves( se, sites, ...
    declared_moves, suspected_moves )
% Break station records at documented and possible moves.

temperatureGlobals;
session = sessionStart;

if nargin < 3
    declared_moves = true;
    suspected_moves = true;
elseif nargin < 4
    suspected_moves = false;
end

if ~declared_moves && ~suspected_moves
    se2 = se;
    sites2 = sites;
    back_map = (1:length(se))';
    start_pos = ones( length(se), 1 );
    return;
end

sessionSectionBegin( 'Split Station Moves' );
sessionWriteLog( ['Called with ' num2str( length(sites) ) ' stations'] );

frc = sessionFunctionCache;

hash = collapse( [collapse( md5hash( se ) ), collapse( md5hash( sites ) ), ...
    md5hash( [declared_moves, suspected_moves] )] );

result = get( frc, hash );
if ~isempty( result )
    se2 = result{1};
    sites2 = result{2};
    back_map = result{3};
    start_pos = result{4};
    sessionWriteLog( [num2str( length(sites2) ) ' stations loaded from cache'] );
    sessionSectionEnd( 'Split Station Moves' );
    return;
end

cnt = 1;
back_map = zeros( length(se), 1 );
start_pos = ones( length(se), 1 );

for k = 1:length(se)
    timePlot2( 'Spliting Moves', k / length(se) );   
    if declared_moves && suspected_moves
        cuts = union( sites(k).relocated, sites(k).possible_relocated );
    elseif declared_moves
        cuts = sites(k).relocated;
    else
        cuts = sites(k).possible_relocated;
    end
    
    if isempty(cuts)
        se2(cnt) = se(k);
        sites2(cnt) = sites(k);
        back_map(cnt) = k;
        start_pos(cnt) = 1;
        cnt = cnt + 1;
        continue;
    end
    
    dates = se(k).dates;
    cuts = [min(dates)-1, cuts, max(dates) + 1];
    cnt_start = cnt;
    for j = 1:length(cuts)-1
        f = find( dates >= cuts(j) & dates < cuts(j+1) );
        if ~isempty(f)
            se2(cnt) = select( se(k), f );
            start_pos(cnt) = f(1);
            cnt = cnt + 1;
        end
    end
    sites2(cnt_start:cnt-1) = sites(k);
    back_map(cnt_start:cnt-1) = k;    
end

back_map(cnt:end) = [];
start_pos(cnt:end) = [];

parfor k = 1:length(se2)
    se2(k) = compress(se2(k));
end

save( frc, hash, {se2, sites2, back_map, start_pos} );
        
sessionWriteLog( [num2str( length(sites2) ) ' stations in result'] );
sessionSectionEnd( 'Split Station Moves' );

    