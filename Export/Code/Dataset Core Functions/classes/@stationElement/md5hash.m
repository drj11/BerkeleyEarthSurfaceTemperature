function hash = md5hash( se )

hash = md5hash;
for k = 1:length(se)
    se(k) = compress( se(k) );
    
    A = struct( se(k) );
    if isfield( A, 'auto_compress' )
        A = rmfield( A, 'auto_compress' );
    end

    hash(k) = md5hash( A );
end

