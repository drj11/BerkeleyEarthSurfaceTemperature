function SVNadd( pth, recursive )
% Add directory or file to SVN management

temperatureGlobals;

if nargin < 2
    recursive = 0;
end

if isempty( svn_path )
    error( 'SVN path has not been setup.')
end

command = ['"' svn_path '" add --force'];
if logical(recursive) 
    command = [command ' --depth=infinity'];
else
    command = [command ' --depth=immediates'];
end

if pth(end) == '\'
    pth(end) = [];
end

command = [command ' "' pth '"'];

system(command);
