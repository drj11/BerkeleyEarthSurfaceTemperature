function SVNcommitScratch( pth, message )

temperatureGlobals;

if nargin < 2
    message = 'Updating Scratch Directory';
end

if nargin < 1
    if isempty( temperature_scratch_dir )
        error( 'Scratch Directory is Not Defined' );
    else
        pth = temperature_scratch_dir;
    end
else
    pth = [temperature_software_dir psep pth];
    if ~exist( pth, 'dir' )
        error( ['Unable to find path: "' pth '"'] );
    end
end

SVNadd( pth, true )
SVNcommit( pth, message, true );