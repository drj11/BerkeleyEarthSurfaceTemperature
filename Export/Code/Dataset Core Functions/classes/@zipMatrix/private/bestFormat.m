function a = bestFormat( a );

tol = 1e-7;

warning( 'off', 'MATLAB:intConvertOverflow' ); 
warning( 'off', 'MATLAB:intConvertNonIntVal' ); 
if min(a) < 0
    if all(abs(double(int8(a)) - a) < tol)
        a = int8(a);
    elseif all(abs(double(int16(a)) - a) < tol)
        a = int16(a);
    elseif all(abs(double(int32(a)) - a) < tol)
        a = int32(a);
    end
else
    if all(abs(double(uint8(a)) - a) < tol)
        a = uint8(a);
    elseif all(abs(double(uint16(a)) - a) < tol)
        a = uint16(a);
    elseif all(abs(double(uint32(a)) - a) < tol)
        a = uint32(a);
    end
end   
warning( 'on', 'MATLAB:intConvertOverflow' );
warning( 'on', 'MATLAB:intConvertNonIntVal' ); 
