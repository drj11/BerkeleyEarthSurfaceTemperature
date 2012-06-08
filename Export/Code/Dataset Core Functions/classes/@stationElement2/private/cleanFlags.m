function res = cleanFlags( flag_array )
% res = cleanFlags( flag_array )

flags = sort(flag_array,2);

s = size(flags);
flen = s(2);

resort_f = 0;
for j = flen:-1:2
    f2 = find(flags(:,j) == flags(:,j-1));
    flags(f2,j) = 0;
    if ~isempty(f2)
        resort_f = 1;
    end       
end

if resort_f
    flags = sort(flags, 2);
end

ss = sum(flags, 1);
f = find(ss == 0);
if ~isempty(f)
    flags(:,f) = [];
end

res = flags;