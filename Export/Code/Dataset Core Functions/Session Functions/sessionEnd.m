function sessionEnd
% End session.  Called automatically by onCleanup.  This function should
% never be called directly.

sessionParallelCheck;
global SESSION_DATA;

if ~isempty(SESSION_DATA)
    fout = SESSION_DATA.log;
    
    if SESSION_DATA.depth > 0
        warning( 'TemperatureProject:sessionEnd:block_not_closed', ...
            'Session closed without closing all blocks' );        
        SESSION_DATA.depth = 0;
    end
    
    st = ['Close session for "' SESSION_DATA.caller_name '"'];
    sessionWriteLog( st );
    st = ['Total time elapsed ' formatTimeDifference( (now - SESSION_DATA.started)*24*60*60 )];
    sessionWriteLog( st );
    
    sessionWriteLog( ['================== Session Closed ==================' sprintf( '\r\n' )] );
    
    fclose( fout );
    
    fclose('all');
end

SESSION_DATA = [];
