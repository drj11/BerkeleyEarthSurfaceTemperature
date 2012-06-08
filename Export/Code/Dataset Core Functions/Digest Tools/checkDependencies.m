function v = checkDependencies( fname )

v = 1;
df = readDigestFile( fname );

if ~ismember( 'dependency', fields( df ) )
    return;
end

for k = 1:length( df.dependency )
    df2 = readDigestFile( df.dependency{k}{2} );
    if ~strcmp(df2.md5_hash, df.dependency{k}{1} )
        v = 0;
        return;
    end
end