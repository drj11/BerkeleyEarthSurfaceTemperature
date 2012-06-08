function sessionParallelCheck

if exist( 'getCurrentWorker', 'file' )
    V = getCurrentWorker();
    if ~isempty(V)
        error( 'Session Info Not Available in Parallel Job' );
    end
end 
