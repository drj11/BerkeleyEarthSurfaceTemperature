function display( md )

if length(md) > 1
    display( [num2str(length(md)) ' MD5 Hashes'] );
else
    S = substruct( '.', 'key' );
    display( sprintf( '\n%s\n', subsref( md(:), S ) ) );
end