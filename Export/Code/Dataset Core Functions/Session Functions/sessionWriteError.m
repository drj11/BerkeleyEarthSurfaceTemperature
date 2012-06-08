function sessionWriteError( msg, ME ) 
% sessionWriteError( message, Matlab error structure ) 

name = parentFunction;
sessionWriteLog( [' !!!!!!!!!! Error in ' name ' !!!!!!!!!! '] );

sessionWriteLog( ' ' )
sessionWriteLog( msg );
sessionWriteLog( ' ' )
sessionWriteLog( ME.message );
sessionWriteLog( ' ' );

for k = 1:length( ME.stack )
    sessionWriteLog( ['Error in line ' num2str(ME.stack(k).line) ...
        ' of ' ME.stack(k).name] );
end

sessionWriteLog( ' ' );
sessionWriteLog( [' !!!!!!!!!! End Error Report for ' name ' !!!!!!!!!! '] );
sessionWriteLog( ' ' );

