function [new_x, new_y] = averageRedundancy( x, y )

if length(x) < 2
    new_x = x;
    new_y = y;
    return;
end

used = x.*0;

f1 = find( x(1:end-1) ~= x(2:end) );
origin = [1; f1(:)+1];
used(origin) = 1;

new_y = y(origin);
new_x = x(origin);
counts = new_y.*0 + 1;

dist = 1;

last = origin + dist;

fx = find( last > length(x) );
if length(fx) > 0 
    origin(fx) = [];
    last(fx) = [];
end 

f = find( x(origin) == x(last) & used(last) == 0 );

while length(f) > 0
    new_y(f) = new_y(f) + y(last(f));
    counts(f) = counts(f) + 1;
    used(last(f)) = 1;
    
    dist = dist + 1;
    
    last = origin + dist;

    fx = find( last > length(x) );
    if length(fx) > 0 
        origin(fx) = [];
        last(fx) = [];
    end 
    
    f = find( x(origin) == x(last) & used(last) == 0 );
end 

new_y = new_y ./ counts;
