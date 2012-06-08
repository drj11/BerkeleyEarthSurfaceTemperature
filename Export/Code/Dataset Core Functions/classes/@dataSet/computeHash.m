function hash = computeHash( ds )

m1 = md5hash( ds.name );
m2 = collapse( ds.data );
m3 = collapse( ds.sites );

hash = collapse( [m1, m2, m3] );
