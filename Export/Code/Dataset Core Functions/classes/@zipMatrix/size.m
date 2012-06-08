function v = size( cv, k )

if nargin == 1
    v = cv.size;
else
    v = cv.size(k);
end