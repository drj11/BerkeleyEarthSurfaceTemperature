function sites = getSites( dataset )
% sites = getSites( dataset )
%
% Loads the sites from dataset

if length( dataset ) > 1 
    error( 'Only load one dataset at a time.  Arrays not allowed.' );
end

tb = typedHashTable( 'stationSite2' );
sites = load( tb, dataset.sites );