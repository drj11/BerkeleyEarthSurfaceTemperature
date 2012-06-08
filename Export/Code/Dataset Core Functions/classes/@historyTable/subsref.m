function v = subsref( dd, S )

if length(S) > 1
    error( 'Multi-part access not supported.' );
else
    value = S(1).subs;
end

if iscell( value )
    if length( value ) > 2
        error( 'Value must be one or two items' );
    elseif length( value ) == 2
        value = [value{1}, value{2}];
    elseif length( value ) == 1
        value = [value{1}, 0];
    else
        value = [now, 0];
    end
end
if length(value) > 2
    error( 'Needs 1 or 2 parameters.' );
end

if isnumeric( value )
    if length( value ) > 2
        error( 'Value must be one or two items' );
    elseif length( value ) == 2
        value = value;
    elseif length( value ) == 1
        value = [value, 0];
    else
        value = [now, 0];
    end
end 

if ischar( value )
    error( 'Index must be numeric.' );
end

if value(1) <= 0
    value(1) = now;
end

if strcmp(S(1).type, '()')
    pos = quickSearch( value(1), dd.keys, 'nearest' );
    if ~isnan(pos)
        pos = floor(pos);
        if pos == 0
            v = [];
        elseif pos > length(dd.keys)
            v = [];
        elseif dd.keys(pos) > value(1) || dd.keys(pos) < value(2)
            v = [];
        else
            v = dd.values{pos};
        end
    else
        error( 'No content' );
    end
else
    error( 'Unsupported access type' );
end
