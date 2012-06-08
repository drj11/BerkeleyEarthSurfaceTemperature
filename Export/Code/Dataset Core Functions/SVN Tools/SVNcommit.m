function SVNcommit( pth, message, recursive )
% Add directory or file to SVN management

temperatureGlobals;

if nargin < 3
    recursive = 0;
end
if nargin < 2
    error( 'Must specify commit message.' );
end

if isempty( svn_path )
    error( 'SVN path has not been setup.')
end
password = getBerkeleyEarthPassword();

command = ['"' svn_path '" commit --message="' message '"'];
if logical(recursive) 
    command = [command ' --depth=infinity'];
else
    command = [command ' --depth=immediates'];
end

if pth(end) == '\'
    pth(end) = [];
end

command = [command ' --username=' BerkeleyEarth_username];
command = [command ' --password=' password];
command = [command ' --non-interactive'];
command = [command ' "' pth '"'];
