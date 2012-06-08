function pt = merge( pt, index1, index2 )

temperatureGlobals;

if isa( index1, 'char' );
    index1 = lookup(pt, index1);
end
if isa( index2, 'char' );
    index2 = lookup(pt, index2);
end

if index1 == index2
    return;
end

fout = fopen([temperature_data_dir 'PrimaryKeyTable_' pt.name '_merge.log'],'a');
for k = 1:length(pt.accessor_list{index1});
    if k > 1
        fprintf( fout, ', ' );
    end
    fprintf( fout, '%c', pt.accessor_list{index1}{k});
end
fprintf(fout,' <=> ');
for k = 1:length(pt.accessor_list{index2});
    if k > 1
        fprintf( fout, ', ' );
    end
    fprintf( fout, '%c', pt.accessor_list{index2}{k});
end
fprintf(fout,'\n');
fclose(fout);

for k = 1:length(pt.accessor_list{index2})
    pt.accessor_list{index1}{end+1} = pt.accessor_list{index2}{k};
end

pt.accessor_list{index2} = {};
f = find(pt.lookup_table_numbers == index2);
pt.lookup_table_numbers(f) = index1;

if pt.auto_save
    savePKT( pt );
end