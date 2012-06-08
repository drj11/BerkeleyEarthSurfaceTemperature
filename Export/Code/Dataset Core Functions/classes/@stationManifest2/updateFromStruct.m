function mn = updateFromStruct( mn, mns )
% Updates stationManifest using specially structured data.  Used for making
% manual corrections to stationManifest records.

if length(mn) > 1 || length(mns) > 1
    error( 'Only one record at a time' );
end

f = fieldnames( mns );

old_pt = mn.location;
latitude = old_pt.lat;
longitude = old_pt.long;
elevation = old_pt.elev;
lat_unc = old_pt.lat_unc;
long_unc = old_pt.long_unc;
elev_unc = old_pt.elev_unc;

for k = 1:length(f)
    if isfield( struct(mn), f{k} )
        mn.(f{k}) = mns.(f{k});
    end
    
    switch f{k}
        case {'latitude', 'lat'}
            latitude = mns.(f{k});
        case {'longitude', 'long'}
            longitude = mns.(f{k});
        case {'elevation', 'elev'}
            elevation = mns.(f{k});
        case {'lat_unc', 'latitude_uncertainty'}
            lat_unc = mns.(f{k});
        case {'long_unc', 'longitude_uncertainty'}
            long_unc = mns.(f{k});
        case {'elev_unc', 'elevation_uncertainty'}
            elev_unc = mns.(f{k});
    end
end

mn.location = geoPoint2( latitude, longitude, elevation, lat_unc, long_unc, elev_unc );

mn.site_flags(end+1) = siteFlags( 'EDITED_RECORD' );
mn.site_flags = unique( mn.site_flags );

mn.source = stationSourceType( 'Corrected_Location' );
mn.original_line = ['Manually corrected record replacing "' mn.hash.hash '"' ];

mn.hash = computeHash( mn );

