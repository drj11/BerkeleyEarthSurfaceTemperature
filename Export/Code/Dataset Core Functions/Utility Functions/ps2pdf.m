function ps2pdf( input_pth, output_pth )
% Convert PS file to PDF.

temperatureGlobals;

if ~exist( 'ps2pdf_path', 'var' ) || strcmp( ps2pdf_path, 'None' )
    error( 'ps2pdf path not set' );
end

if nargin == 0
    error( 'No input.' );
end
if nargin == 1
    [pathstr, name, ext] = fileparts( input_pth );
    output_pth = [pathstr filesep name '.pdf'];
end

system( ['"' ps2pdf_path '" "' input_pth '" "' output_pth '"'] );