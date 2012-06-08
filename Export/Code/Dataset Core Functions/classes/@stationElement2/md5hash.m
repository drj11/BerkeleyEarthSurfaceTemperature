function hash = md5hash( se )
%Return / Generate MD5 hash for ZipMatrix

hash = md5hash;
for k = 1:length(se)
    if isnull( se(k).md5hash )
        se(k) = compress( se(k) );
    end
    hash(k) = se(k).md5hash;
end

