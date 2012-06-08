function [result, location] = ismember( md1, md2 )
% Provides the ismember function for md5hashes

v1 = [md1(:).val];
v2 = [md2(:).val];

if nargout > 1
    [result1, location1] = ismember( v1(1,:), v2(1,:) );
    [result2, location2] = ismember( v1(2,:), v2(2,:) );
else
    result1 = ismember( v1(1,:), v2(1,:) );
    result2 = ismember( v1(2,:), v2(2,:) );
end    
result = logical(result1) & logical(result2);

if nargout > 1
    location = result.*location1; 
    if any( v1(2,result) ~= v2(2,location(result)) )
        error( 'Upper 64 bits don''t match' );
    end
end

sz = size( md1 );
result = reshape( result, sz );