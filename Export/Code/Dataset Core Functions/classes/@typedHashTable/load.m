function [vals, sup] = load( dt, md5s )
% hash = LOAD( typedHashTable, MD5 Hashes );
%
% Loads data from typed table on disk

if ~isa( md5s, 'md5hash' )
    error( 'Called with something other than md5hash' );
else
    md5s = md5hash( md5s );
end

if nargout > 1
    [vals, sup] = get( dt.table, md5s );
else
    vals = get( dt.table, md5s );
end

if iscell( vals )
    vals = [vals{:}];
end
