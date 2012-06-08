function purgeDependantFiles( dir_root )

temperatureGlobals;
hash_cache = dictionary();

dd = generateFileList( dir_root );

for k = 1:length(dd)
    dd{k}
    df = readDigestFile( dd{k} );

    if ~ismember( 'dependency', fields( df ) )
        continue;
    end

    for k = 1:length( df.dependency )
        try
            old = hash_cache( df.dependency{k}{2} );
        catch
            df2 = readDigestFile( df.dependency{k}{2} );
            old = df2.md5_hash;
            hash_cache( df.dependency{k}{2} ) = old;
        end
                
        if ~strcmp( old, df.dependency{k}{1} )
            delete( [temperature_data_dir dd(k)] );
            delete( [temperature_data_dir dd(k) '.digest'] );
            break;
        end
    end
end

hash_cache

function dd = generateFileList( dir_root )

temperatureGlobals;
dx = dir( [temperature_data_dir dir_root] );

dd = {};

for k = 1:length(dx)
    if dx(k).isdir
        if strcmp( dx(k).name, '.' ) || strcmp( dx(k).name, '..' ) 
            continue;
        end
        dx(k).name
        dn = generateFileList( [dir_root '\' dx(k).name] );
        dd(end+1:end+length(dn)) = dn;
    else
        if strcmp(dx(k).name(end-6:end), '.digest' )
            dd{end+1} = [dir_root '\' dx(k).name(1:end-7)];
        end
    end
end
        