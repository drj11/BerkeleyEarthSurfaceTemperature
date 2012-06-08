function se = processGHCNMDataString( se, strs )

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

str = strvcat(strs);

year = sscanf( str(:,1:4)','%4d' );

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

se.dates(end+1:end+blocks) = v;
se.data(end+1:end+blocks) = vals;
se.time_of_observation(end+1:end+blocks) = NaN;
se.num_measurements(end+1:end+blocks) = NaN;
se.source(end+1:end+blocks,1) = source_code;
se.flags(end+1:end+blocks,1) = NaN;

