function se = makeEquivalent( se )

persistent station_record_equivalent_map;

if isempty( station_record_equivalent_map )

    map = {'MNTP', 'TAVG';
        'OT07', 'TOBS';
        'OT14', 'TOBS';
        'OT21', 'TOBS';
        'MMXT', 'TMAX';
        'MMNT', 'TMIN';
        'MNTM', 'TAVG'};

    map2 = [];

    for k = 1:length(map(:,1))
        v = stationRecordType( map{k,1} );
        map2(k,1) = v.index;
        v = stationRecordType( map{k,2} );
        map2(k,2) = v.index;
    end
    
    station_record_equivalent_map = map2; 
end

for k = 1:length( station_record_equivalent_map(:,1) ) 
    if se.record_type == station_record_equivalent_map(k,1)
        se.record_type = station_record_equivalent_map(k,2);
    end
end