function dd = remove( dd, item )

if nargout == 0
    error('Need to set an output to recieve the update.' );
end

pos = quickSearch( item, dd.keys, 'nearest' );
if pos == floor(pos) && pos > 0
    dd.values(pos) = [];
    dd.keys(pos) = [];
else
    error( 'Keys was not present' );
end
