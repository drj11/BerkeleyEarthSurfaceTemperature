function se = processCADataString( se, strs )
% Reads a cell array of CA raw data and populates the corresponding
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

source_code = stationSourceType( 'CA' );
original_data_code = dataFlags( 'FROM_C_TENTH' );

str = strvcat(strs);

year = sscanf( str(:,17:20)','%4d' );
type = cellstr(str(:,1:4));

switch se.record_type
    case 1 %TMAX
        target = 'TMAX';
    case 2 %TMIN
        target = 'TMIN';
end

vals = zeros( length(str(:,1)), 12 );
month = vals;
for k = 1:12
    month(:, k) = ones(length(str(:,1)), 1)*k;
    vals(:, k) = sscanf( str(:,(21:25) + (k-1)*5)','%5f' )/10;
end

if length(year) < length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

year = year*ones(1, 12);

f = find( ~strcmp( target, type ) );
vals(f, :) = [];
month(f, :) = [];
year(f, :) = [];

vals = vals(:);
month = month(:);
year = year(:);
f = find( vals == -999.9 );
vals(f) = [];
month(f) = [];
year(f) =[]; 

v = (year - 1600)*12 + month;

blocks = length(v);

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals;
se.uncertainty(end+1:end+blocks, 1) = 0.05;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = NaN;
se.source(end+1:end+blocks,1) = source_code;
se.flags(end+1:end+blocks, 1) = original_data_code;

