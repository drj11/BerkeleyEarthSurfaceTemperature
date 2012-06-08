function defineDataCollection( name, description, redefine )

reg = getRegistrationStructure();

if nargin < 3
    redefine = false;
end

if ismember( name, reg ) && ~redefine
    error( 'Data collection with that name already exists' );
end

collection = struct();
collection.name = name;
collection.desc = description;
collection.types = dictionary();

reg( name ) = collection; 

saveRegistrationStructure( reg );
    