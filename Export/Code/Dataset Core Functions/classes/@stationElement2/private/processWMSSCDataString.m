function se = processWMSSCDataString( se, strs )
% Reads a cell array of WMSSC raw data and populates the corresponding
% station element with the data.

% Verify the station element has the right frequency type
freq = stationFrequencyType('m');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if ischar( strs )
    strs = cellstr( strs );
end

source_code = stationSourceType( 'WMSSC' );
original_data_code = dataFlags( 'FROM_C_TENTH' );

str = strvcat(strs);

year = sscanf( str(:,9:12)','%4d' );
month = sscanf( str(:,13:15)','%2d' );
vals = sscanf( str(:,56:61)','%6f' )/10;

if length(year) < length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

f = find(vals == 99.0);
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
se.source(end+1:end+blocks,1) = source_code;
se.flags(end+1:end+blocks, 1) = original_data_code;

