function sx = replaceFlag( se, I, flag1, flag2 );

sx = se;

flags = expand( sx.flags );

f = find( flags == flag1 );
flags(f) = flag2;

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