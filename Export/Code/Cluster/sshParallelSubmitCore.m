function sshParallelSubmitCore( scheduler, job, props, threads, include_self )
%sshParallelSubmitFcn - submit script example
%   This example is designed to run only on UNIX workers. It works by
%   calling a wrapper shell script which uses SSH to launch SMPD processes
%   on each worker. The workers to use are specified by a hosts file which
%   is supplied to the submit function as an extra input argument - i.e. the
%   generic scheduler's ParallelSubmitFcn property must be specified like
%   this:
% 
%   s.ParallelSubmitFcn = {@sshParallelSubmitFcn, '/path/to/hosts.file'};
%
%   After completion of the mpiexec command, the SMPD processes are
%   destroyed again using SSH.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $   $Date: 2006/12/27 20:41:04 $

% Set up the environment for the decode function - the wrapper shell script
% will ensure that all these are forwarded to the MATLAB workers.
setenv( 'MDCE_DECODE_FUNCTION', 'sshParallelDecode' );
setenv( 'MDCE_STORAGE_LOCATION', props.StorageLocation );
setenv( 'MDCE_STORAGE_CONSTRUCTOR',props.StorageConstructor );
setenv( 'MDCE_JOB_LOCATION', props.JobLocation );

%if props.NumberOfTasks > scheduler.ClusterSize
%    error( 'Requested workers exceeds ClusterSize specification' );
%end

% Tell the script how many parallel processes to launch
setenv( 'MDCE_NUM_PROCS', num2str( props.NumberOfTasks ) );

if props.NumberOfTasks > MDCEavailable() 
    error( 'Cluster:Licenses', 'Insufficient MDCE Licenses Available' );
end

% Choose the smpd port to use - base this on the job ID
setenv( 'MDCE_SMPD_PORT', num2str( 20000 + mod( job.ID, 10000 ) ) ); 

% Set this so that the script knows where to find MATLAB, SMPD and MPIEXEC on
% the cluster. This might be empty - the wrapper script must deal with that.
setenv( 'MDCE_CMR', scheduler.ClusterMatlabRoot );

% Tell the script what it needs to run under MPIEXEC. These two properties
% will incorporate ClusterMatlabRoot if it is set.
setenv( 'MDCE_MATLAB_EXE', props.MatlabExecutable );
setenv( 'MDCE_MATLAB_ARGS', props.MatlabArguments );

% Create updated node file
if nargin < 4
    threads = 1;
    include_self = true;
elseif nargin < 5
    include_self = true;
end
[~, nodefile] = buildNodeList( props.NumberOfTasks, threads, include_self );

job.UserData.threads = threads;

% Tell the script which hosts file to use
setenv( 'MDCE_HOSTS_FILE', nodefile );

% Choose a file for the output. Please note that currently, DataLocation refers
% to a directory on disk, but this may change in the future.
logFile = fullfile( scheduler.DataLocation, ...
                    sprintf( 'Job%d.mpiexec.out', job.ID ) );
fprintf( 1, 'mpiexec output directed to: %s\n', logFile );

% Assume script is in the same directory as this M-file
[dirpart] = fileparts( mfilename( 'fullpath' ) );
scriptName = fullfile( dirpart, 'sshParallelWrapper.sh' );

% Then execute the wrapper script
[s,w] = system( sprintf( '"%s" > "%s" &', scriptName, logFile ) );

% Report an error if the script did not execute correctly.
if s
    warning( 'distcompexamples:generic:SSH', ...
             'Submit failed with the following message:\n%s', w );
else
    disp( w );
end

% delete( nodefile );
