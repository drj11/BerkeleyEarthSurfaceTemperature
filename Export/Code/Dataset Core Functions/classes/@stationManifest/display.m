function display(mn)

ss = struct();

ss.source = stationSourceType( mn.source );
ss.ids = mn.ids;
ss.name = mn.name;
ss.country = subsref( mn, substruct( '.', 'country' ) );
ss.state = mn.state;
ss.county = mn.county;

if ~isnan(mn.duration)
    ss.record_start = subsref( mn, substruct( '.', 'start' ) );
    ss.record_stop = subsref( mn, substruct( '.', 'stop' ) );
end

ss.latitude = subsref( mn, substruct( '.', 'lat' ) );
ss.longitude = subsref( mn, substruct( '.', 'long' ) );
ss.elevation = subsref( mn, substruct( '.', 'elevation' ) );
ss.relocation = mn.reloc;
ss.station_type = mn.station_type;

display( ss );