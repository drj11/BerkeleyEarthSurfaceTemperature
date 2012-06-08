function sx = makeSingleValued( se, bf )
% stationElement = makeSingleValued( stationElement, bad_flags )
%
% Takes a station element record that may be multi-valued and returns a
% single-valued alternative record.  This operates on the assumption that
% all non-flagged values it is passed are equally acceptable, and expands
% the uncertainty to accommodate that if necessary.

if length( se ) > 1
    error( 'Only supports single input' );
end
if numItems(se) <= 1
    sx = se;
    return;
end

% If record is already single valued, just return it back
dates = double( se.dates );
if min( diff(dates) ) > 0
    sx = se;
    return;
end

% Use blank flags if not specified
if nargin < 2
    bf = [];
end

st = structureMerge( se );
st = mergeCore( st, bf, 'merge_any' );


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
end

