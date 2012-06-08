function [file_hash, dep_hash] = sessionFileHash( pth )

sessionParallelCheck;
global SESSION_DATA

if isempty( SESSION_DATA ) 
    file_hash = [];
    dep_hash = [];
end

try
    file_hash = SESSION_DATA.file_hashes( pth );
catch
    error( 'Requested File in not in the Session Archive.' );
end

if nargout > 1
    try
        dep_hash = SESSION_DATA.dep_hashes( pth );
    catch
        [~, hashes] = functionDependencies( pth, SESSION_DATA.file_hashes );
        hashes = sort(hashes);
        dep_hash = collapse( hashes );
        SESSION_DATA.dep_hashes( pth ) = dep_hash;
    end
end
     