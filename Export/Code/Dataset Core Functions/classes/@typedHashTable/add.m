function hash = add( dt, se, caller )
% hash = ADD( typedHashTable, classes, calling function );
%
% Adds classes to the table on disk

if ~isa( se, dt.class )
    error( 'Called with mismatched class' );
end

% Don't use isempty.
if length( se ) == 0
    hash = md5hash;
    hash(1) = [];
    return;
end

if nargin < 3
    caller = parentFunction;
end
    
supplement = struct();
[supplement(1:length(se)).time] = deal(now());
[supplement(:).caller] = deal(caller);

fname = what(caller);
if ~isempty(fname)
    file_hash = saveMFile( fname );
else
    file_hash = '';
end
[supplement(:).file_hash] = deal(file_hash);

% Process in groups of 5000, otherwise too large a project can crash the
% parfor loops.
hash = md5hash;

for k = 1:5000:length(se)
    last = min(length(se),k+5000-1);
    hash(k:last) = addArray( dt.table, se(k:last), supplement(k:last) );
end