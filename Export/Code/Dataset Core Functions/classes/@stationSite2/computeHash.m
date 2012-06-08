function hash = computeHash( site )

SS = struct( site );
SS = rmfield( SS, 'hash' );

hash = md5hash( SS );