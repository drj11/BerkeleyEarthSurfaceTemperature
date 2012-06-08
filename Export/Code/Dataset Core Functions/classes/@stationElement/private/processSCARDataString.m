function se = processSCARDataString( se, strs )

freq = stationFrequencyType('m');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

element = stationRecordType( se.record_type );

if ~strcmp( element.abbrev, 'TAVG' )
    error( 'Record has wrong data type' );
end

source_code = stationSourceType( 'SCAR' );

[year, month, value] = strread( strs{1}, '%*6c%d%d%f', 'whitespace', ' \t', 'delimiter', '\n');

v = (year - 1600)*12 + month;

ls = length(year);

se.dates(end+1:end+ls) = v;
se.data(end+1:end+ls) = value;
se.time_of_observation(end+1:end+ls) = NaN;
se.num_measurements(end+1:end+ls) = NaN;
se.source(end+1:end+ls,1) = source_code;

se.flags(end+1:end+ls,1) = NaN;


