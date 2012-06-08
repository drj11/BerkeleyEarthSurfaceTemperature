function str_val = standardNameCleaner( str_val )

if iscell( str_val )
    for k = 1:length(str_val)
        str_val{k} = standardNameCleaner( str_val{k} );
    end
    return;
end

if isempty( str_val )
    return;
end

str_val = upper(str_val);
str_val( str_val == '_' | str_val == '=' ) = ' ';

if str_val(end) == '-' 
    str_val( str_val == '-' ) = ' ';
end

str_val = regexprep( str_val, '-{2,}', ' ' );
str_val = regexprep( str_val, '\s{2,}', ' ' );
str_val = regexprep( str_val, '[\s-(*]+$', '' );
str_val = regexprep( str_val, '([,\).])(\w)', '$1 $2' );
str_val = regexprep( str_val, '(\w)(\()', '$1 $2' );
str_val = strtrim( str_val );
