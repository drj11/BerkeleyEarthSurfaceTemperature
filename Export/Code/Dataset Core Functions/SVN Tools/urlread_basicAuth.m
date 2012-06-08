function html = urlread_basicAuth( urlstr, filename )
% Downloads material from the web using BasicAuth protocols.

temperatureGlobals;
password = getBerkeleyEarthPassword();

if nargout == 0 && nargin < 2
    error( 'Wrong number of parameters' );
end

urlstr = cleanURL( urlstr );

input_string = javaObject('java.lang.String', ...
    [BerkeleyEarth_username ':' password]);
encoder = sun.misc.BASE64Encoder();
encoding = encode( encoder, getBytes( input_string ) );

% Use java's default handler to avoid stream caching rather than the http
% handler that is ordinarily included in Matlab.  Matlab's default tends to
% give out of memory errors for very large downloads.
handler = sun.net.www.protocol.http.Handler;
url = java.net.URL( [], urlstr, handler );

uc = openConnection( url );
uc.setRequestProperty( 'Authorization', ['Basic ' char(encoding)] );

inputStream = getInputStream( uc );
if nargout > 0
    outputStream = java.io.ByteArrayOutputStream;
else
    outputStream = java.io.FileOutputStream( filename );
end

try
    % This StreamCopier is unsupported and may change at any time.
    import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream, outputStream);
catch ME
    try
        % ISC not available on Octave, try apache default (not
        % interruptible)
        import org.apache.commons.io.IOUtils
        IOUtils.copy( inputStream, outputStream );
    catch ME
        error( 'temperatureInstaller:StreamCopierMissing', 'Fatal Error: No stream copier available' );
    end
end

inputStream.close;
outputStream.close;

if nargout > 0
    html = char(outputStream.toByteArray');
end


function res = cleanURL( urlstr )
% Format a URL string.
res = strrep( urlstr, '%', '%25' );
res = strrep( res, ' ', '%20' );