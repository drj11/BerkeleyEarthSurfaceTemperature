function entry = findDataEntry( collection, type, version )

if nargin == 2
    version = 'LATEST';
end

reg = getRegistrationStructure;

if ismember( collection, reg )
    group = reg( collection );
else
    error( 'No collection with that name exists.' );
end

if ismember( type, group.types )
    type_record = group.types( type );
else
    error( 'Collection does not include the specified type.' );
end

if ismember( version, type_record.version )
    entry = type_record.version( version );
else
    error( 'Specified version was not found.' );
end

pth = entry.path;