function v = length( cv )

v = cv.size(1);
if v == 1
    v = cv.size(2);
end