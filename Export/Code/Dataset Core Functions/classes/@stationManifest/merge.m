function mn = merge( mn1, mn2 )

mn = mn1;

if mn1.source ~= mn2.source
    error( 'Sources do not match' );
else
    mn.source = mn1.source;
end

if mn1.country ~= mn2.country
    if mn1.country == 0
        mn.country = mn2.country;
    elseif mn2.country == 0
        mn.country = mn1.country;
    else
        error( 'Countries do not match' );
    end
else
    mn.country = mn1.country;
end

if isnan( mn1.state )
    mn1.state == '';
end
if isnan( mn2.state )
    mn2.state == '';
end

if ~strcmp( mn1.state, mn2.state )
    if strcmp( mn1.state, '' );
        mn.state = mn2.state;
    elseif strcmp( mn2.state, '' );
        mn.state = mn1.state;
    else
        error( 'States do not match' );
    end
else
    mn.state = mn1.state;
end

if isnan( mn1.county )
    mn1.county == '';
end
if isnan( mn2.county )
    mn2.county == '';
end

if ~strcmp( mn1.county, mn2.county )
    if strcmp( mn1.county, '' );
        mn.county = mn2.county;
    elseif strcmp( mn2.county, '' );
        mn.county = mn1.county;
    else
        error( 'Counties do not match' );
    end
else
    mn.county = mn1.county;
end

dur1 = mn1.duration;
dur2 = mn2.duration;

if isa( dur1, 'timeRange' ) && isa( dur2, 'timeRange' )
    if dur1.last_instant == dur2.first_instant
        mn.duration = timeRange( dur1.first_instant, dur2.last_instant );
        if ~strcmp( mn2.reloc, '' )
            error( 'Can''t merge on relocation' );
        end        
    elseif dur1.first_instant == dur2.last_instant
        mn.duration = timeRange( dur2.first_instant, dur1.last_instant );
        if ~strcmp( mn1.reloc, '' )
            error( 'Can''t merge on relocation' );
        else
            mn.reloc = mn2.reloc;
        end
    elseif dur1.first_instant == dur2.first_instant && ...
            dur1.last_instant == dur2.last_instant
        mn.duration = dur1;
        if ~strcmp( mn1.reloc, mn2.reloc )
            error( 'Can''t merge on relocation' );
        end
    else
        error( 'Can''t reconcile time ranges.' );
    end
elseif isa( dur1, 'timeRange' ) || isa( dur2, 'timeRange' )
    error( 'Absent Time Range');
else
    mn.duration = mn1.duration;
end

if mn1.alt_elevation ~= mn2.alt_elevation
    if isnan( mn1.alt_elevation )
        mn.alt_elevation = mn2.alt_elevation;
        mn.alt_elevation_type = mn2.alt_elevation_type;
    elseif isnan( mn2.alt_elevation )
        mn.alt_elevation = mn1.alt_elevation;
        mn.alt_elevation_type = mn1.alt_elevation_type;
    else
        error( 'Alt elevations do not match' );
    end
else
    mn.alt_elevation = mn1.alt_elevation;
    mn.alt_elevation = mn1.alt_elevation_type;
end

if mn1.time_zone ~= mn2.time_zone
    if isnan( mn1.time_zone )
        mn.time_zone = mn2.time_zone;
    elseif isnan( mn2.time_zone )
        mn.time_zone = mn1.time_zone;
    else
        error( 'Time zones do not match' );
    end
else
    mn.time_zone = mn1.time_zone;
end

pos1 = mn1.location;
pos2 = mn2.location;

if pos1.lat ~= pos2.lat || pos1.long ~= pos2.long
    if isnan( pos1.lat ) || isnan( pos1.long )
        lat = pos2.lat;
        long = pos2.long;
    elseif isnan( pos2.lat ) || isnan( pos2.long )
        lat = pos1.lat;
        long = pos1.long;
    else
        error( 'Locations do not match' );
    end
else
    lat = pos1.lat;
    long = pos1.long;
end
 
if pos1.elev ~= pos2.elev
    if isnan( pos1.elev )
        elev = pos2.elev;
    elseif isnan( pos2.elev )
        elev = pos1.elev;
    else
        error( 'Altitudes do not match' );
    end
else
    elev = pos1.elev;
end

mn.location = geoPoint( lat, long, elev );

if isnan( mn1.station_type )
    mn1.station_type == '';
end
if isnan( mn2.station_type )
    mn2.station_type == '';
end

if ~strcmp( mn1.station_type, mn2.station_type )
    if strcmp( mn1.station_type, '' );
        mn.station_type = mn2.station_type;
    elseif strcmp( mn2.station_type, '' );
        mn.station_type = mn1.station_type;
    else
        error( 'Station types do not match' );
    end
else
    mn.station_type = mn1.station_type;
end

if mn1.location_precision ~= mn2.location_precision
    if isnan( mn1.location_precision )
        mn.location_precision = mn2.location_precision;
    elseif isnan( mn2.location_precision )
        mn.location_precision = mn1.location_precision;
    else
        error( 'Location precision do not match' );
    end
else
    mn.location_precision = mn1.location_precision;
end

ids1 = mn1.ids;
ids2 = mn2.ids;

if sum( ismember( ids1, ids2 ) ) == length( ids1 )
    mn.ids = ids2;
elseif sum( ismember( ids2, ids1 ) ) == length( ids2 )
    mn.ids = ids1;
else
    error( 'IDs are not super/subset related' );
end

names1 = mn1.name;
names2 = mn2.name;

if sum( ismember( names1, names2 ) ) == length( names1 )
    mn.name = names2;
elseif sum( ismember( names2, names1 ) ) == length( names2 )
    mn.name = names1;
else
    error( 'Names are not super/subset related' );
end


