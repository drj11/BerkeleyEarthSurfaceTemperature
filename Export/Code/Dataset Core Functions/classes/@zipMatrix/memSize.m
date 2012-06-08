function v = memSize( a )

v = 713 + bytesOf( a.data )*length( a.data ) + ...
    bytesOf( a.size )*length( a.size );