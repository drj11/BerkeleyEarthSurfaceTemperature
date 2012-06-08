function res = getStationNormals( se )
% Returns a structure containing station normal periodicity parameters.

temperatureGlobals;
session = sessionStart;

frc = sessionFunctionCache();

% Use cache if possible
results = get( frc, collapse( md5hash( se ) ) );

if ~isempty( results )
    res = results;
    return;
end

% Start with local
res = getLocalNormals( se );

% If local is missing, use regional
missing = false( length(se), 1 );
for k = 1:length( res )
    if isnan(res(k).mean_constant)
        missing(k) = true;
    end
end
if any( missing )
    res2 = getRegionalNormals( se );
    res(missing) = res2( missing );
end

save( frc, collapse( md5hash( se ) ), res );


