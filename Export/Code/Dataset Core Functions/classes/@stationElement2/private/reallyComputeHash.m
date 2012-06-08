function se = reallyComputeHash( se )
%Generate MD5 hash for StationElement

for k = 1:length(se)
    jv=java.security.MessageDigest.getInstance('MD5');
    
    jv.update( typecast( se(k).record_type, 'uint8' ) );
    jv.update( typecast( se(k).frequency, 'uint8' ) );
    B = se(k).site;
    jv.update( typecast( B.num, 'uint8' ) );
    
    B = se(k).dates;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end

    B = se(k).time_of_observation;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end

    B = se(k).data;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end

    B = se(k).uncertainty;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end
    
    B = se(k).num_measurements;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end

    B = se(k).flags;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B(:), 'uint8' ) );
    end

    B = se(k).source;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B(:), 'uint8' ) );
    end

    B = se(k).record_flags;
    if isa( B, 'zipMatrix' )
        C = md5hash( B );
        jv.update( typecast( C.num, 'uint8' ) );
    elseif ~isempty( B )
        jv.update( typecast( B, 'uint8' ) );
    end

    B = se(k).primary_record_ids;
    if ~isempty( B )
        B = collapse( B );
        jv.update( typecast( B.num, 'uint8' ) );
    end
    
    se(k).md5hash = md5hash( typecast(jv.digest,'uint64') );  

    clear jv;
end

