function hash = saveMFile( fname )
% Saves M file into the file cache.
persistent mc;

if isempty( mc )
    mc = primitiveHashTable( 'Matlab Code' );
end

if ~exist( fname, 'file' )
    error( ['Unable to find file: ' fname] );
end

fin = fopen( fname, 'r' );
A = fread( fin, Inf, 'uchar' );
fclose( fin );

A = cleanMFile( char(A) );

B = struct();
B.time = now();
B.file_name = fname;

hash = add( mc, A, B );
