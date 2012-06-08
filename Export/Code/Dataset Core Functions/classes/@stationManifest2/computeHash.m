function hash = computeHash( mn )

SS = struct( mn );
SS = rmfield( SS, 'hash' );

hash = md5hash( SS );