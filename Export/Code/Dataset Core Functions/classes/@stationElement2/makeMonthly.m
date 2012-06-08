function sx = makeMonthly( se, bad_flags )
% stationElement = makeMonthly( stationElement, bad_flags )
%
% Converts a daily record into a monthly record.
persistent monthly_duplicate_flags monthly_merge_flags;

% error( 'Need to finish updating this' )

if length(se) > 1
    error( 'Can not be called with an array' );
end

if nargin < 2
    bad_flags = [];
end

if se.frequency == stationFrequencyType( 'm' );
    sx = se;
    return;
elseif se.frequency ~= stationFrequencyType( 'd' )
    error( 'Not possible to make monthly.' );
end 

if isMultiValued( se )
    se = makeSingleValued( se, bad_flags );
end

if numItems( se ) == 0
    sx = stationElement2( se.record_type, 'm' );
    return;
end

dv = datevec( double( se.dates ) );                        
monthnum = (dv(:,1) - 1600)*12 + dv(:,2);

st = structureMerge( se );
st.dates = monthnum;
st.frequency = stationFrequencyType( 'm' );

[st, counts] = mergeCore( st, bad_flags, 'average_dissimilar', 0 );
st.num_measurements = counts;

f = find( ~isnan(st.num_measurements) );
if ~isempty(f)
    st.flags(f, end+1) = dataFlags( 'MONTHLY_NUM_DROPPED' );
end

f = find( st.time_of_observation == -1 );
if ~isempty(f)
    st.time_of_observation(f) = NaN;
    st.flags(f, end+1) = dataFlags( 'MONTHLY_TOB_CHANGE' );
end


%Check complete month.
v = zeros(length(st.dates), 3);
v(:,1) = floor( st.dates / 12 - 1/24 + 1600 );
v(:,2) = st.dates - (v(:,1) - 1600)*12;
v(:,3) = 1;

d1 = datenum(v);
v(:,2) = v(:,2) + 1;
f = find(v(:,2) > 12);
v(f,2) = 1;
v(f,1) = v(f,1) + 1;
d2 = datenum(v);

days = d2 - d1;

st.num_measurements = counts;
f = find( counts(:) < days(:) );
if ~isempty(f)
    st.flags(f, end+1) = dataFlags( 'MONTHLY_INCOMPLETE' );
end

f = find( counts(:) < days(:)-9 );
if ~isempty(f)
    st.flags(f, end+1) = dataFlags( 'MONTHLY_HIGHLY_INCOMPLETE' );
end

st.flags(:, end+1) = dataFlags( 'NEW_MONTHLY_AVERAGE' );



% Replace very fine differences with nearest thousandths.  This is useful
% in support of the compression algorithms.
dd = abs(diff( st.data ));
f = ( dd > 1e-7 );
if min(dd(f)) < 0.001
    st.data = round( st.data * 1000 ) / 1000;
    st.uncertainty = round( st.uncertainty * 10000 ) / 10000;
end


sx = class( st, 'stationElement2' );
sx.md5hash = md5hash;

if sx.auto_compress
    sx = compress( sx );
end
