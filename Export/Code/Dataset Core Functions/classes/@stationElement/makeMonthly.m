function sx = makeMonthly( se, bad_flags )

persistent monthly_duplicate_flags monthly_merge_flags;

if nargin < 2
    bad_flags = [];
end

if se.frequency == stationFrequencyType( 'm' );
    sx = se;
    return;
elseif se.frequency ~= stationFrequencyType( 'd' )
    error( 'Not possible to make monthly.' );
end 

if length(se) > 1
    error( 'Can not be called with an array' );
end

if isMultiValued( se )
    se = makeSingleValued( se, bad_flags );
end

if numItems( se ) == 0
    if isstruct( se.record_type )
        sx = stationElement(); %How does this occur?
    else       
        sx = stationElement( se.record_type, 'm' );
    end
    return;
end

dates = expand( se.dates );
data = expand( se.data );

tob = double( se.time_of_observation );
f = ( tob == 255 );
tob(f) = NaN;

num = double( se.num_measurements );
f = ( num == 65535 );
num(f) = NaN;

flags = expand( se.flags );
source = expand( se.source );

flag_pos = findFlags( se, bad_flags );
flagged = dates.*0;
flagged( flag_pos ) = 1;

f = find(isnan(dates));  %Why does this occur?
if ~isempty(f)
    dates(f) = [];
    data(f) = [];
    tob(f) = [];
    num(f) = [];
    flags(f, :) = [];
    source(f, :) = [];
    flagged(f, :) = [];
end

f = find(isnan(flags));
flags(f) = 0;

if isempty(dates)
    sx = stationElement( se.record_type, 'm' );
    return;
end

s = size(flags);
if s(1) == 0
    flags(1:length(data),1) = 0;
end

v = datevec( double( dates ) );
dates = (v(:,1) - 1600)*12 + v(:,2);
dates(end+1) = dates(end) + 1;

ofs = 1;

ld = length(dates);

first = [1:ld-ofs];
last = [ofs+1:ld];

used = dates.*0;

counts = data.*0; 

new_flags = flags;
new_flags(:,end+1:31*end ) = 0;

lf = length(flags(1,:));

new_source = source;
new_source(:,end+1:31*end ) = 0;

ls = length(source(1,:));

drop_flag = dates.*0;

f = find( dates(first) ~= dates(last) & used(first) == 0 );
while ~isempty(f)
    f_orig = f;
    used( first(f_orig) ) = 1;
    if ofs > 1        
        both_flag = find( flagged( first(f_orig) ) == flagged( last(f_orig) - 1 ) );        
        
        if ~isempty(both_flag)
            f = f_orig(both_flag);
            
            data( last(f) - 1 ) = data( last(f) - 1 ) + data( first(f) );         

            f1 = ( isnan(tob( last(f) - 1 )) );
            tob( last(f(f1)) - 1 ) = tob( first(f(f1)) );

            f1 = ( ~isnan( tob( last(f) - 1 ) ) & ~isnan( tob( first(f) ) ) & ...
                tob( first(f) ) ~= tob( last(f) - 1 ) );
            tob( last(f(f1)) - 1 ) = -1;        

            f1 = ( isnan(num( last(f) - 1 )) );
            num( last(f(f1)) - 1 ) = num( first(f(f1)) );

            f1 = ( ~isnan( num( last(f) - 1 ) ) & ~isnan( num( first(f) ) ) & ...
                num( first(f) ) ~= num( last(f) - 1 ) );
            num( last(f(f1)) - 1 ) = -1;        

            new_flags( last(f) - 1, (ofs-1)*lf + (1:lf)) = flags(first(f), :);        
            new_source( last(f) - 1, (ofs-1)*ls + (1:ls)) = source(first(f), :);        

            counts( last(f) - 1 ) = counts( last(f) - 1 ) + 1;        
        end
        
        new_unflag = find( flagged( last(f_orig) - 1 ) & ~flagged( first(f_orig) ) );        
        
        if ~isempty(new_unflag)
            f = f_orig(new_unflag);

            data( last(f) - 1 ) = data( first(f) );         
            tob( last(f) - 1 ) = tob( first(f) );
            num( last(f) - 1 ) = num( first(f) );

            new_flags( last(f) - 1, (ofs-1)*lf + (1:lf)) = flags(first(f), :);        
            new_source( last(f) - 1, (ofs-1)*ls + (1:ls)) = source(first(f), :);        

            new_flags( last(f) - 1, 1:(ofs-1)*lf ) = 0;
            new_source( last(f) - 1, 1:(ofs-1)*ls ) = 0;
            
            counts( last(f) - 1 ) = 1;
            
            drop_flag( last(f) - 1 ) = 1;
            flagged( last(f) - 1 ) = 0;
        end
        
        new_isflag = ( ~flagged( last(f_orig) - 1 ) & flagged( first(f_orig) ) );        
        drop_flag( last( f_orig(new_isflag) ) - 1 ) = 1;
        
    else
        counts( last(f) - 1 ) = 1;        
    end

    ofs = ofs + 1;
    first = [1:ld-ofs];
    last = [ofs+1:ld];

    f = find( dates(first) ~= dates(last) & used(first) == 0 );
end

f = find( counts >= 1 );
data = data(f) ./ counts(f);
dates = dates(f);
num = num(f);
tob = tob(f);
flags = new_flags(f,:);
source = new_source(f,:);
counts = counts(f);
drop_flag = drop_flag(f);

f = find( drop_flag );
if ~isempty(f)
    flags(f, end+1) = dataFlags( 'MONTHLY_BAD_FLAGGED_VALUE_DROPPED' );
end

f = find( ~isnan(num) );
if ~isempty(f)
    num(f) = NaN;
    flags(f, end+1) = dataFlags( 'MONTHLY_NUM_DROPPED' );
end

f = find( tob == -1 );
if ~isempty(f)
    tob(f) = NaN;
    flags(f, end+1) = dataFlags( 'MONTHLY_TOB_CHANGE' );
end


%Check complete month.
v = zeros(length(dates), 3);
v(:,1) = floor( dates / 12 - 1/24 + 1600 );
v(:,2) = dates - (v(:,1) - 1600)*12;
v(:,3) = 1;

d1 = datenum(v);
v(:,2) = v(:,2) + 1;
f = find(v(:,2) > 12);
v(f,2) = 1;
v(f,1) = v(f,1) + 1;
d2 = datenum(v);

days = d2 - d1;

f = find( counts(:) < days(:) );
if ~isempty(f)
    flags(f, end+1) = dataFlags( 'MONTHLY_INCOMPLETE' );
end

f = find( counts(:) < days(:)-9 );
if ~isempty(f)
    flags(f, end+1) = dataFlags( 'MONTHLY_HIGHLY_INCOMPLETE' );
end

flags(:, end+1) = dataFlags( 'NEW_MONTHLY_AVERAGE' );


% Sort and Remove Duplicates
flags = sort( flags, 2 );

f = find( flags(:,1:end-1) == flags(:,2:end) & flags(:,1:end-1) );
flags(f) = 0;
if ~isempty(f)
    flags = sort( flags, 2 );
end

source = sort( source, 2 );

f = find( source(:,1:end-1) == source(:,2:end) & source(:,1:end-1) );
source(f) = 0;
if ~isempty(f)
    source = sort( source, 2 );
end

if ~isempty(flags)
    ss = sum(flags);
    f = (ss == 0);
    if any( f )
        flags(:,f) = [];
    end
end

ss = sum(source);
f = (ss == 0);
if any(f)
    source(:,f) = [];
end


resort_f = 0;

if isempty( monthly_duplicate_flags )
    %Add Flags for Duplicate Processing 
    duplicate_flags = { 'DUPLICATE_1', 'DUPLICATE_2', 'DUPLICATE_3', ...
        'DUPLICATE_4', 'DUPLICATE_5' };
    mvf = [];
    for k = 1:length(duplicate_flags) 
        mvf(k) = dataFlags( duplicate_flags{k} );
    end
    monthly_duplicate_flags = mvf;
else
    mvf = monthly_duplicate_flags;
end
    
res = ismember( flags, mvf );
res = any(res,2);
f = find(res);

if ~isempty(f)
    flags(f, end+1) = dataFlags( 'MONTHLY_INCLUDED_DUPLICATES' );
    resort_f = 1;
end

if isempty( monthly_merge_flags )
    duplicate_flags = { 'MERGE_1', 'MERGE_2', 'MERGE_3' };
    mvf = [];
    for k = 1:length(duplicate_flags) 
        mvf(k) = dataFlags( duplicate_flags{k} );
    end
    monthly_merge_flags = mvf;
else
    mvf = monthly_merge_flags;
end
    
res = ismember( flags, mvf );
res = any(res,2);
f = find(res);

if ~isempty(f)
    flags(f, end+1) = dataFlags( 'MONTHLY_INCLUDED_MERGES' );
    resort_f = 1;
end


if resort_f
    flags = sort(flags, 2);
    ss = sum(flags);
    f = find(ss == 0);
    if ~isempty(f)
        flags(:,f) = [];
    end
end


%Output Record;
sx.record_type = se.record_type;
sx.frequency = stationFrequencyType( 'm' );
sx.dates = dates(:)';
sx.time_of_observation = tob;

dd = abs(diff(data));
f = find( dd > 1e-7 );
if min(dd(f)) < 0.001
    data = round( data * 1000 ) / 1000;
end

sx.data = data;
sx.num_measurements = counts;
sx.flags = flags;
sx.source = source;
sx.auto_compress = se.auto_compress;

sx = class( sx, 'stationElement' );
if sx.auto_compress
    sx = compress( sx );
end