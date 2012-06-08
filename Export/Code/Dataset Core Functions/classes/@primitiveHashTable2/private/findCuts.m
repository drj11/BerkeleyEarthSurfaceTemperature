function res = findCuts( key_list )

if length(key_list(:,1)) == 1
    res = [1,1];
    return
end

bk =  find(~all(~diff(key_list),2));

res = ones(length(bk)+1,2);
res(2:end, 1) = bk+1;
res(1:end-1,2) = bk;
res(end,2) = length(key_list(:,1));


