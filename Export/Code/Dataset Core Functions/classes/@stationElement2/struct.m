function st = struct( se )
% structure = struct( stationElement )
%
% Provides a decompressed structure respresentation of the stationElement

se = decompress( se );
st = builtin( 'struct', se );

for k = 1:length(st)
    st(k).time_of_observation = double( se(k).time_of_observation );
    f = ( st(k).time_of_observation == 255 );
    st(k).time_of_observation(f) = NaN;
    
    st(k).num_measurements = double( se(k).num_measurements );
    f = ( st(k).num_measurements == 65535 );
    st(k).num_measurements(f) = NaN;
    
    s = size( st(k).flags );
    if s(1) == 0
        st(k).flags(1:length(data),1) = 0;
    end    
end