function result = isnull( md5 ) 
%Check for empty hash

if isempty(md5)
    result = 1;
end

result = zeros( length(md5), 1 );
for k = 1:length(md5)
    result(k) = all( md5(k).val == 0 );
end