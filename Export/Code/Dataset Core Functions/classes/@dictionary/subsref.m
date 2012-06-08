function v = subsref( dd, S );

if length(S) > 1
    error( 'Multi-part access not supported.' );
else
    value = S(1).subs;
end

if iscell( value )
    if length( value ) > 1
        error( 'Value must be single item' );
    else
        value = value{1};
    end
end
if isnumeric( value )
    if length( value ) > 1
        error( 'Value must be single item' );
    else
        value = num2str( value );
    end
end 

if strcmp(S(1).type, '()')
    pos = quickSearch( value, dd.keys );
    if ~isnan(pos)
        v = dd.values{pos};
    else
        error( ['Index "' value '" not found'] );
    end
else
    error( 'Unsupported access type' );
end
