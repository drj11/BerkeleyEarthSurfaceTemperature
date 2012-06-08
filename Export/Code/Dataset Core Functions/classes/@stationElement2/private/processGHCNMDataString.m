function se = processGHCNMDataString( se, strs )
% Reads a cell array of GHCN-M raw data and populates the corresponding
% station element with the data.

% Verify the station element has the right frequency type
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
source_code = stationSourceType( 'GHCN-M' );

original_data_code = dataFlags( 'FROM_C_TENTH' );

% Loop over passed strings
for jj = 1:length(strs)
    % Cut ID portion, not relevant at this stage
    str = strs{jj}(13:end);
    
    year = str2double(str(1:4));
        
    vals = sscanf( str(5:end), '%05f' );
    month = 1:12;

    % Remove missing values
    f  = find(vals == -9999);
    vals(f) = [];
    month(f) = [];
    
    if rec.units == 'C'
        % Organized in raw lists with precision 0.1 C
        vals = vals / 10;
    else
        error('Unknown Units');
    end
        
    v = (year - 1600)*12 + month;

    blocks = length(v);
    
    se.dates(end+1:end+blocks, 1) = v;
    se.data(end+1:end+blocks, 1) = vals;
    se.uncertainty(end+1:end+blocks, 1) = 0.05;
    se.time_of_observation(end+1:end+blocks, 1) = NaN;
    se.num_measurements(end+1:end+blocks, 1) = NaN;
    se.source(end+1:end+blocks, 1) = source_code;

    se.flags(end+1:end+blocks, 1) = original_data_code;

end