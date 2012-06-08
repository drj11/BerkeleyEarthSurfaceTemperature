function result = sessionStart
% session_variable = sessionStart
%
% Start session.  Returned value must be stored to variable.

if nargout < 1
    error( 'TemperatureProject:sessionStart', ...
        'Must be called with an output argument.' );
end

sessionParallelCheck;
global SESSION_DATA;

temperatureGlobals;
result = [];

st = dbstack(1,'-completenames');
if isempty(st) 
    SESSION_DATA = [];
    return;
elseif length(st) > 1
    if ~isempty(SESSION_DATA)
        return;
    end
end

SESSION_DATA.caller_name = st(1).name;
SESSION_DATA.caller_file = st(1).file;
SESSION_DATA.started = now;
SESSION_DATA.function_cache = dictionary();

SESSION_DATA.blocks = struct();
SESSION_DATA.depth = 0;

SESSION_DATA.log = fopen( temperature_session_log, 'a' );
fout = SESSION_DATA.log;
sessionWriteLog( '================== New Session ==================' );
st = ['Open session for "' SESSION_DATA.caller_name '"'];
sessionWriteLog( st );

[dependencies, hashes] = functionDependencies( SESSION_DATA.caller_file );
SESSION_DATA.file_hashes = dictionary( dependencies, hashes );
SESSION_DATA.dep_hashes = dictionary();

[~,I] = sort( dependencies );
dependencies = dependencies(I);
hashes = hashes(I);

sessionWriteLog( '' );

st = [ 'Archiving current versions of required Matlab source code' ];
sessionWriteLog( st );

rt = length( temperature_software_dir ) + 1;
for k = 1:length(dependencies)
    st = sprintf( 'Save "%s": \t%s', dependencies{k}(rt:end), hashes(k).hash );
    sessionWriteLog( st );
end
st = [ num2str(length(dependencies)) ' dependent files saved'];
sessionWriteLog( st );
sessionWriteLog( '' );


result = struct();
result.caller = SESSION_DATA.caller_name;
result.time = SESSION_DATA.started;
result.cleanup = onCleanup( @sessionEnd );

