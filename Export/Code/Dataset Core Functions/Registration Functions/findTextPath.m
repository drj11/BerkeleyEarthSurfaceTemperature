function pth = findTextPath( collection, type, version )

if nargin == 1 && isa( collection, 'registeredDataSet' )
    rdd = collection;
    collection = rdd.collection;
    type = rdd.type;
    version = rdd.version;
end
 
entry = findDataEntry( collection, type, version );
pth = entry.path;

pth = strrep( pth, '/', filesep );
pth = strrep( pth, '\', filesep );

pth = strrep( pth, [filesep 'Matlab' filesep], [filesep 'Text' filesep] );
