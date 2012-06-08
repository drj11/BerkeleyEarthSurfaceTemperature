function jobStartup( job )

warning( 'off', 'MATLAB:maxNumCompThreads:Deprecated' );
try
    threads = job.UserData.threads;
    maxNumCompThreads( threads );
catch
end

warning( 'on', 'MATLAB:maxNumCompThreads:Deprecated' );
