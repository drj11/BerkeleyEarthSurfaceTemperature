function breaks = changePointDetection( data, threshold, segment_max_length )

if length(data) < 6
    breaks = [];
    return;
end

breaks = [];

if nargin < 3    
    segment_max_length = 12*10;
end
if nargin < 2 
    threshold = 0.999;
end

threshold_mult = erfinv( threshold ) * sqrt(2);

done = false;
while ~done
    
    s = sort(data);
    lower_limit = s(ceil(length(s)*0.1));
    upper_limit = s(floor(length(s)*0.9));
    
    mask = ( data < upper_limit ) & ( data > lower_limit );
    
    data2 = data(mask);
    indices = 1:length(data);
    indices2 = indices(mask);
    
    cs = cumsum(data2);
    
    len = length(data2);
    
    T = zeros( len, 3 );
    for k = 4:len - 4
        m1 = cs(k) / k;
        m2 = (cs(end) - cs(k)) / ( len - k );
        
        s1 = mean( ( data2(1:k) - m1 ) .^ 2 ) / (k - 1);
        s2 = mean( ( data2(k+1:end) - m2 ) .^2 ) / ( len - k - 1 );
        
        T(k,1) = abs(m1 - m2)/sqrt( s1 + s2 );
        T(k,2:3) = [m1,m2];
    end
    
    [~,fk] = max( T(:, 1) );
    
    if T(fk,1) > threshold_mult
        k = indices2(fk);
        breaks(end+1) = k;
        data(k+1:end) = data(k+1:end) + T(fk,2) - T(fk,3);
        done = false;
    else
        done = true;
    end
    
end

breaks = sort(breaks);

if ~isempty(breaks) 
    breaks = [1, breaks, length(data)];

    breaks2 = cell(length(breaks)-1, 1);
    for k = 1:length(breaks)-1
        breaks2{k} = changePointDetection( data( breaks(k):breaks(k+1)-1 ), threshold, ...
            segment_max_length ) + breaks(k) - 1;
    end

    breaks = unique( [breaks breaks2{:}] );
else
    breaks = [1, length(data)];
end    
        
breaks2 = cell(length(breaks)-1, 1);
breaks3 = cell(length(breaks)-1, 1);

for k = 1:length(breaks)-1
    if breaks(k+1) - breaks(k) > segment_max_length
        len_seg = breaks(k+1) - breaks(k) - 1;
        midpt = floor( breaks(k) + len_seg / 2 );
        select1 = breaks(k):midpt;
        breaks2{k} = changePointDetection( data( select1 ), threshold, ...
            segment_max_length ) + breaks(k) - 1;
        select2 = midpt+1:breaks(k+1)-1;
        breaks3{k} = changePointDetection( data( select2 ), threshold, ...
            segment_max_length ) + midpt;

    end
end

breaks = unique( [breaks breaks2{:} breaks3{:}] );

breaks = breaks( 2:end-1 );

