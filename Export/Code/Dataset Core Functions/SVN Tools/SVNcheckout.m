function SVNcheckout( source, dest, depth )
% Use SVN checkout to copy the files

temperatureGlobals
checkPath( dest );

if nargin < 3
    depth = 'infinity';
end

source = cleanURL( source );

global BerkeleyEarth_username;

password = getBerkeleyEarthPassword();

if ~exist( [dest filesep '.svn'], 'dir' )
    cmd = sprintf( '"%s" --username "%s" --password "%s" --depth="%s" --non-interactive checkout "svn://%s" "%s"',...
        svn_path, BerkeleyEarth_username, password, depth, source, dest);
else
    cmd = sprintf( '"%s" --username "%s" --password "%s" --depth="%s" --non-interactive update "%s"',...
        svn_path, BerkeleyEarth_username, password, depth, dest);
end
status = system( cmd );
if status ~= 0
    warning( 'SVNcheckout:SVNerror', 'SVN exited with an error' );
    if ispc
        disp( ['There is a known bug on Windows 7 that causes SVN to occasionally fail.  ' ...
            'We will try repeating the download to try to get it to complete.'] );
        % This is very annoying.  When new files are created on
        % Windows 7 they are subjected to Windows indexer and/or
        % antivirus check.  SVN creates new files by first opening
        % temp files and then moving them to their final location.
        % If the temp file is being read by either of the above
        % Windows services when SVN attempts to move it, then SVN
        % will fail.  This happens sporadically and inconsistenly.
        
        % Right now the best fix appears to be to restart the
        % operation as an "update".  It is not uncommon to require
        % several restarts during a single large checkout
        
        cmd = sprintf( '"%s" --username "%s" --password "%s" --depth="%s" update "%s"',...
            svn_path, BerkeleyEarth_username, password, depth, dest);
        for cnt = 1:10
            status = system( cmd );
            if status == 0
                break;
            end
        end
        if status ~= 0
            warning( 'SVNcheckout:SVNerror2', 'Unable to complete SVN session' );
        end
    end
end

function url = cleanURL( url )

url = strrep( url, '/', 'XxXxXxXxYyYyYyY' );
url = urlencode( url );
url = strrep( url, 'XxXxXxXxYyYyYyY', '/' );
url = strrep( url, '+', '%20' );

