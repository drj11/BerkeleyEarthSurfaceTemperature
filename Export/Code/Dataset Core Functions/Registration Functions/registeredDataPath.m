function pth = registeredDataPath ( collection, type, version )

temperatureGlobals;

pth = [ clean(collection) psep clean(type) psep 'Matlab' psep clean(version) psep];


function strval = clean( strval )

strval = strrep( strval, '/', '_' );
strval = strrep( strval, '\', '_' );
