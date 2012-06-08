function records = getData( dataset )
% records = getData( dataset )
%
% Loads the records from dataset

if length(dataset ) > 1 
    error( 'Only load one dataset at a time.  Arrays not allowed.' );
end

tb = typedHashTable( 'stationElement2' );
records = load( tb, dataset.data );