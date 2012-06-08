function v = lookup( pt, accessors )

if isa( accessors, 'char' )
    accessors = cellstr(accessors);
end

if ~isnumeric(accessors)
    if length(accessors) == 1 && isnumeric(accessors{1})
        accessors = accessors{1};
    end
end

if isnumeric(accessors)
    if length(accessors) ~= 1
        error( 'Numeric input limited to one element' );
    else
        v = pt.accessor_list( accessors );
        v = v{:};
        return
    end
end

for k = 1:length( accessors )
    if isa( accessors{k}, 'char' )
        a = quickSearch( accessors{k}, pt.lookup_table_names );
        if ~isnan(a)
            v(k) = pt.lookup_table_numbers(a(1));
        else
            v(k) = NaN;
        end
    else
        error( 'Wrong input type' );
    end
end