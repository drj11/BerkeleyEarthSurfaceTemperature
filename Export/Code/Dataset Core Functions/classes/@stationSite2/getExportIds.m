function res = getExportIds( sites )
% Retrieves unique export ids for each site.  This is based on the archive
% keys and a unique assignment table.

temperatureGlobals;
persistent station_id_codes station_id_counter

psep = filesep();

if isempty( station_id_codes )
    try
        load( [temperature_data_dir 'Export ID Codes' psep 'export_id_assignments'] );
    catch
        station_id_codes = dictionary();
        station_id_counter = 0;
        checkPath( [temperature_data_dir 'Export ID Codes' psep 'export_id_assignments'] );
        error( 'Export ID Data Missing' );
    end
end

organize = zeros(length(sites), 3);
for k = 1:length(sites)
    organize(k, :) = [sites(k).country(1), sites(k).location.latitude, sites(k).location.longitude];
end
[~,I] = sortrows( organize );
sites = sites(I);

saves = 0;
res = zeros( length(sites), 1 );
for k = 1:length(sites)
    if isempty( sites(k).archive_keys )
        code2 = num2str( md5hash( sites(k).ids ) );
    else
        code2 = num2str( md5hash( char( sites(k).archive_keys ) ) );
    end
    
    try
        index = station_id_codes( code2 );
    catch
        disp( 'Allocating new code' );
        station_id_codes( code2 ) = station_id_counter + 1;
        
        station_id_counter = station_id_counter + 1;
        index = station_id_counter;
        saves = 1;
    end
    
    res(k) = index;
end

res(I) = res;

if saves == 1
   save( [temperature_data_dir 'Export ID Codes' psep 'export_id_assignments'],...
       'station_id_codes', 'station_id_counter' );
end
    