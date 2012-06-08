function se = processUSHCNMDataString( se, strs )
% Reads a cell array of USHCN-M raw data and populates the corresponding
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

source_code = stationSourceType( 'USHCN-M' );
original_data_code = dataFlags( 'FROM_F_TENTH' );

str = strvcat(strs);

year = sscanf( str(:,8:11)','%4d' );

[vals, flags_tok] = strread( str(:,13:end-7)', '%6f%1c', 'whitespace', '');
vals = vals / 10;

if length(vals) < length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

flags = zeros( length(flags_tok), 1 );

un = unique( flags_tok );
for j = 1:length(un)
    if un(j) == ' '
        continue;
    end
    f = ( flags_tok == un(j) );
    flags(f) = dataFlags( ['USHCN-M_' un(j)] );
end

month = ones(length(year),1) * (1:12);
year = year * ones( 1, 12 );
vals = vals';

month = reshape(month', 1, length(month(:)));
year = reshape(year', 1, length(year(:)));

f = find(vals == -999.9);
vals(f) = [];
month(f) = [];
year(f) = [];
flags(f) = [];

v = (year - 1600)*12 + month;

vals = unitConversion( vals, 'F', 'C' );

blocks = length(v);

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals;
se.uncertainty(end+1:end+blocks, 1) = 0.05*5/9;
se.time_of_observation(end+1:end+blocks,1) = NaN;
se.num_measurements(end+1:end+blocks,1) = NaN;
se.source(end+1:end+blocks,1) = source_code;
se.flags(end+1:end+blocks,1:2) = [flags, ones(blocks, 1)*original_data_code];

se.flags = sort( se.flags, 2 );

