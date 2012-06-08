function res = getLocalNormals( se )
% Returns a structure containing station normal periodicity parameters.

temperatureGlobals;
session = sessionStart;

frc = sessionFunctionCache();

% Use cache if possible
results = getArray( frc, num2cell( md5hash( se ) ) );

missing = false( length(results), 1);

[dates, data] = getData( se(1) );

% Use first value to prime data structure;
res(1) = characterizeDataPeriodicity( dates, data );
res(1:length(missing)) = res(1);

for k = 1:length(missing)
    if isempty( results{k} )
        missing(k) = true;
    else
        res(k) = results{k};
    end
end

if sum(missing) == 0
    res = [results{:}];
    return;
end

I = find( missing );

bf = getBadFlags();

se2 = se(I);
res2 = res(I);

% Load missing values
parfor k = 1:length(I)
    [dates, data] = getData( se2(k), bf );
    
    res2(k) = characterizeDataPeriodicity( dates, data );
end

res(I) = res2;

% Save to cache;
saveArray( frc, num2cell( md5hash( se2 ) ), res2 );


