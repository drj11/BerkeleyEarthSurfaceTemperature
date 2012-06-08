function v = stringOrder( s1, s2 )

mx = min(length(s1), length(s2));

s = sign(s1(1:mx) - s2(1:mx));
f = find(s);

if isempty(f)
    if length(s1) == length(s2)
        v = 0;
    elseif length(s2) > length(s1)
        v = -1;
    else
        v = 1;
    end
elseif s(f(1)) > 0
    v = 1;
else
    v = -1;
end
