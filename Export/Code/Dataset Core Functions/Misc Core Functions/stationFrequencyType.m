function v = stationFrequencyType( c, reload )

persistent frequency_type_specification frequency_type_name;
if isempty( frequency_type_specification ) || (nargin > 1 && logical( reload ) )
    [frequency_type_specification, frequency_type_name] = ...
        loadFrequencyTypes();
end

persistent last_frequency_key last_frequency_value;

if isnumeric( c ) 
    if length( c ) > 1
        v{1} = stationFrequencyType( c(1) );
        v{length(c)} = v{1};
        for k = 2:length(c)
            v{k} = stationFrequencyType( c(k) );
        end
        return;
    end
end

if isa( c, 'char' )
    c = lower(c);    
    if strcmp( c, last_frequency_key )
        v = last_frequency_value;
    else
        v = frequency_type_specification( lower(c) );
        last_frequency_key = c;
        last_frequency_value = v;
    end
elseif isa( c, 'double' )
    v = frequency_type_name{c};
end           


function [frequency_type_specification, frequency_type_name] = loadFrequencyTypes()

fts = {
    {'Daily', 'd', 'day', 'dly'},
    {'Monthly', 'm', 'mon', 'month'},
    {'Annual', 'a', 'year', 'yr', 'y'},
    {'Hourly', 'h', 'hour', 'hr'}
    };

frequency_type_specification = dictionary();
frequency_type_name = {};

for k = 1:length(fts)
    frequency_type_name{k} = fts{k}{1};
    for j = 1:length(fts{k})
        frequency_type_specification( lower(fts{k}{j}) ) = k;
    end
end

        