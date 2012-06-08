function list = insertSort( element, list )

pos = quickSearch( element, list, 'nearest' );

s = size(list);

if pos ~= floor(pos)
    pos = floor(pos);
end

if s(1) > 1
    list = [list(1:pos); element; list(pos+1:end)];
else
    list = [list(1:pos), element, list(pos+1:end)];
end