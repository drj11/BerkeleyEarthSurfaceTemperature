function sessionWriteLog( st )
% sessionWriteLog( string )
%
% Write string to Session Log

sessionParallelCheck;
global SESSION_DATA

if isempty( SESSION_DATA )
    error( 'Session has not been started.' );
end

if SESSION_DATA.depth > 0 
    A = char( zeros( 1, SESSION_DATA.depth ) + '+' );
else
    A = ' ';
end

fout = SESSION_DATA.log;
fprintf( fout, '%s %s %s\r\n', datestr(now), A, st );

if isempty(st)
    disp(' ');
else
    disp( st );
end

persistent lastDraw
if isempty( lastDraw )
    lastDraw = 0;
end
if cputime - lastDraw > 5
    drawnow;
    lastDraw = cputime;
end

