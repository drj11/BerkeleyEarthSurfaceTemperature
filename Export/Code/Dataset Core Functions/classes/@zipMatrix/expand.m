function v = expand( cv )
% Decompress a zipMatrix data structure
%
% Based on DUNZIP

if cv.type == 0 || isempty( cv.data ) || prod( double( cv.size ) ) == 0
    v = [];
    return;
end

ct = getDataTypeCodes();

if length( cv.data ) == 1
    if strcmp( ct(cv.type), 'logical' )
        v = false( prod( double( cv.size ) ), 1 ) | cv.data;
    else
        v = ones( prod( double( cv.size ) ), 1, ct{cv.type} ).*cv.data;
    end
    if cv.increment ~= 0
        v = v + cast( cv.increment.*(1:length(v))', ct{cv.type} );
    end
    
    v = reshape( v, cv.size );
    return
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier

input_stream = java.io.ByteArrayInputStream( cv.data );
inflater_stream = java.util.zip.InflaterInputStream( input_stream );
output_stream = java.io.ByteArrayOutputStream;

isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
isc.copyStream( inflater_stream, output_stream );

Q = typecast( output_stream.toByteArray, 'uint8' );

if cv.type == 3
    v = logical(Q);
elseif cv.type == 4
    v = char(Q);
else
    v = typecast( Q, ct{cv.type} );
end

if cv.increment ~= 0   
    v = v + cast( cv.increment.*(1:length(v))', ct{cv.type} );    
end

v = reshape(v,cv.size);

input_stream.close();
inflater_stream.close();
output_stream.close();
