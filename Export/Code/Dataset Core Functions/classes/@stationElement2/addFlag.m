function sx = addFlag( se, I, flag );

sx = se;

flags = expand( sx.flags );
flags(I,end+1) = flag;

flags = sort( flags, 2 );

f = find( flags(:,1:end-1) == flags(:,2:end) & flags(:,1:end-1) );
flags(f) = 0;
if ~isempty(f)
    flags = sort( flags, 2 );
end

S = max( flags );
f = find( S == 0 );

if length(f) > 0
    flags(:,f) = [];
end

if sx.auto_compress == 1
    sx.flags = zipMatrix( flags );
else
    sx.flags = flags;
end

sx.md5hash = md5hash;