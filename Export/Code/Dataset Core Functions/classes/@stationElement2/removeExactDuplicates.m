function sx = removeExactDuplicates( se )
% stationElement = removeExactDuplicates( stationElement )
%
% Scan a record and collapse any multi-valued dates where the data is
% identical across multiple reports

dates = double( se.dates );

% If the series is single-valued, simply exit.
if length( unique( dates ) ) == length( dates )
    sx = se;
    return;
end
if length( se ) > 1
    error( 'Only supports single input' );
end

% If record is already single valued, just return it back
dates = double( se.dates );
if length( uniquePreSorted( dates ) ) == length( dates )
    sx = se;
    return;
end

% Use blank flags if not specified
if nargin < 2
    bf = [];
end

st = structureMerge( se );
st = mergeCore( st, bf, 'remove_duplicates' );
sx = class( st, 'stationElement2' );

if sx.auto_compress
    sx = compress( sx );
else
    sx.md5hash = md5hash;
end


function vals = uniquePreSorted( vals )

db = diff(vals);
d = db ~= 0;
d = [true; d];

vals = vals(d);
