function sx = removeExactDuplicates( se )

%Based on makeSingleValued

dates = double( se.dates );
if length( unique( dates ) ) == length( dates )
    sx = se;
    return;
end

ofs = 1;

dates = expand( se.dates );
data = expand( se.data );

tob = double( se.time_of_observation );
f = ( tob == 255 );
tob(f) = NaN;

num = expand( se.num_measurements );
f = ( num == 65535 );
num(f) = NaN;

flags = expand( se.flags );
source = expand( se.source );

f = find(isnan(dates));
if length(f) > 0
    dates(f) = [];
    data(f) = [];
    tob(f) = [];
    num(f) = [];
    flags(f, :) = [];
    source(f, :) = [];
end

s = size(flags);
if s(1) == 0
    flags(1:length(data),1) = 0;
end

ofs = 1;

ld = length(dates);

new_flags = double( flags );
new_flags(:,end+1:5*end ) = 0;

lf = length(flags(1,:));

new_source = double( source );
new_source(:,end+1:5*end ) = 0;

ls = length(source(1,:));

%Create effective dates function that only matches if data is duplicated
dates = dates + (data - min(data) + 1) / 1e6;

[dates,I] = sort(dates);
dates(end+1) = dates(end) + 1;

df = find( diff(dates) == 0 );
pos_start = min(df);
pos_end = max(df) + 1;

data = data(I);
tob = tob(I);
num = num(I);
flags = flags(I,:);
source = source(I,:);

used = data.*0 + 1;

first = [pos_start:pos_end-ofs];
last = [pos_start+ofs:pos_end];

counts = data.*0 + 1;
counts(pos_start:pos_end) = 0;
used(pos_start:pos_end) = 0;

f = find( dates(first) ~= dates(last) & used(first) == 0 );
while length(f) > 0
    used( first(f) ) = 1;
    
    fx = find( dates(first(f)) ~= dates(last(f) - 1) );
    f(fx) = [];
    
    if ofs > 1
        %Remove Conflicts for TOB and NUM
        f1 = find( ~isnan( tob( last(f) - 1 ) ) & ~isnan( tob( first(f) ) ) & ...
            tob( first(f) ) ~= tob( last(f) - 1 ) );
        used( first(f(f1)) ) = 0;
        f(f1) = [];
        
        f1 = find( ~isnan( num( last(f) - 1 ) ) & ~isnan( num( first(f) ) ) & ...
            num( first(f) ) ~= num( last(f) - 1 ) );
        used( first(f(f1)) ) = 0;
        f(f1) = [];
        
        f1 = find( isnan(tob( last(f) - 1 )) );
        tob( last(f(f1)) - 1 ) = tob( first(f(f1)) );
        f1 = find( isnan(num( last(f) - 1 )) );
        num( last(f(f1)) - 1 ) = num( first(f(f1)) );
        
        if length(f) > 0
            new_flags( last(f) - 1, (ofs-1)*lf + (1:lf)) = flags(first(f), :);
            new_source( last(f) - 1, (ofs-1)*ls + (1:ls)) = source(first(f), :);        
        
            counts( last(f) - 1 ) = counts( last(f) - 1 ) + 1;
        end
    else
        counts( last(f) - 1 ) = 1;        
    end

    ofs = ofs + 1;
    first = [pos_start:pos_end-ofs];
    last = [pos_start+ofs:pos_end];

    f = find( dates(first) ~= dates(last) & used(first) == 0 );
end
    
f = find( used == 0 );
counts( f ) = 1;

f = find( counts >= 1 );
data = data(f);
dates = floor(dates(f));
num = num(f);
tob = tob(f);
flags = new_flags(f,:);
source = new_source(f,:);
counts = counts(f);


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

if resort_f
    flags = sort(flags, 2);
end
if resort_s
    source = sort(source, 2);
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



sx.record_type = se.record_type;
sx.frequency = se.frequency;
sx.dates = dates;
sx.time_of_observation = tob;
sx.data = data;
sx.num_measurements = num;
sx.flags = flags;
sx.source = source;
sx.auto_compress = se.auto_compress;

sx = class( sx, 'stationElement' );
sx = compress( sx );