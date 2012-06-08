function se = processSCARDataString( se, strs )
% Process set of SCAR data strings.

freq = stationFrequencyType('m');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

element = stationRecordType( se.record_type );
code = element.abbrev;

source_code = stationSourceType( 'SCAR' );

[year, month, value, percent] = strread( sprintf( '%s\n', strs{:} ) , ...
    '%*d%d%d%f%d', 'whitespace', ' \t', 'delimiter', '\r\n');

if length(year) ~= length(strs)
    sessionWriteLog( ['Error: Too few lines read in "' strs{1}(1:30) '"...'] );
end


v = (year - 1600)*12 + month;
dt = datenum( year, month, 1 );
dt2 = datenum( year, month + 1, 1 );
dd = dt2 - dt;

dd = round(dd.*percent/100);
f = ( percent == -1 );
dd(f) = NaN;

ls = length( year );
if ls == 0  
    error( 'No data.' );
end

original_data_code = dataFlags( 'FROM_C_TENTH' );
estimated_flag = dataFlags( 'NUM_ESTIMATED' );
flags = zeros( ls, 2 );
flags( percent ~= -1, 1 ) = estimated_flag;
flags( :, 2 ) = original_data_code;

if strcmp( code(1:2), 'OT' )
    tob = str2double( code(3:4) );
else
    tob = NaN;
end

se.dates(end+1:end+ls, 1) = v;
se.data(end+1:end+ls, 1) = value;
se.uncertainty(end+1:end+ls, 1) = 0.05;
se.time_of_observation(end+1:end+ls, 1) = tob;
se.num_measurements(end+1:end+ls, 1) = dd;
se.source(end+1:end+ls,1) = source_code;

se.flags(end+1:end+ls,1:2) = flags;

se.flags = sort( se.flags, 2 );
