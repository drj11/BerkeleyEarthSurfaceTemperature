function sx = merge( se1, se2, bf )
% stationElement = merge( stationElement1, stationElement2, bad_flags )
%
% The basic merge operation.  Data is merged if and only if the values are
% consistent within the precision of the data.  Otherwise, this results in
% a multi-valued record.  Use makeSingleValued to create single valued
% record.

if length( se1 ) > 1 || length( se2 ) > 1
    error( 'Only supports single input' );
end

% Check types
if se1.record_type ~= se2.record_type
    se1 = makeEquivalent( se1 );
    se2 = makeEquivalent( se2 );
    if se1.record_type ~= se2.record_type    
        error('Record Types does not match.');
    end
end
if se1.frequency ~= se2.frequency
    error('Frequency does not match.');
end

% Use blank flags if not specified
if nargin < 3
    bf = [];
end

se = [se1, se2];

st = structureMerge( se );
st = mergeCore( st, bf, 'merge_consistent' );


% Replace very fine differences with nearest thousandths.  This is useful
% in support of the compression algorithms.
dd = abs(diff( st.data ));
f = ( dd > 1e-7 );
if min(dd(f)) < 0.001
    st.data = round( st.data * 1000 ) / 1000;
    st.uncertainty = round( st.uncertainty * 10000 ) / 10000;
end


sx = class( st, 'stationElement2' );

if sx.auto_compress
    sx = compress( sx );
else
    sx.md5hash = md5hash;
end
