function v = numItems( se )

v = zeros( length(se), 1 );
for k = 1:length(se)       
    v(k) = length( se(k).data );
end