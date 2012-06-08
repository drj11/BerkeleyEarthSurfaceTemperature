function hash = hashFile( fname )
% Generate an MD5 hash given a file name

if ~exist( fname, 'file' )
    error( 'Unable to locate required file.' );
end

fin = fopen( fname, 'r' );

jv=java.security.MessageDigest.getInstance('MD5');

while ~feof(fin)
    A = fread( fin, 50000, 'uchar' );
    jv.update(A);
end
fclose( fin );

hash = md5hash( typecast(jv.digest,'uint64') );

clear jv;

