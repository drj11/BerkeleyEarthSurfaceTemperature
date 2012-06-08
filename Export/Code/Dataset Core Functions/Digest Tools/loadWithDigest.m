function res = loadWithDigest( fname, ignore )

temperatureGlobals;

v = load( [temperature_data_dir fname] );
res = v.value;

if nargin > 1
    if strcmp(ignore, 'ignore')
        return;
    end
end

if ~checkDependencies( [fname '.mat'] )
    warning( ['Dependencies for "' fname '" out of date'] );
end