function res = getRegionalNormals( se )
% Returns a structure containing regional normal periodicity parameters.

temperatureGlobals;
session = sessionStart;

min_length = 5; % years;
min_completeness = 0.8;

max_distance = 2500; % km
max_compare = 21;
num_exclusions = 3;

bf = getBadFlags();

% Determine which sites meet the length and completeness criteria order to
% be consider as local comparison references.
good_sites = false( length(se), 1 );
parfor k = 1:length(se)
    dates = getData( se(k), bf );
    len = dates(end) - dates(1);
    if len < min_length
        continue;
    end
    cc = length(dates) / len;
    if isMonthly( se(k) )
        cc = cc / 12;
    else
        cc = cc / 365.25;
    end
    if cc < min_completeness
        continue;
    end
    good_sites(k) = true;    
end     

[dates, data] = getData( se(1) );

% Use first value to prime data structure;
res(1) = characterizeDataPeriodicity( dates, data );
res(1:length(se)) = res(1);

local_normals(1:length(se)) = res(1);
local_normals(good_sites) = getLocalNormals( se(good_sites) );

good_sites = (good_sites & ~isnan( [local_normals.mean_constant]' ));

sites = [se(:).sites];
neighbors = findNeighbors( sites, max_distance, max_compare, good_sites );

frc = sessionFunctionCache();

% Use cache if possible
input = cell( length(se) );
for j = 1:length(se)
    input{j} = { {md5hash( se(j) )}, {sites(neighbors{j})} };
end
results = getArray( frc, input );

missing = zeros( length(results), 1);

for k = 1:length(missing)
    if isempty( results{k} )
        missing(k) = 1;
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
neighbors = neighbors(I);

% Load missing values
for k = 1:length(I)    
    res2(k) = generateReferenceValues( local_normals( neighbors{k} ), num_exclusions );
end

res(I) = res2;

% Save to cache;
saveArray( frc, input(I), res2 );


function res2 = generateReferenceValues( res, exclusions )
% Combines the reference records

% Exclude specified number of high and low outliers.
selected = (exclusions+1:length(res)-exclusions);

if isempty( selected )
    res2.mean_constant = NaN;
    res2.variance_constant_high = NaN;
    res2.variance_constant_low = NaN;
    res2.mean_periodicity = zeros(2*3,1)*NaN;
    res2.variance_periodicity_high = zeros(2*3,1)*NaN;
    res2.variance_periodicity_low = zeros(2*3,1)*NaN;
    return;
end

res2 = res(1);

% Constant Portion
means = [res.mean_constant];
means = sort(means);

res2.mean_constant =  mean(means(selected));
% Augment with variance among sites to account for regional variability.
ss = std(means(selected));

var_high = [res.variance_constant_high];
var_high = sort(var_high);

res2.variance_constant_high =  sqrt(mean(var_high(selected)).^2 + ss.^2);

var_low = [res.variance_constant_low];
var_low = sort(var_low);

res2.variance_constant_low =  sqrt(mean(var_low(selected)).^2 + ss.^2);


% Periodic portion
means = [res.mean_periodicity];
means = sort(means,2);

res2.mean_periodicity =  mean(means(:,selected), 2);
ss = std(means(:,selected), 0, 2);
% TODO: Increase periodic amplitudes in proportion to sample variance.

var_high = [res.variance_periodicity_high];
var_high = sort(var_high,2);

res2.variance_periodicity_high =  mean(var_high(:,selected), 2);

var_low = [res.variance_periodicity_low];
var_low = sort(var_low,2);

res2.variance_periodicity_high =  mean(var_low(:,selected), 2);
