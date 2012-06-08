function se = setSite( se, site )
% Sets the site field to "site"

for k = 1:length(se)
    se(k).site = md5hash( site );
    se(k).md5hash = md5hash;
end