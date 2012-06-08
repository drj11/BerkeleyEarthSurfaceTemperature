function tf = collectionExists( name )

reg = getRegistrationStructure();

tf = ismember( name, reg );
