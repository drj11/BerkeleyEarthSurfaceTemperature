function display( se )

if length( se ) == 1
    sx = struct();
    A = md5hash( se );
    sx.md5hash = A.hash;
    
    v = stationRecordType( se.record_type );
    if isstruct(v)
        sx.record_type = v.abbrev;
    else
        sx.record_type = se.record_type;
    end
    
    v = stationFrequencyType( se.frequency );    
    sx.frequency = v;
    
    if ~isempty( se.site )
        sx.site = se.site.hash;
    else
        sx.site = 'None';
    end
    
    sx.length = length(se.dates);
    sx.record_flags = se.record_flags;
    sx.primary_record_ids = se.primary_record_ids;
    sx.auto_compress = se.auto_compress;
    
    disp(sx)
    disp( 'Additional accessors:' );
    disp( '   dates, datenum, data, uncertainty, tob, num, flags, source' );
    disp( ' ' );
else
    disp( [' ' num2str( length(se) ) ' stationElements'] );
end
