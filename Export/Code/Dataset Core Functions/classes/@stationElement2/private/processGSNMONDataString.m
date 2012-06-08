function se = processGSNMONDataString( se, strs )
% Process set of GSNMON data strings.

freq = stationFrequencyType('m');
if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

element = stationRecordType( se.record_type );
code = element.abbrev;

source_code = stationSourceType( 'GSNMON' );

lengths = zeros(length(strs), 1);
for k = 1:length(strs)
    strs{k}( strs{k} == '*' ) = ' ';
    strs{k} = strtrim( strs{k} );
    lengths(k) = length(strs{k});
end
f = find(lengths < 14 );
strs(f) = [];

[year, month, value] = strread( sprintf( '%s\n', strs{:} ) , ...
    '%*d%d%d%f', 'whitespace', ' \t', 'delimiter', '\r\n');

if length(year) < length(strs)
    sessionWriteLog( ['Error: Too few lines read in "' strs{1}(1:30) '"...'] );
end

f = (value == -999.9) | isnan(value);
value(f) = [];
year(f) = [];
month(f) = [];
if isempty(year)
    return;
end

v = (year - 1600)*12 + month;

ls = length( year );
if ls == 0  
    error( 'No data.' );
end

original_data_code = dataFlags( 'FROM_C_TENTH' );
flags = zeros( ls, 1 );
flags( :, 1 ) = original_data_code;

se.dates(end+1:end+ls, 1) = v;
se.data(end+1:end+ls, 1) = value;
se.uncertainty(end+1:end+ls, 1) = 0.05;
se.time_of_observation(end+1:end+ls, 1) = NaN;
se.num_measurements(end+1:end+ls, 1) = NaN;
se.source(end+1:end+ls, 1) = source_code;

se.flags(end+1:end+ls, 1) = flags;
