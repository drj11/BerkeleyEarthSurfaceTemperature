function [res, selections] = determineBestPrecision( A )
% res = determineBestPrecision( values )
%
% Attempts to find the element of values reported to the highest base-10
% precision.  In the event that elements of A are not consistent with being
% different roundings of the same number, returns an average of the
% disagreeing values.

if length(A) <= 1
    res = A;
    if nargout > 1
        selections = 1;
    end
    return;
end

f = find( A ~= 0 );
if isempty(f)
    res = 0;
    if nargout > 1
        selections = 1;
    end
    return;
end

start = -ceil( max( log(abs(A(f))) / log(10) ) );

selections = 1:length(A);

for k = start:10+start
    shift = 10.^k;
    
    B = round(A * shift) / shift;

    if max(B) == min(B)
        f = find( B - A == 0 );
        if length(f) == length(A);
            res = A(1);
            selections = selections(1);
            return;            
        elseif ~isempty(f)
            A(f) = [];
            selections(f) = [];
            
            if length(A) == 1
                res = A;
                return;
            end
        end
    else
        res = mean( A );
        return;
    end
end
    
res = mean(A);
