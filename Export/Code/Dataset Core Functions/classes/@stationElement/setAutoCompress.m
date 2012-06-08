function se = setAutoCompress( se, v )

if nargin < 2
    v = 1;
end

for k = 1:length(se)
    se(k).auto_compress = v;
    if v == 1
        se(k) = compress( se(k) );
    end
end