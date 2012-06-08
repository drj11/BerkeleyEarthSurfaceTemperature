function [records, sites] = getData( dataset )
% records = getData( dataset )
%
% Loads the records from dataset

temperatureGlobals;
if length(dataset ) > 1 
    error( 'Only load one dataset at a time.  Arrays not allowed.' );
end

clean_path = dataset.path;
clean_path = strrep( clean_path, '/', psep );
clean_path = strrep( clean_path, '\', psep );

pth = [temperature_data_dir psep 'Registered Data Sets' psep clean_path]; 
cnt = 1;
pth2 = [pth 'data_' num2str(cnt) '.mat'];

records = cell( 1, 1 );
while exist( pth2, 'file' )
    A = load( pth2, 'dat' );
    records{ cnt } = A.dat;
    cnt = cnt + 1;
    pth2 = [pth 'data_' num2str(cnt) '.mat'];
end
records = [records{:}];

if nargout == 2
    sites = getSites( dataset );
end