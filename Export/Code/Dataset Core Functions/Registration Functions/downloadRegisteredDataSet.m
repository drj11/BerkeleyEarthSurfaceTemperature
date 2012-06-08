function downloadRegisteredDataSet( dataset_name, type_name, ver_name )

temperatureGlobals;
global password;
password = getBerkeleyEarthPassword();

svn_repos = 'svn.berkeleyearth.org';

if ~iscell( dataset_name )
    dataset_name = { dataset_name };
    type_name = { type_name };
    ver_name = { ver_name };
end

paths = cell( length(dataset_name), 1 );
sizes = zeros( length( dataset_name), 1 );

for k = 1:length( dataset_name )
    entry = findDataEntry( dataset_name{k}, type_name{k}, ver_name{k} );
    paths{k} = ['Registered Data Sets' psep entry.path];
    sizes(k) = entry.size;
end

disp( ' ' );
disp( 'Starting Download Agent' )
disp( ' ' );

disp( 'Measuring internet connection' );
try
    tic;
    test = urlread( 'http://www.yahoo.com/' );
    res = toc;

    rate = length(test) / res;
catch
    error( 'No internet connection' );
end

disp( ['Estimated download rate: ' num2str( round( rate * 8 / 1e6 * 100 ) / 100 ) ' Mbps'] );

disp( ' ' );
disp( ['Dataset(s) selected: ' num2str(length(sizes)) ] );
disp( ['Total file size: ' num2str( round(sum(sizes) / 1e6 * 100) / 100 ) ' MB'] );
disp( ['Estimated download time: ' num2str( sum(sizes) / rate / 60 ) ' minutes'] );

disp(' ');
tf = getApproval( 'Do you want to perform this download' );
if ~strcmp( tf, 'y' )
    error( 'Cancelled by user' );
end

% Create Registered Data Sets placeholder if needed
pth = [temperature_data_dir 'Registered Data Sets'];
if ~exist( pth, 'dir' ) && installed_with_svn 
    SVNcheckout( [svn_repos '/data/Registered Data Sets'], pth, 'empty' );
end 

start_time = clock;
for k = 1:length(paths)
    pth = strrep( paths{k}, '\', psep );
    pth = strrep( pth, '/', psep );
    
    disp( ['Downloading (' num2str(k) '/' ...
        num2str(length(paths)) ') : ' pth ] );
    disp( ['Estimated time for this download: ' num2str( sizes(k) / rate / 60 ) ' minutes '] );
    disp( ['Estimated time for remaining downloads: ' num2str( sum(sizes(k:end)) / rate / 60 ) ' minutes '] );
    disp( ' ' );
    
    pth2 = strrep( pth, psep, '/' );
    if installed_with_svn
        SVNcheckout( [svn_repos '/data/' pth2(1:end-1)], ...
            [temperature_data_dir pth(1:end-1)] );
    else
        fake_checkout( [svn_repos '/svn/data/' pth2], ...
            [temperature_data_dir pth] );
    end
    
    stop_time = clock;
    elapsed = etime( stop_time, start_time );
    disp( ['Download Complete, ' num2str( elapsed / 60 ) ' minutes elapsed'] );
    disp( ' ' );
    rate = sum(sizes(1:k)) / elapsed;
end

disp( ' ' );
disp( 'Download Complete' );
disp( ['Time Elapsed: ' num2str( elapsed / 60 ) ' minutes'] );

password = '';
