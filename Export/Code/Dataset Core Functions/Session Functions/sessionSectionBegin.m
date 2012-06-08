function sessionSectionBegin( name )
% sessionSectionBegin( name )
% Begin log subsection identified by name

if nargin == 0
    name = '';
end

sessionParallelCheck;
global SESSION_DATA

if isempty( SESSION_DATA )
    error( 'Session has not been started.' );
end

sessionWriteLog('');

SESSION_DATA.depth = SESSION_DATA.depth + 1;
if isempty(name)
    sessionWriteLog( ['---------- Start Section ----------'] );
else
    sessionWriteLog( ['---------- Start Section "' name '" ----------'] );
end   

[caller, pth] = parentFunction;

blocks = struct();
blocks.name = name;
blocks.caller = caller;
blocks.path = pth;
blocks.start_time = now;

if SESSION_DATA.depth == 1
    SESSION_DATA.blocks = blocks;
else
    SESSION_DATA.blocks( SESSION_DATA.depth ) = blocks;
end