function dd = subsasgn( dd, S, item );

if length(S) > 1
    error( 'Multi-part access not supported.' );
else
    value = S(1).subs;
end

if iscell( value )
    if length( value ) > 1
        error( 'Index must be single item' );
    else
        value = value{1};
    end
end
if isnumeric( value )
    if length( value ) > 1
        error( 'Index must be single item' );
    else
        value = num2str( value );
    end
end 

if strcmp(S(1).type, '()')
    pos = quickSearch( value, dd.keys, 'nearest' );
    if pos == floor(pos) && pos > 0
        dd.values{pos} = item;
    else
        pos = floor(pos);
        
        dd.keys(pos+2:end+1) = dd.keys(pos+1:end);
        dd.keys{pos+1} = value;
        dd.values(pos+2:end+1) = dd.values(pos+1:end);
        dd.values{pos+1} = item;
    end
else
    error( 'Unsupported access type' );
end
