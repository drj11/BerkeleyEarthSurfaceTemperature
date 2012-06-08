function display( se )

sx = struct( se );

if length( se ) == 1
    v = stationRecordType( sx.record_type );
    if isstruct(v)
        sx.record_type = v.abbrev;
    end
    v = stationFrequencyType( sx.frequency );    
    sx.frequency = v;
end

display( sx );