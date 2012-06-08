function sx = makeSingleValued( se, bf )

dates = expand( se.dates );
if length( uniquePreSorted( dates ) ) == length( dates )
    sx = se;
    return;
end

if nargin < 2
    bf = [];
end

flag_pos = findFlags( se, bf );
flagged = dates.*0;
flagged( flag_pos ) = 1;

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

s = size(flags);
if s(1) == 0
    flags(1:length(data),1) = 0;
end


ofs = 1;

df = find( diff(dates) == 0 );
pos_start = min(df);
pos_end = max(df) + 1;

first = [pos_start:pos_end-ofs];
last = [ofs+pos_start:pos_end];

used = dates.*0;

counts = data.*0 + 1;
counts(pos_start:pos_end) = 0;

max_data = data;
min_data = data;

new_flags = flags;
new_flags(:,end+1:5*end ) = 0;

lf = length(flags(1,:));

new_source = source;
new_source(:,end+1:5*end ) = 0;

ls = length(source(1,:));

dates(end+1) = dates(end) + 1;
drop_flag = dates.*0;

f = find( dates(first) ~= dates(last) & used(first) == 0 );
while length(f) > 0
    f_orig = f;
    
    used( first(f_orig) ) = 1;
    if ofs > 1
        
        both_flag = find( flagged( first(f_orig) ) == flagged( last(f_orig) - 1 ) );            
        if ~isempty(both_flag)
            f = f_orig(both_flag);
            
            f1 = ( data(first(f)) > max_data( last(f) - 1 ) );
            max_data( last(f(f1)) - 1 ) = data(first(f(f1)));
            f1 = ( data(first(f)) < min_data( last(f) - 1 ) );
            min_data( last(f(f1)) - 1 ) = data(first(f(f1)));

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
            
            max_data( last(f) - 1 ) = data(first(f));
            min_data( last(f) - 1 ) = data(first(f));

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
    first = [pos_start:pos_end-ofs];
    last = [ofs+pos_start:pos_end];

    f = find( dates(first) ~= dates(last) & used(first) == 0 );
end
    
if used(end) == 0
    counts(end) = 1;
end

f = ( counts >= 1 );
data = data(f) ./ counts(f);
dates = dates(f);
num = num(f);
tob = tob(f);
flags = new_flags(f,:);
source = new_source(f,:);
max_data = max_data(f);
min_data = min_data(f);
counts = counts(f);
drop_flag = drop_flag(f);

f = find( drop_flag );
if length(f) > 0
    flags(f, end+1) = dataFlags( 'DUPLICATE_BAD_FLAGGED_VALUE_DROPPED' );
end

f = find( num == -1 );
if length(f) > 0
    num(f) = NaN;
    flags(f, end+1) = dataFlags( 'DUPLICATE_CONFLICT_NUM' );
end

f = find( tob == -1 );
if length(f) > 0
    tob(f) = NaN;
    flags(f, end+1) = dataFlags( 'DUPLICATE_CONFLICT_TOB' );
end


% Annotate Merge Difference
fpos = length(flags(1,:)) + 1;
f = find( counts > 1 );

f1 = find( max_data(f) - min_data(f) < 0.01 );
if length(f1) > 0
    flags(f(f1), fpos) = dataFlags( 'DUPLICATE_1' );
end
f2 = find( max_data(f) - min_data(f) >= 0.01 & max_data(f) - min_data(f) < 0.1 );
if length(f2) > 0
    flags(f(f2), fpos) = dataFlags( 'DUPLICATE_2' );
end
f3 = find( max_data(f) - min_data(f) >= 0.1 & max_data(f) - min_data(f) < 0.25 );
if length(f3) > 0
    flags(f(f3), fpos) = dataFlags( 'DUPLICATE_3' );
end
f4 = find( max_data(f) - min_data(f) >= 0.25 & max_data(f) - min_data(f) < 1 );
if length(f4) > 0 
    flags(f(f4), fpos) = dataFlags( 'DUPLICATE_4' );
end
f5 = find( max_data(f) - min_data(f) >= 1 );
if length(f5) > 0
    flags(f(f5), fpos) = dataFlags( 'DUPLICATE_5' );
end


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

ss = sum(flags);
f = (ss == 0);
if any( f )
    flags(:,f) = [];
end

ss = sum(source);
f = (ss == 0);
if any(f)
    source(:,f) = [];
end




sx.record_type = se.record_type;
sx.frequency = se.frequency;
sx.dates = dates;
sx.time_of_observation = tob;

dd = abs(diff(data));
f = ( dd > 1e-7 );
if min(dd(f)) < 0.001
    data = round( data * 1000 ) / 1000;
end
sx.data = data;

sx.num_measurements = num;
sx.flags = flags;
sx.source = source;
sx.auto_compress = se.auto_compress;

sx = class( sx, 'stationElement' );

if sx.auto_compress
    sx = compress( sx );
end


function un = uniquePreSorted( A );
%Requires that A be sorted and not contain NaN or Inf

db = diff(A);
d = db ~= 0;
d( 1, numel(A) ) = 1;  

un = A(d);     
