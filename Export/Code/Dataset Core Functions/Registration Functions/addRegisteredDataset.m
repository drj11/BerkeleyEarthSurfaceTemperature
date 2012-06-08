function addRegisteredDataset( collection, type, version, dp )

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

entry.path = dp.path;
entry.size = dp.size;
entry.updated = dp.date;
entry.num_records = numItems( dp );
entry.hash = md5hash( dp );

type_record.version( version ) = entry;
group.types( type ) = type_record;
reg( collection ) = group;

saveRegistrationStructure( reg );