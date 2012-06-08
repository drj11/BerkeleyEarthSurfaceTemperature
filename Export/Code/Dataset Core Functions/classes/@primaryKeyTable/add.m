function pt = add( pt, accessors )

if nargout == 0
    error( 'Must be called as "pt = add( pt, list );"' );
end

if isa( accessors, 'char' )
    accessors = cellstr( accessors );
end

for k = 1:length( accessors )
    v(k) = quickSearch( accessors{k}, pt.lookup_table_names, 'nearest' );
end
f = find( v == floor(v) & v > 0);
if ~isempty(f)
    error( 'Accessor already exists' );
end

pt.accessor_list{end+1} = accessors;
index = length(pt.accessor_list);

for k = 1:length( accessors )
    pos = v(k);
    if pos ~= floor(pos)
        pos = floor(pos);
    end

    pt.lookup_table_names(pos+2:end+1) = pt.lookup_table_names(pos+1:end);
    pt.lookup_table_names{pos+1} = accessors{k};
    pt.lookup_table_numbers = [
        pt.lookup_table_numbers(1:pos);
        index;
        pt.lookup_table_numbers(pos+1:end)
        ];

    f = find(v > pos);
    v(f) = v(f) + 1;
    
    for j = k+1:length( accessors )
        if v(j) == v(k)
            v(j) = quickSearch( accessors{j}, pt.lookup_table_names, 'nearest' );
        end
    end
end

% [s,I] = sort(pt.lookup_table_names);
% if max(diff(I)) > 1
%     pt.lookup_table_names
%     accessors
%     error('stop');
% end

if pt.auto_save;
    savePKT( pt );
end