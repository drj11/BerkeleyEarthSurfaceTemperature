function sites = getSites( dataset )
% sites = getSites( dataset )
%
% Loads the sites from dataset

temperatureGlobals;
if length(dataset ) > 1 
    error( 'Only load one dataset at a time.  Arrays not allowed.' );
end

clean_path = dataset.path;
clean_path = strrep( clean_path, '/', psep );
clean_path = strrep( clean_path, '\', psep );

pth = [temperature_data_dir psep 'Registered Data Sets' psep clean_path]; 
A = load( [pth 'sites.mat'], 'sites' );
sites = A.sites;