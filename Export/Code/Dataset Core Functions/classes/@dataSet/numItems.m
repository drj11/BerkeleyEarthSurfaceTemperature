function result = numItems( ds )
% Reports number of items in the data set

result = zeros(length(ds), 1);
for k = 1:length(ds)
    result(k) = length(ds(k).data);
end