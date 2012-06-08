function saveWithDigest( fname, value, generator, dependencies, other )

if nargin < 5
    other = {};
end
if nargin < 4
    dependencies = {};
end
if nargin < 3
    error( '"generator" parameter required' );
end

temperatureGlobals;

checkPath( [temperature_data_dir fname] );

save( [temperature_data_dir fname], 'value' );
generateDigestFile( [fname '.mat'] , generator, dependencies, other );