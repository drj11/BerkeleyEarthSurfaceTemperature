function sx = makeAnnual( se, bad_flags )

if nargin < 2
    bad_flags = [];
end

if se.frequency == stationFrequencyType( 'a' );
    sx = se;
    return;
elseif se.frequency == stationFrequencyType( 'd' )
    se = makeMonthly( se, bad_flags );
elseif se.frequency ~= stationFrequencyType( 'm' )
    error( 'Not possible to make monthly.' );
end 

if length(se) > 1
    error( 'Can not be called with an array' );
end

if isMultiValued( se )
    se = makeSingleValued( se );
end

if numItems( se ) == 0
    sx = stationElement2( se.record_type, 'a' );
    return;
end

dates = double( se.dates );
data = double( se.data );
tob = double( se.time_of_observation );
num = double( se.num_measurements );
flags = double( se.flags );
source = double( se.source );

f = find(isnan(dates));
if length(f) > 0
    dates(f) = [];
    data(f) = [];
    tob(f) = [];
    num(f) = [];
    flags(f, :) = [];
    source(f, :) = [];
end

if length(dates) == 0
    sx = stationElement2( se.record_type, 'a' );
    return;
end

f = find(isnan(flags));
flags(f) = 0;

s = size(flags);
if s(1) == 0
    flags(1:length(data),1) = 0;
end

dates = floor(dates/12 - 1/24 + 1600);
dates(end+1) = dates(end) + 1;

ofs = 1;

ld = length(dates);

first = [1:ld-ofs];
last = [ofs+1:ld];

used = dates.*0;

counts = data.*0; 

new_flags = double( flags );
new_flags(:,end+1:31*end ) = 0;

lf = length(flags(1,:));

new_source = double( source );
new_source(:,end+1:31*end ) = 0;

ls = length(source(1,:));

f = find( dates(first) ~= dates(last) & used(first) == 0 );
while length(f) > 0
    used( first(f) ) = 1;
    if ofs > 1        
        data( last(f) - 1 ) = data( last(f) - 1 ) + data( first(f) );         

        f1 = find( isnan(tob( last(f) - 1 )) );
        tob( last(f(f1)) - 1 ) = tob( first(f(f1)) );
        
        f1 = find( ~isnan( tob( last(f) - 1 ) ) & ~isnan( tob( first(f) ) ) & ...
            tob( first(f) ) ~= tob( last(f) - 1 ) );
        tob( last(f(f1)) - 1 ) = -1;        

        f1 = find( isnan(num( last(f) - 1 )) );
        num( last(f(f1)) - 1 ) = num( first(f(f1)) );
        
        f1 = find( ~isnan( num( last(f) - 1 ) ) & ~isnan( num( first(f) ) ) & ...
            num( first(f) ) ~= num( last(f) - 1 ) );
        num( last(f(f1)) - 1 ) = -1;        
        
        new_flags( last(f) - 1, (ofs-1)*lf + (1:lf)) = flags(first(f), :);
        new_source( last(f) - 1, (ofs-1)*ls + (1:ls)) = source(first(f), :);        
        
        counts( last(f) - 1 ) = counts( last(f) - 1 ) + 1;
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


f = find( ~isnan(num) );
if length(f) > 0
    num(f) = NaN;
    flags(f, end+1) = dataFlags( 'ANNUAL_NUM_DROPPED' );
end

f = find( tob == -1 );
if length(f) > 0
    tob(f) = NaN;
    flags(f, end+1) = dataFlags( 'ANNUAL_TOB_CHANGE' );
end


f = find( counts(:) < 12 );
if length(f) > 0
    flags(f, end+1) = dataFlags( 'ANNUAL_INCOMPLETE' );
end



% Sort and Remove Duplicates
flags = sort(flags,2);
source = sort(source,2);

s = size(flags);
flen = s(2);
s = size(source);
slen = s(2);

resort_f = 0;
for j = flen:-1:2
    f2 = find(flags(:,j) == flags(:,j-1));
    flags(f2,j) = 0;
    if length(f2) > 0
        resort_f = 1;
    end       
end

resort_s = 0;
for j = slen:-1:2
    f2 = find(source(:,j) == source(:,j-1));
    source(f2,j) = 0;
    if length(f2) > 0
        resort_s = 1;
    end
end

ss = sum(flags);
f = find(ss == 0);
if length(f) > 0
    flags(:,f) = [];
end

ss = sum(source);
f = find(ss == 0);
if length(f) > 0
    source(:,f) = [];
end


%Add Flags for Duplicate Processing 
duplicate_flags = { 'DUPLICATE_1', 'DUPLICATE_2', 'DUPLICATE_3', ...
    'DUPLICATE_4', 'DUPLICATE_5', 'ANNUAL_INCLUDED_DUPLICATES' };
mvf = [];
for k = 1:length(duplicate_flags) 
    mvf(k) = dataFlags( duplicate_flags{k} );
end

f = [];
for k = 1:length(flags(1,:))
    f = union( f, find( ismember( flags(:,k), mvf ) ) );
end

if length(f) > 0
    flags(f, end+1) = dataFlags( 'ANNUAL_INCLUDED_DUPLICATES' );
    resort_f = 1;
end

duplicate_flags = { 'MERGE_1', 'MERGE_2', 'MERGE_3' };
mvf = [];
for k = 1:length(duplicate_flags) 
    mvf(k) = dataFlags( duplicate_flags{k} );
end

f = [];
for k = 1:length(flags(1,:))
    f = union( f, find( ismember( flags(:,k), mvf ) ) );
end

if length(f) > 0
    flags(f, end+1) = dataFlags( 'ANNUAL_INCLUDED_MERGES' );
    resort_f = 1;
end


if resort_f
    flags = sort(flags, 2);
    ss = sum(flags);
    f = find(ss == 0);
    if length(f) > 0
        flags(:,f) = [];
    end
end
if resort_s
    source = sort(source, 2);
    ss = sum(source);
    f = find(ss == 0);
    if length(f) > 0
        source(:,f) = [];
    end
end


%Output Record;
sx.record_type = se.record_type;
sx.frequency = stationFrequencyType( 'a' );
sx.dates = dates;
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

sx = class( sx, 'stationElement2' );
if sx.auto_compress
    sx = compress( sx );
end