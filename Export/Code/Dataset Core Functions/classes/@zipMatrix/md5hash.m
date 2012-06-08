function hash = md5hash( zm )
%Return / Generate MD5 hash for ZipMatrix

jv=java.security.MessageDigest.getInstance('MD5');

jv.update( typecast( zm.size, 'uint8' ) );
jv.update( typecast( zm.increment, 'uint8' ) );
jv.update( typecast( zm.type, 'uint8' ) );
if islogical( zm.data )
    jv.update( uint8(zm.data) );
else    
    jv.update( typecast( zm.data, 'uint8' ) );
end

hash = md5hash( typecast(jv.digest,'uint64') );

clear jv;
