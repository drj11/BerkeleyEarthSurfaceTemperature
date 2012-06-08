function se = processHadCRUDataString( se, strs )
% Process HadCRU Data String

% Check for right frequency type
freq = stationFrequencyType('m');
if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if isa( strs, 'char' )
    strs = cellstr( strs );
end

rec = stationRecordType( se.record_type );
if ~strcmp( rec.abbrev, 'TAVG' )
    error( 'Wrong Record Type' );
end

source_code = stationSourceType( 'HadCRU' );
original_data_code = dataFlags( 'FROM_C_TENTH' );

str = strvcat(strs);
year = sscanf( str(:,1:4)','%4d' );

if length(year) ~= length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

vals = strread( str(:,5:end)', '%6f' );
month = ones(length(year),1) * (1:12);
year = year * ones( 1, 12 );
vals = vals';

month = reshape(month', 1, length(month(:)));
year = reshape(year', 1, length(year(:)));

f  = find(vals == -99);
vals(f) = [];
month(f) = [];
year(f) = [];

v = (year - 1600)*12 + month;

blocks = length(v);

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals;
se.uncertainty(end+1:end+blocks, 1) = 0.05;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = NaN;
se.source(end+1:end+blocks, 1) = source_code;
se.flags(end+1:end+blocks, 1) = original_data_code;

