function updateRegistratedDatasetList()
% Updates the registration registry to allow the user to know what files
% are currently available for download.

temperatureGlobals;

password = getBerkeleyEarthPassword();

pth = [temperature_data_dir 'Registered Data Sets' psep 'Registration Records'];

try
    urlread( 'http://www.google.com/' );
catch
    error( 'No internet connection' );
end

if installed_with_svn
    svn_path = 'svn.berkeleyearth.org/data/Registered Data Sets/Registration Records';
    SVNcheckout( svn_path, pth );
else
    svn_path = 'svn.berkeleyearth.org/svn/data/Registered Data Sets/Registration Records/';
    fake_checkout( svn_path, [pth psep] );
end
