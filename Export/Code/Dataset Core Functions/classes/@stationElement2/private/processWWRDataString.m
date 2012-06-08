function se = processWWRDataString( se, strs )
% Reads a cell array of WWR raw data and populates the corresponding
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

source_code = stationSourceType( 'WWR' );
original_data_code = dataFlags( 'FROM_C_TENTH' );

str = strvcat(strs);

year = sscanf( str(:,9:12)','%4d' );
type = str2num( str(:,8) );
special = str(:,13);
f = ( special == ' ' );
special(f) = '0';
special = str2num( special );

switch se.record_type
    case 3 %TAVG
        target = 4;
    case 1 %TMAX
        target = 6;
    case 2 %TMIN
        target = 7;
end

vals = zeros( length(str(:,1)), 1 );
month = vals;
for k = 1:12
    % Missing values are encoded as blank spaces, but Matlab hates it when
    % you do that, so we are detecting the spaces and repalcing them with
    % "NaN"s.
    f = find( str(:, 18 + (k-1)*5 ) == ' ' );
    str( f, (16:18) + (k-1)*5 ) = ones(length(f), 1)*'NaN'; 
    month(:, k) = ones(length(str(:,1)), 1)*k;
    vals(:, k) = sscanf( str(:,(14:18) + (k-1)*5)','%5f' )/10;
end

if length(year) < length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

year = year*ones(1, 12);

f = find(special >= 1 | type ~= target);
vals(f, :) = [];
month(f, :) = [];
year(f, :) = [];

vals = vals(:);
month = month(:);
year = year(:);
f = find( isnan( vals ) );
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

