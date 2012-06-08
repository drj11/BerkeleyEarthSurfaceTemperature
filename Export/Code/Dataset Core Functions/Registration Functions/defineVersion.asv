function defineVersion( collection, type, name, description, redefine )

reg = getRegistrationStructure();

if nargin < 5
    redefine = false;
end

if ~ismember( collection, reg )
    error( 'Data collection with that name doesn''t exist' );
end

ver = struct();
ver.name = name;
ver.desc = description;
ver.path = '';
ver.size = 0;
ver.updated = 0;
ver.num_records = 0;
ver.hash = md5hash;

group = reg( collection );
if ~ismember( type, group.types )
    error( 'Type with that name doesn''t exists' );
end

type_record = group.types( type );
versions = type_record.version;
if ismember( name, versions ) && ~redefine
    error( 'Version with that name already exists' );
end

versions( name ) = ver;
type_record.version = versions;
group.types( type ) = type_record;
reg( collection ) = group;

saveRegistrationStructure( reg );
    