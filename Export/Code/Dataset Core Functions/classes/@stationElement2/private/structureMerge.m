function st = structureMerge( se )
% structure = structureMerge( stationElement )
%
% Creates a structure that merges the passed array of stationElements

st = struct( se(1) );
if length(se) == 1
    return;
end
st(length(se)) = st;

for k = 2:length(se)
    st(k) = struct( se(k) );
end

st(1).record_type = unique( [st.record_type] );
st(1).frequency = unique( [st.frequency] );
st(1).primary_record_ids = unique( [st.primary_record_ids] );
st(1).record_flags = unique( [st.record_flags] );
st(1).md5hash = md5hash;

st(1).dates = vertcat( st.dates );
st(1).data = vertcat( st.data );
st(1).num_measurements = vertcat( st.num_measurements );
st(1).time_of_observation = vertcat( st.time_of_observation );
st(1).uncertainty = vertcat( st.uncertainty );

st(1).auto_compress = min( [st.auto_compress] );

% Stack flags
s = zeros( length(se), 2);
for k = 1:length(se)
    s(k,:) = size( st(k).flags );
end
flags = zeros( sum(s(:,1)), max(s(:,2)) );

cs = cumsum(s(:,1));
cs = [0; cs];
for k = 1:length(se)
    flags( cs(k)+1:cs(k+1), 1:s(k,2) )  = st(k).flags;
end
st(1).flags = flags;

% Stack source
s = zeros( length(se), 2);
for k = 1:length(se)
    s(k,:) = size( st(k).source );
end
source = zeros( sum(s(:,1)), max(s(:,2)) );

cs = cumsum(s(:,1));
cs = [0; cs];
for k = 1:length(se)
    source( cs(k)+1:cs(k+1), 1:s(k,2) )  = st(k).source;
end
st(1).source = source;

% Pick of just the first one
st = st(1);

% Sort the structure
[~,I] = sort( st.dates );

st.dates = st.dates(I);
st.data = st.data(I);
st.uncertainty = st.uncertainty(I);
st.num_measurements = st.num_measurements(I);
st.time_of_observation = st.time_of_observation(I);
st.source = st.source(I);
st.flags = st.flags(I);
