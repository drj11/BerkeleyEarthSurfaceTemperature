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

source_code = stationSourceType( 'GHCN-M' );

for jj = 1:length(strs)
    str = strs{jj}(13:end);
    
    year = str2double(str(1:4));
        
    vals = sscanf( str(5:end), '%05d' );
    month = 1:12;

    f  = find(vals == -9999);
    vals(f) = [];
    month(f) = [];
    
    if rec.units == 'C'
        vals = vals / 10;
    else
        error('Unknown Units');
    end
        
    v = (year - 1600)*12 + month;

    blocks = length(v);
    
    se.dates(end+1:end+blocks) = v;
    se.data(end+1:end+blocks) = vals;
    se.time_of_observation(end+1:end+blocks) = NaN;
    se.num_measurements(end+1:end+blocks) = NaN;
    se.source(end+1:end+blocks,1) = source_code;

    se.flags(end+1:end+blocks,1) = NaN;

end