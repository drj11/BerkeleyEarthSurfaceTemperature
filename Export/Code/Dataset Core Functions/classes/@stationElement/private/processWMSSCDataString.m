function se = processWMSSCDataString( se, strs )

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

source_code = stationSourceType( 'WMSSC' );

str = strvcat(strs);

year = sscanf( str(:,9:12)','%4d' );
month = sscanf( str(:,13:15)','%2d' );
vals = sscanf( str(:,56:61)','%d' )/10;

f = find(vals == 99.0);
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

