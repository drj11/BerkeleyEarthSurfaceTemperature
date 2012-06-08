function cleanUpMatlabImage( fname )

A = textread( fname, '%s', 'delimiter', '\n','whitespace', '' );

I = strmatch( '(Student Version of MATLAB) show', A );
A(I) = ''; 

fout = fopen( fname, 'w' );
fprintf( fout, '%s\n', A{:} );
fclose( fout );