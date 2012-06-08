function sessionSectionEnd( name )
% sessionSectionEnd( name )
% Close log subsection identified by name

if nargin == 0
    name = '';
end

sessionParallelCheck;
global SESSION_DATA

if isempty( SESSION_DATA )
    error( 'Session has not been started.' );
end
[caller, pth] = parentFunction;

block = SESSION_DATA.blocks( SESSION_DATA.depth );
if ~strcmp( block.name, name ) || ~strcmp( block.caller, caller ) || ...
        ~strcmp( block.path, pth )
    error( 'Section closure does not match last section opening' );
end

st = ['Section time elapsed ' formatTimeDifference( (now - block.start_time)*24*60*60 )];
sessionWriteLog( st );

if isempty(name)
    sessionWriteLog( ['---------- End Section ----------'] );
else
    sessionWriteLog( ['---------- End Section "' name '" ----------'] );
end  

SESSION_DATA.blocks( SESSION_DATA.depth ) = [];
SESSION_DATA.depth = SESSION_DATA.depth - 1;

sessionWriteLog('');
