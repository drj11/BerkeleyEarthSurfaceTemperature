function v = bytesOf( a )

switch class(a)
    case {'int8', 'uint8', 'logical'}
        v = 1;
    case {'int16', 'uint16'}
        v = 2;
    case {'int32', 'uint32', 'single'}
        v = 4;
    case {'int64', 'uint64', 'double'}
        v = 8;
    otherwise
        error( 'Unknown type' );
end