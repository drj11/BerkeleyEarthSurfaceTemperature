function cv = compress( cv )
% Based on DZIP

if isempty( cv.data )
    return;
end

cv.data = cv.data(:);

test = true;
if isinteger( cv.data )
    rc = double(intmax( class( cv.data ) )) - ...
        double(intmin( class( cv.data ) ));
    rc = rc / length(cv.data);
    if rc < 1
        test = false;
    end
end

if length( cv.data ) > 1 && ~islogical( cv.data ) && test
    if isinteger( cv.data )
        df = diff( single( cv.data ) );
    else
        df = diff( cv.data );
    end
    l_zero = sum( ~df );
    l_one = sum( df == 1 );
    
    if l_zero > (length( df ) - l_one) / 2 && l_zero >= l_one
        dd = 0;
        cnt = l_zero;
    elseif l_one > (length( df ) - l_zero) / 2 && l_one >= l_zero
        dd = 1;
        cnt = l_one;
    else
        [dd, cnt] = mode( df );
    end    
else
    dd = 0;
    cnt = 1;
end

if cnt > 1 && dd ~= 0 
    cv.increment = dd;
    cl = class( cv.data );
    
    warning( 'off', 'MATLAB:intConvertOverflow' );
    inc = cast( dd.*(1:length(cv.data))', cl );
    if all( inc == 0 )
        %Negative numbers can be crushed to zero
        cv.increment = 0;
    else
        %Test for overflow / underflow
        A = cv.data - inc;
        B = A + inc;

        if any( B ~= cv.data ) 
            cv.increment = 0;
        else
            cv.data = A;
        end
    end    
    warning( 'on', 'MATLAB:intConvertOverflow' );
    
else
    cv.increment = 0;
end

if max( cv.data ) == min( cv.data )
    cv.data = cv.data(1);
    return;
end

if cv.type == 3 || cv.type == 4
    cv.data = uint8( cv.data );
else
    cv.data = typecast( cv.data, 'uint8');
end

output_stream = java.io.ByteArrayOutputStream();
deflated = java.util.zip.DeflaterOutputStream( output_stream );

% Break into pieces to avoid Java Heap memory problems.
for k = 1:5e6:length( cv.data )
    limit = min( k + 5e6 - 1, length(cv.data) );
    deflated.write( cv.data(k:limit) );
end

deflated.close();
cv.data = typecast( output_stream.toByteArray, 'uint8' );
output_stream.close();

