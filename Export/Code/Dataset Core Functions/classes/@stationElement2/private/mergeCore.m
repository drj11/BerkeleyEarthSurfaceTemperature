function [result_st, result_count] = mergeCore( st, bf, action, repeats )
% station_structure = mergeCore( station_structure, bad_flags action )
%
% The core of the station record merging / averaging code.  Should not be
% called directly.

if nargin < 4
    repeats = 1;
end

switch lower(action)
    case {'raw'}
        result_st = st;
        return;
    case {'merge_any'}
        command = 1;
    case {'merge_consistent'}
        command = 2;
    case {'average_similar'}
        command = 3;
    case {'average_dissimilar'}
        command = 4;
    case {'remove_duplicates'}
        command = 5;
    otherwise
        error( 'Action instruction not understood' );
end

if length( st.frequency ) > 1
    error( 'All records must have same frequency type' );
end

freq_type = upper( stationFrequencyType( st.frequency ) );

target_dates = unique( st.dates );

result_st = st;
result_st.dates = target_dates;

dates = double( st.dates );
dates(end+1) = -Inf; % A placeholder to ensure we grab the last value;

ld = length( dates )-1;

[~, c] = mode( double(dates) );

% No duplicates, nothing to do here.
if c == 1
    result_st = st;
    result_count = 1;
    return;
end

% initialize data holders
data = zeros( ld, c, 'single' );
unc = data;
num = data.*NaN;
tob = data.*NaN;
flagged = false( ld, c );
orig_flagged = any( ismember( st.flags, bf ), 2 );

s = size( st.flags );
lf = s(2);
flags = zeros( ld, c*lf );

s = size( st.source );
ls = s(2);
source = zeros( ld, c*ls );

data( 1:ld, 1 ) = st.data;
unc( 1:ld, 1 ) = st.uncertainty;
num( 1:ld, 1 ) = st.num_measurements;
tob( 1:ld, 1 ) = st.time_of_observation;
flags( 1:ld, 1:lf) = st.flags;
source( 1:ld, 1:ls) = st.source;
flagged( 1:ld, 1) = orig_flagged;

% Special processing to accelerate certain cases.
if command == 5 || command == 2
    A = [double(dates(1:ld)), double(data(:, 1)), double(unc(:,1)), double(num(:,1)), double(tob(:,1))];
    [~,I] = sortrows( A );
    
    dates( 1:ld ) = dates(I);
    data = data(I,:);
    unc = unc(I,:);
    num = num(I,:);
    tob = tob(I,:);
    flags = flags(I,:);
    source = source(I,:);
    flagged = flagged(I,:);
end

counts = zeros( ld, c );

% Data is "stored" at the last occurence.  Located these and mark the
% associated lines.
if command == 5
    f = find( ( dates(1:end-1) ~= dates( 2:end ) ) | ...
        [( data(1:end-1, 1) ~= data( 2:end, 1 ) ); true] );
else
    f = find( dates(1:end-1) ~= dates( 2:end ) );
end    
used = false( ld+1, 1 );
used(f) = true;
counts(f, 1) = 1;

for k = 2:c
    if command == 5 
        f = find( ( (dates( 1:end-k ) ~= dates( k+1:end )) | ...
            [(data( 1:end-k, 1 ) ~= data( k+1:end, 1 )); true]) & ~used( 1:end-k ) );
    else
        f = find( (dates( 1:end-k ) ~= dates( k+1:end )) & ~used( 1:end-k ) );        
    end
    
    if isempty(f)
        continue;
    end
    data( f + k - 1, k ) = data(f);
    num( f + k - 1, k ) = num(f);
    tob( f + k - 1, k ) = tob(f);
    unc( f + k - 1, k ) = unc(f);
    flagged( f + k - 1, k ) = flagged(f);
    flags( f + k - 1, (1:lf) + lf*(k-1) ) = flags(f,1:lf);
    source( f + k - 1, (1:ls) + ls*(k-1) ) = source(f,1:ls);
    
    used(f) = true;
    counts(f + k - 1, k) = 1;
end

% Remove the lines that have now been stacked.
f = (sum( counts, 2 ) > 0);

dates = dates(f);
data = data(f,:);
num = num(f,:);
unc = unc(f,:);
tob = tob(f,:);
flags = flags(f,:);
source = source(f,:);
flagged = flagged(f,:);
counts = counts(f,:);

f = find( sum(counts,2) > 1 );

data2 = data( f, : );
unc2 = unc( f, : );
counts2 = counts( f, : );
num2 = num( f, : );
tob2 = tob( f, : );
flags2 = flags( f, : );
source2 = source( f, : );
flagged2 = flagged( f, : );

no_flags = ( sum( flagged2, 2 ) == 0 );
all_flags = ( sum( flagged2, 2 ) == sum( counts2, 2 ) );
some_flags = (~no_flags & ~all_flags);

mask = false( size( counts2 ) );
if ~isempty( flagged2 )
    mask( some_flags, : ) = (flagged2( some_flags, : ) == 1);
end

num_est = [];
tob_est = [];
num_conflict = [];
tob_conflict = [];
consistent = [];
avg_inconsistent = [];

% Handle Data and Uncertainty
switch command
    case {1, 5}  % merge_any
        data2( mask ) = 0;
        unc2( mask ) = 0;
        counts2( mask ) = 0;
        
        data_high = data2 + unc2;
        data_high( ~counts2 ) = Inf;        
        data_low = data2 - unc2;
        data_low( ~counts2 ) = -Inf;
        
        [data(f, 1), unc(f, 1), consistent] = rangeResolver( data_high, data_low );
        
        unc3 = unc2;
        unc3( ~counts2 ) = Inf;
        min_unc = min( unc3 , [], 2 );
        I = ( unc(f,1) < min_unc );
        if any(I)
            unc(f(I),1) = min_unc(I);
        end
        
        if command == 5
            result_st.dates = dates;
        end
        result_st.data = data(:,1);
        result_st.uncertainty = unc(:,1);
    case 2  % merge_consistent
        data2( mask ) = 0;
        unc2( mask ) = 0;
        counts2( mask ) = 0;               
        
        data_high = data2 + unc2;
        data_high( ~counts2 ) = Inf;        
        data_low = data2 - unc2;
        data_low( ~counts2 ) = -Inf;

        [datum, uncs, consistent] = rangeResolver( data_high, data_low );
                
        data(f(consistent), 1) = datum(consistent);
        unc(f(consistent), 1) = uncs(consistent);        
                
        unc3 = unc2;
        unc3( ~counts2 ) = Inf;
        min_unc = min( unc3 , [], 2 );
        I = ( unc(f,1) < min_unc & min_unc ~= Inf );
        if any(I)
            unc(f(I),1) = min_unc(I);
        end

        % The following is a somewhat dumb response.  It takes all of the
        % values that can't be merged in a mutually consistent way and
        % treats them as independent multi-values.  Ideally we would want
        % to see if subsets of these points could be merged.  However,
        % ultimately these values will be merged at later stages, so the
        % impact is probably not great.
        bad = ~consistent;
            
        cc = ( sum( counts2(bad, :), 2 ) > 1 );
        select = find(bad);
        select = select( cc );
        template = false( size( counts2 ) );
        template( select, 2:end ) = true;
        template( select, : ) = template( select, : ) & (counts2( select, : ));
        I = find( template );
        
        sz = size( data );
        additional = length(I);
        
        select = sz(1)+1:sz(1)+additional;
        
        dates2 = dates(f)*ones(1, length(counts2(:,1)) );
        dates( select ) = dates2( I );
        data( select, 1 ) = data2( I );
        unc( select, 1 ) = unc2( I );
        num( select, 1 ) = num2( I );
        tob( select, 1 ) = tob2( I );
        counts( select, 1 ) = counts2( I );
        flagged( select, 1 ) = flagged( I );
        
        counts2( I ) = 0;
        counts(f,:) = counts2;
        
        for j = 1:lf
            flags_x = flags2( :, j:lf:end );
            flags( select, j ) = flags_x( I );
        end
        for j = 1:ls
            source_x = source2( :, j:ls:end );
            source( select, j ) = source_x( I );
        end            
        
        [~,I] = sort(dates);
        dates = dates(I);
        data = data(I,:);
        num = num(I,:);
        tob = tob(I,:);
        unc = unc(I,:);
        counts = counts(I,:);
        flags = flags(I,:);
        source = source(I,:);
        flagged = flagged(I,:);                
        
        f = find( sum(counts,2) > 1 );
        consistent = true( length(f), 1 ); % All that reach this point are consitent mergers.
        
        num2 = num(f,:);
        tob2 = tob(f,:);
        flags2 = flags(f,:);
        source2 = source(f,:);
        counts2 = counts(f,:);
        flagged2 = flagged(f,:);
       
        no_flags = ( sum( flagged2, 2 ) == 0 );
        all_flags = ( sum( flagged2, 2 ) == sum( counts2, 2 ) );
        some_flags = (~no_flags & ~all_flags);

        mask = false( size( counts2 ) );
        mask( some_flags, : ) = (flagged2( some_flags, : ) == 1);        
        
        result_st.dates = dates;
        result_st.data = data(:,1);
        result_st.uncertainty = unc(:,1);
    case 3  % average similar
        data2( mask ) = 0;
        unc2( mask ) = 0;
        counts2( mask ) = 0;
        
        weight = zeros( size( data2 ) );
        weight( unc2 > 0 ) = 1./unc2( unc2 > 0 ).^2;
        
        datum  = sum( data2.*weight, 2 ) ./ sum( counts2.*weight, 2 );
        data(f, 1) = datum;
        
        datum = datum*ones(1, c).*counts2;
        stat = sqrt( sum( unc2.^2, 2 ) ./ sum( counts2, 2 ).^2 );
        cc2 = ( sum( counts2, 2 ) - 1 );
        cc2( cc2 == 0 ) = 1;
        
        spread = sqrt( sum( (data2 - datum).^2.*weight, 2 ) ./ cc2 );
        avg_inconsistent = (spread > 2);
        spread( spread < 1 ) = 1;

        % We are expanding the statistical error to account for the spread
        % in the data, since these values are all supposed represent the
        % same datum, and hence the spread is an estimate of the error.
        unc( f, 1 )  = stat.*spread;
        
        result_st.data = data(:,1);
        result_st.uncertainty = unc(:,1);
    case 4 % average dissimilar
        data2( mask ) = 0;
        unc2( mask ) = 0;
        counts2( mask ) = 0;
        
        data( f, 1 )  = sum( data2, 2 ) ./ sum( counts2, 2 );
        unc( f, 1 )  = sqrt( sum( unc2.^2, 2 ) ./ sum( counts2, 2 ).^2 );
        
        result_st.data = data(:,1);
        result_st.uncertainty = unc(:,1);
end

% Handle other terms
switch command
    case {1, 3, 4, 5, 2}
        [num_all, num_est] = getIndexValue( num2, mask );
        [tob_all, tob_est] = getIndexValue( tob2, mask );
        
        num_conflict = ( num_all == -9999 );
        tob_conflict = ( tob_all == -9999 );
        
        num_all( num_conflict ) = NaN;
        tob_all( tob_conflict ) = NaN;
        
        num( f, 1 ) = num_all;
        tob( f, 1 ) = tob_all;
                
        flags( f, : ) = maskOverFlags( flags2, mask, lf);
        source( f, : ) = maskOverFlags( source2, mask, ls );                
        
        result_st.num_measurements = num(:,1);
        result_st.time_of_observation = tob(:,1);
        result_st.source = source;
        result_st.flags = flags;
end


% Special case, dissimilar averaging has an extra requirement that
% values share a common source.  We enforce that here.
if command == 4 && repeats > 0
    bad = false( length(result_st.data), 1 );
    source = result_st.source;
    for j = 1:size( source, 1 )
        I = ( source( j, : ) > 0 );
        [~, c] = mode( source( j, I ) );
        if c ~= repeats
            bad(j) = true;
        end
    end
    bad( sum( counts, 2 ) ~= repeats ) = true;
    
    if any(bad)
        counts(bad,:) = [];
        result_st.dates(bad) = [];
        result_st.data(bad) = [];
        result_st.num_measurements(bad) = [];
        result_st.time_of_observation(bad) = [];
        result_st.uncertainty(bad) = [];
        result_st.source(bad,:) = [];
        result_st.flags(bad,:) = [];
    end
end

% Flags to be added

% Average includes missing values (allowed for some kinds of averages)
f2 = ( sum( counts, 2 ) > 1);
if any(f2)
    switch command
        case 1
            name = 'MULTIPLE_VALUES_MERGED';
        case 2
            name = 'CONSISTENT_VALUES_MERGED';
        case 3
            name = 'AVERAGED_SIMILAR_VALUES';
        case 4
            name = 'AVERAGED_DISSIMILAR_VALUES';
        case 5
            name = 'DUPLICATES_REMOVED';
    end
    result_st.flags(f2, end+1) = dataFlags( [freq_type '_' name] );
end


% Average includes missing values (allowed for some kinds of averages)
f2 = ( sum( counts, 2 ) < repeats );
if any(f2)
    result_st.flags(f2, end+1) = dataFlags( [freq_type '_AVERAGE_MISSING_VALUES'] );
end

% Average was made after dropping bad flaged values
if any( some_flags )
    result_st.flags( f(some_flags), end+1) = dataFlags( [freq_type '_MERGER_BAD_FLAGGED_VALUE_DROPPED'] );
end

% Num of observations conflicted amongst averaged records
if any( num_conflict )
    result_st.flags( f(num_conflict), end+1) = dataFlags( [freq_type '_MERGER_CONFLICT_NUM'] );
end

% Time of observation conflicted amongst averaged records
if any( tob_conflict )
    result_st.flags( f(tob_conflict), end+1) = dataFlags( [freq_type '_MERGER_CONFLICT_TOB'] );
end

% Time of observation was based on reports from some but not all records.
if any( tob_est )
    result_st.flags( f(tob_est), end+1) = dataFlags( [freq_type '_MERGER_ESTIMATED_TOB'] );
end

% Number of observations was based on reports from some but not all records.
if any( num_est )
    result_st.flags( f(num_est), end+1) = dataFlags( [freq_type '_MERGER_ESTIMATED_NUM'] );
end

% Number of observations was based on reports from some but not all records.
if any( consistent )
    result_st.flags( f(consistent), end+1) = dataFlags( [freq_type '_MERGED_CONSISTENT'] );
end

if command == 1
    % Number of observations was based on reports from some but not all records.
    if any( ~consistent )
        result_st.flags( f(~consistent), end+1) = dataFlags( [freq_type '_MERGED_INCONSISTENT'] );
    end
end

% Number of observations was based on reports from some but not all records.
if any( avg_inconsistent )
    result_st.flags( f(avg_inconsistent), end+1) = dataFlags( [freq_type '_AVERAGED_INCONSISTENT'] );
end


result_count = sum( counts, 2 );

% Clean up the flag tables.
result_st.source = cleanFlags( result_st.source );
result_st.flags = cleanFlags( result_st.flags );

% Replace very fine differences with nearest ten thousandths.  This is useful
% in support of the compression algorithms and underflow issues.
dd = abs(diff( result_st.data ));
f = ( dd > 1e-7 );
if min(dd(f)) < 0.0001
    data = round( result_st.data * 10000 ) / 10000;
    unc = round( result_st.uncertainty * 10000 ) / 10000;
    result_st.data = data;
    result_st.uncertainty = unc;
end





function [v, est] = getIndexValue( M, mask )
% Determine the best value for NUM and TOB

v1 = max( M, [], 2 );
v2 = min( M, [], 2 );

va = v1;
f = (v1 ~= v2) & ~( isnan(v1) & isnan(v2) );
va(f) = -9999;

% Figure out masked values
M(mask) = NaN;

v1 = max( M, [], 2 );
v2 = min( M, [], 2 );

vb = v1;
f = (v1 ~= v2) & ~( isnan(v1) & isnan(v2) );
vb(f) = -9999;

% Masked values
v = vb;
est = false( size(v) );
est( any( isnan(vb), 2 ) ) = true;
est( isnan(v) & any( isnan(va), 2 ) ) = true;

v( isnan(v) ) = va( isnan(v) );
est( isnan(v) ) = false;




function [val, err, consistent] = rangeResolver( max_table, min_table )
% Attempt to find self-consistent description from upper and lower bounds.

s = size( max_table );
val = zeros( s(1), 1 );
err = val;

d_high = min( max_table, [], 2 );
d_low = max( min_table, [], 2 );

good = (d_high >= d_low);

consistent = good;

val(good) = (d_high(good) + d_low(good)) / 2;
err(good) = (d_high(good) - d_low(good)) / 2;

bad = ~good;

if all(good)
    return;
end

max_table2 = max_table( bad, : );
min_table2 = min_table( bad, : );

val2 = zeros( size( max_table2 ) );
err2 = zeros( size( max_table2 ) );
for k = 1:s(2)
    select = [1:k-1, k+1:s(2)];

    [val2(:,k), err2(:,k)] = ...
        rangeResolver( max_table2( :, select ), min_table2( :, select ) );
    
    max_table2 = val2 + err2;
    min_table2 = val2 - err2;
    
    d_high = max( max_table2, [], 2 );
    d_low = min( min_table2, [], 2 );
    
    val(bad) = (d_high + d_low) / 2;
    err(bad) = (d_high - d_low) / 2;
end




function flags = maskOverFlags( flags, mask, width )
% Uses the mask to eliminate all values in a flag table

s1 = size( flags );

for k = 1:width
    select = k:width:s1(2);
    flags( :, select ) = flags( :, select ) .* ~mask;
end

