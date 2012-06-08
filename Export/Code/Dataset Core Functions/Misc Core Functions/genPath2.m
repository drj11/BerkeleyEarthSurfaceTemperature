function P = genPath2( root )
% Recursively generates a path excluding svn folders

if root(end) == filesep
    root = root(1:end-1);
end

if ~exist( root, 'dir' )
    error( 'Not a vaild path' );
end

P = root;
dd = dir(root) ;

for k = 1:length(dd)
    if ~dd(k).isdir
        continue;
    end
    if strcmp( dd(k).name, '..' ) || strcmp( dd(k).name, '.' ) || ...
            strcmp( dd(k).name, '.svn' ) || strcmp( dd(k).name(1), '@' )
        continue;
    end
    P2 = genPath2( [root filesep dd(k).name] );
    
    P = [P pathsep  P2];
end