function sx = removeFlag( se, I, flag );

sx = se;

flags = expand ( sx.flags );

for k = 1:length(flags(1,:))
    f = find( flags(I,k) == flag );
    if ~isempty(f)
        flags(I(f),k) = 0;
    end
end

flags = sort( flags, 2 );

f = find( flags(:,1:end-1) == flags(:,2:end) & flags(:,1:end-1) );
flags(f) = 0;
if ~isempty(f)
    flags = sort( flags, 2 );
end

S = max( flags );
f = find( S == 0 );

if ~isempty(f)
    flags(:,f) = [];
end

if se.auto_compress == 1
    sx.flags = zipMatrix( flags );
else
    sx.flags = flags;
end

sx.md5hash = md5hash;