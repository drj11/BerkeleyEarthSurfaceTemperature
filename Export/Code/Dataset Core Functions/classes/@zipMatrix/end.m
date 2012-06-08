function v = end( cv, k, n )

if n == 1
    v = cv.size(1)*cv.size(2);
else
    v = size( cv, k );
end
