function display(mn)

if length(mn) > 1
    disp( [num2str(length(mn)), ' StationManifests']);
    return;
end

ss = struct();

if ~isnan( mn.source )
    ss.source = stationSourceType( mn.source );
else
    ss.source = 'None';
end
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

disp( ss );