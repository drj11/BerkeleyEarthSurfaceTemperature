function defineDataType( collection, name, description, redefine )

reg = getRegistrationStructure();

if nargin < 4
    redefine = false;
end

if ~ismember( collection, reg )
    error( 'Data collection with that name doesn''t exist' );
end

type = struct();
type.name = name;
type.desc = description;
type.version = dictionary();

group = reg( collection );
if ismember( name, group.types ) && ~redefine
    error( 'Type with that name already exists' );
end

group.types( name ) = type;
reg( collection ) = group; 

saveRegistrationStructure( reg );
    