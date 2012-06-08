function sx = merge( se1, se2 )

% Note: Merged Data rounded to nearest 0.001 C (for memory size)

if se1.record_type ~= se2.record_type
    se1 = makeEquivalent( se1 );
    se2 = makeEquivalent( se2 );
    if se1.record_type ~= se2.record_type    
        se1
        se2
        error('Record Types does not match.');
    end
end
if se1.frequency ~= se2.frequency
    error('Frequency does not match.');
end

dates1 = expand( se1.dates );
dates2 = expand( se2.dates );

tob1 = double( se1.time_of_observation );
f = ( tob1 == 255 );
tob1(f) = NaN;

tob2 = double( se2.time_of_observation );
f = ( tob2 == 255 );
tob2(f) = NaN;

data1 = expand( se1.data );
data2 = expand( se2.data );

num1 = double( se1.num_measurements );
f = ( num1 == 65535 );
num1(f) = NaN;

num2 = double( se2.num_measurements );
f = ( num2 == 65535 );
num2(f) = NaN;

flags1 = expand( se1.flags );
flags2 = expand( se2.flags );
source1 = expand( se1.source );
source2 = expand( se2.source );

f = isnan(flags1);
flags1(f) = 0;
f = isnan(flags2);
flags2(f) = 0;

if isempty( flags1 )
    flags1 = zeros( length(dates1), 1 );
end
if isempty( flags2 )
    flags2 = zeros( length(dates2), 1 );
end

auto_compress = min( [se1.auto_compress, se2.auto_compress] );

dates = [dates1, dates2];
data = [data1, data2];
tob = [tob1, tob2];
num = [num1, num2];
flags = flags1;
flags(end+1:end+length(flags2(:,1)),1:length(flags2(1,:))) = flags2;
source = source1;
source(end+1:end+length(source2(:,1)),1:length(source2(1,:))) = source2;

origin = [dates1.*0 + 1, dates2.*0 + 2];

[~,I] = sort(dates);
dates = dates(I);
data = data(I);
tob = tob(I);
num = num(I);
flags = flags(I,:);
source = source(I,:);
origin = origin(I);

m(1) = dataFlags( 'MERGE_1' );  % <= 0.01 C
m(2) = dataFlags( 'MERGE_2' );  % 0.01 - 0.1 C
m(3) = dataFlags( 'MERGE_3' );  % 0.1 - 0.25 C

te = dataFlags( 'MERGE_CONFLICT_TOB' );
ne = dataFlags( 'MERGE_CONFLICT_NUM' );

slen = length( source(1,:) );
flen = length( flags(1,:) );

cutoffs = [0.01, 0.1, 0.25];
for k = 1:length(cutoffs)
    dist = 1;

    remove = zeros(length(dates),1);
    df = find(diff(dates) == 0);
    pos_start = min(df);
    pos_end = max(df) + 1;

    first = (pos_start:pos_end-dist);
    last = first + dist;
    
    f = find(dates(first) == dates(last));
    while ~isempty(f)
        f2 = find(origin(first(f)) == 1 & origin(last(f)) == 2);
        
        if ~isempty(f2)
            f = f(f2);
        else
            f = [];
        end
        
        if ~isempty(f)
            df = abs(data(first(f)) - data(last(f)));
        
            f3 = find(df <= cutoffs(k));
            if ~isempty(f3)
                f = f(f3);
            else
                f = [];
            end
        end
        
        if ~isempty(f)
            data(first(f)) = (data(first(f)) + data(last(f)))/2;
            origin(first(f)) = 0;
            origin(last(f)) = 0;
            remove(last(f)) = 1;

            source(first(f),slen+(1:slen)) = source(last(f),1:slen);
            flags(first(f),flen+(1:flen)) = flags(last(f),1:flen);
            flags(first(f), 2*flen+1) = m(k);
                    
            f1 = find(isnan(tob(first(f))));
            tob(first(f(f1))) = tob(last(f(f1)));

            f1 = find(isnan(num(first(f))));
            num(first(f(f1))) = num(last(f(f1)));

            %TOB conflict Error
            f1 = (~isnan(tob(first(f))) & ~isnan(tob(last(f))) & ...
                tob(first(f)) ~= tob(last(f)));
            flags(first(f(f1)), 2*flen+2) = te;

            %NUM conflict Error
            f1 = (~isnan(num(first(f))) & ~isnan(num(last(f))) & ...
                num(first(f)) ~= num(last(f)));
            flags(first(f(f1)), 2*flen+3) = ne;            
        end
    
        dist = dist + 1;
        
        first = (pos_start:pos_end-dist);
        last = first + dist;

        f = find(dates(first) == dates(last));
        
    end
    
    f = find(remove);
    dates(f) = [];
    data(f) = [];
    tob(f) = [];
    num(f) = [];
    flags(f,:) = [];
    source(f,:) = [];
    origin(f) = [];
end

flags = sort(flags,2);
source = sort(source,2);

f = find( origin == 0 );

flen = length(flags(1,:));
slen = length(source(1,:));

resort_f = 0;
for j = flen:-1:2
    f2 = find(flags(f,j) == flags(f,j-1));
    flags(f(f2),j) = 0;
    if ~isempty(f2)
        resort_f = 1;
    end       
end

resort_s = 0;
for j = slen:-1:2
    f2 = find(source(f,j) == source(f,j-1));
    source(f(f2),j) = 0;
    if ~isempty(f2)
        resort_s = 1;
    end
end

if resort_f
    flags(f,:) = sort(flags(f,:),2);
end
if resort_s
    source(f,:) = sort(source(f,:),2);
end

ss = sum(flags);
f = find(ss == 0);
if ~isempty(f)
    flags(:,f) = [];
end

ss = sum(source);
f = find(ss == 0);
if ~isempty(f)
    source(:,f) = [];
end
            
sx.record_type = se1.record_type;
sx.frequency = se1.frequency;
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
sx.auto_compress = auto_compress;
      
sx = class( sx, 'stationElement' );

if sx.auto_compress
    sx = compress( sx );
end