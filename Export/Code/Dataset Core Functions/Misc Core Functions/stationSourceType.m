function v = stationSourceType( s, reload )
% value = stationSourceType( string )
% string = stationSourceType( value )
% ... = stationSourceType( ..., reload flag )
%
% Accesses the stationSourceType flags.

persistent station_source_list
if nargin < 2
    reload = 0;
end

if isempty( station_source_list ) || reload == 1
    station_source_list = loadStationSourceList();
end

persistent last_source_key last_source_value;
if isa( s, 'char' )
    if strcmp( last_source_key, s )
        v = last_source_value;
        return;
    end
end

v = station_source_list( s );

if isa( s, 'char' )
    last_source_key = s;
    last_source_value = v;
end


function station_source_list = loadStationSourceList
% Main loader, called first time and on reloads.

station_source_list = dictionary();

source_codes = primaryKeyTable( 'station_sources' );

rst = {{'US First Order Summary of the Day', 'USSOD-FO'}
    {'US Cooperative Summary of the Day', 'USSOD-C'}
    {'US Summary of the Day', 'USSOD'}
    {'Global Historical Climatology Network - Daily', 'GHCN-D'}
    {'Global Summary of the Day', 'GSOD'}
    {'Global Historical Climatology Network - Monthly v2', 'GHCN-M'}
    {'Global Historical Climatology Network - Monthly v3', 'GHCN-M v3'}
    {'Scientific Committee on Antarctic Research', 'SCAR'}
    {'Hadley Centre Data Release', 'HadCRU'}
    {'US Cooperative Summary of the Month', 'USSOM'}
    {'US Historical Climatology Network - Monthly', 'USHCN-M'}
    {'US Historical Climatology Network - Daily', 'USHCN-D'}
    {'World Monthly Surface Station Climatology', 'WMSSC'}
    {'GSN Monthly Data', 'GSNMON'}
    {'Monthly Climatic Data of the World', 'MCDW'}
    {'GCOS Monthly CLIMAT Summaries', 'GCOS'}
    {'Multi-network Metadata System', 'MMS'}
    {'World Weather Records', 'WWR'}  
    {'Colonial Archive', 'CA'}
    {'World Meteorological Organization Metadata', 'WMO'}
    
    {'Original Manuscript (from USSOD)', 'USSOD_1'}
    {'SRRS (from USSOD)', 'USSOD_2'}
    {'AFOS (from USSOD)', 'USSOD_3'}
    {'DATSAV (from USSOD)', 'USSOD_4'}
    {'NMC (from USSOD)', 'USSOD_5'}
    {'Foreign Keyed (from USSOD)', 'USSOD_6'}
    {'MAPSO (from USSOD)', 'USSOD_7'}
    {'SRRS "A" / Manuscript "B" (from USSOD)', 'USSOD_8'}
    {'Unknown / Other (from USSOD)', 'USSOD_9'}
    {'ASOS (from USSOD)', 'USSOD_A'}
    
    {'US Cooperative Summary of the Day (from GHCN)', 'GHCN_0'}
    {'US Preliminary Cooperative Summary of the Day, transmitted (from GHCN)', 'GHCN_1'}
    {'US Preliminary Cooperative Summary of the Day, keyed from paper (from GHCN)', 'GHCN_2'}
    {'CDMP Cooperative Summary of the Day (from GHCN)', 'GHCN_6'}
    {'USSOD-C transmitted (from GHCN)', 'GHCN_7'}
    {'ASOS, since 2006  (from GHCN)', 'GHCN_A'}
    {'Australian data from Australian Bureau of Met (from GHCN)', 'GHCN_a'}
    {'ASOS, 2000-2005 (from GHCN)', 'GHCN_B'}
    {'Belarus update (from GHCN)', 'GHCN_b'}
    {'US Fort Data (from GHCN)', 'GHCN_F'}
    {'GCOS or other offical Government Data (from GHCN)', 'GHCN_G'}
    {'High Plains Regional Climate Center (from GHCN)', 'GHCN_H'}
    {'International Collection, personal contacts (from GHCN)', 'GHCN_I'}
    {'USSOD-C paper forms (from GHCN)', 'GHCN_K'}
    {'Monthly METAR Extract (from GHCN)', 'GHCN_M'}
    {'Quarantined African Data (from GHCN)', 'GHCN_Q'}
    {'NCDC Reference Network / USHCN (from GHCN)', 'GHCN_R'}
    {'Global Summary of the Day (from GHCN)', 'GHCN_S'}
    {'US First Order Summary of the Day (from GHCN)', 'GHCN_X'}
    {'Ukraine update (from GHCN)', 'GHCN_u'}
    {'Uzbekistan update (from GHCN)', 'GHCN_z'}

    {'Monthly Climatic Data of the World - Preliminary (from GHCN3)', 'GHCN3_C'}
    {'GHCN-M v2 - Single Valued Series (from GHCN3)', 'GHCN3_G'}
    {'UK Met Office (from GHCN3)', 'GHCN3_K'}
    {'Monthly Climatic Data of the World - Final', 'GHCN3_M'}
    {'Netherlands /KNMI (from GHCN3)', 'GHCN3_N'}
    {'CLIMAT / non-MCDW (from GHCN3)', 'GHCN3_P'}
    {'USHCN v2 (from GHCN3)', 'GHCN3_U'}
    {'World Weather Records (from GHCN3)', 'GHCN3_W'}
    {'Colonial Era Archive (from GHCN3)', 'GHCN3_J'}
    {'Datzilla Manual Assessmet (from GHCN3)', 'GHCN3_Z'}
    {'GHCN-M v2 multiple series 0 (from GHCN3)', 'GHCN3_0'}
    {'GHCN-M v2 multiple series 1 (from GHCN3)', 'GHCN3_1'}
    {'GHCN-M v2 multiple series 2 (from GHCN3)', 'GHCN3_2'}
    {'GHCN-M v2 multiple series 3 (from GHCN3)', 'GHCN3_3'}
    {'GHCN-M v2 multiple series 4 (from GHCN3)', 'GHCN3_4'}
    {'GHCN-M v2 multiple series 5 (from GHCN3)', 'GHCN3_5'}
    {'GHCN-M v2 multiple series 6 (from GHCN3)', 'GHCN3_6'}
    {'GHCN-M v2 multiple series 7 (from GHCN3)', 'GHCN3_7'}
    {'GHCN-M v2 multiple series 8 (from GHCN3)', 'GHCN3_8'}
    {'GHCN-M v2 multiple series 9 (from GHCN3)', 'GHCN3_9'}
    
    {'Data Merged from Multiple Sources', 'Merged'}
    {'Specially Edited Location Record', 'Corrected_Location'}
    {'Composite Record from Averaging Multiple Records', 'Synthesis'}
    {'Duplicate Record of Same Type', 'Duplicate'}

    {'NCDC: US Cooperative Summary of the Day', 'NCDC_3200'}
    {'NCDC: US First Order Summary of the Day', 'NCDC_3210'}
    {'NCDC: US First Order ASOS Summary of the Day', 'NCDC_3211'}
    {'NCDC: CDMP Cooperative Summary of the Day', 'NCDC_3206'}
    {'NCDC: Undocumented Summary of the Day', 'NCDC_3201'}  %?!?!
    {'NCDC: US Cooperative Summary of the Day - Preliminary', 'NCDC_3202'}
    {'NCDC: RCC-Preliminary Summary of the Day', 'NCDC_RCC-'}
    
    };

for k = 1:length(rst)
    v = source_codes( rst{k} );
    f = find( isnan(v) );
    if length(f) == length(rst{k})
        source_codes = add( source_codes, rst{k} );
    elseif ~isempty(f)
        f1 = find( ~isnan(v) );
        if max(v(f1)) ~= min(v(f1))
            error( 'Naming conflict' );
        end
        source_codes = extend( source_codes, v(f1(1)), rst{k}(f) );
    end
    
    for j = 1:length( rst{k} )
        index = source_codes(rst{k}{j});
        station_source_list(rst{k}{j}) = index;
    end
    index = source_codes(rst{k}{1});
    station_source_list( index ) = rst{k}{1};    
end
    

    