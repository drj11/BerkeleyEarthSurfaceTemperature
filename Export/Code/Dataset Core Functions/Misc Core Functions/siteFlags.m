function v = siteFlags( s, reload )

persistent site_flag_list;
if isempty( site_flag_list ) || ( nargin > 1 && logical( reload ) )
    site_flag_list = loadSiteFlagList();
end

if nargin == 0
    ks = keys( site_flag_list );
    vs = [];
    for k = 1:length(ks)
        val = str2num( ks{k} );
        if isempty(val)
            continue;
        end
        vs(end+1) = val;
    end
    vs = sort(vs);
    for k = 1:length(vs)        
        display( [num2str(vs(k)) ' - ' site_flag_list(vs(k))] );
    end
    return
end

persistent site_flag_last site_flag_value;
if isa( s, 'char' )
    if strcmp( site_flag_last, s )
        v = site_flag_value;
        return
    end
end

v = site_flag_list( s );

if isa( s, 'char' )
    site_flag_last = s;
    site_flag_value = v;
end


function site_flag_list = loadSiteFlagList

site_flag_list = dictionary();

flag_codes = primaryKeyTable( 'site_flags' );

rst = {
    {'Station is known to have been relocated', 'RELOCATED'}
    {'Changing location with time suggests possible relocation', 'POSSIBLE_RELOCATION'}
    {'Conflicting locations from different sources', 'LOCATION_CONFLICT'}
    {'Station location conflict greater than 15 km', 'LARGE_LOCATION_CONFLICT'}
    {'Station location conflict greater than 100 km', 'EXTREME_LOCATION_CONFLICT'}
    
    {'Multiple sources reported this site', 'MULTIPLE_SOURCES'}
    {'Multiple names associated with this site', 'MULTIPLE_NAMES'}
   
    {'Site includes daily data reports', 'DAILY_DATA'}
    {'Site includes monthly data with no daily analog', 'UNIQUE_MONTHLY_DATA'}
    
    {'Site has country identification conflict', 'COUNTRY_CONFLICT'}
    {'Site has no country identification', 'MISSING_COUNTRY'}
    {'Country name was remapped', 'COUNTRY_REMAP'}
    {'Site has state identification conflict', 'STATE_CONFLICT'}
    {'Site has county identification conflict', 'COUNTY_CONFLICT'}
    
    {'Site is more than 10 km from land', 'MARINE'}
    {'Site is more than 100 km from land', 'ISOLATED_MARINE'}
    {'Site is more than 10 km from water', 'INLAND'}
    {'Site is more than 100 km from water', 'ISOLATED INLAND'}
    
    {'Site elevation concern: > 10 m and < 100 m from topographic expectation', 'ELEVATION_QUESTIONED'}
    {'Site elevation probably wrong: > 100 m from topographic expectation', 'ELEVATION_BAD'}
    
    {'Site in top 10% of surrounding 100 km^2', 'LOCAL_HIGH'}
    {'Site in bottom 10% of surrounding 100 km^2', 'LOCAL_LOW'}

    {'Part of the US Climate Reference Network', 'US_CRN'}
    {'Part of the US Historical Climate Network', 'US_HCN'}
    {'Part of the Global Climate Observing System', 'GCOS'}

    {'Composite Record Created by the USHCN', 'USHCN_COMPOSITE'}    

    {'Source Archive had no Metadata', 'MISSING_SITE'}        
    {'No location data', 'MISSING_LOCATION'}        
    {'Metadata for Missing Site found in Alternative Archive', 'MISSING_SITE_ALTERNATIVE_FOUND'}        
    {'Site Partially based on Supplemental Records', 'SUPPLEMENTAL_RECORDS'}        

    {'Station record was manually corrected', 'EDITED_RECORD'}        

    };
    
for k = 1:length(rst)
    v = flag_codes( rst{k} );
    f = find( isnan(v) );
    if length(f) == length(rst{k})
        flag_codes = add( flag_codes, rst{k} );
    elseif ~isempty(f)
        f1 = find( ~isnan(v) );
        if max(v(f1)) ~= min(v(f1))
            error( 'Naming conflict' );
        end
        flag_codes = extend( flag_codes, v(f1(1)), rst{k}(f) );
    end
    
    for j = 1:length( rst{k} )
        index = flag_codes(rst{k}{j});
        site_flag_list(rst{k}{j}) = index;
    end
    index = flag_codes(rst{k}{1});
    site_flag_list( index ) = rst{k}{1};    
end
    

    