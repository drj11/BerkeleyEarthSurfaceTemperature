function v = matchFlags( s, reload )
% value = matchFlags( flag_string )
% flag_structure = matchFlags( value )
% ... = matchFlags( ..., reload )
%
% Manages the lookup table for match flags.

persistent match_flag_list
if isempty( match_flag_list ) || ( nargin > 1 && reload == 1 )
    match_flag_list = loadMatchFlagList();
end

if nargin == 0
    ks = keys( match_flag_list );
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
        display( [num2str(vs(k)) ' - ' match_flag_list(vs(k))] );
    end
    return
end

persistent match_flag_last match_flag_value;
if isa( s, 'char' )
    if strcmp( match_flag_last, s )
        v = match_flag_value;
        return
    end
end

v = match_flag_list( s );

if isa( s, 'char' )
    match_flag_last = s;
    match_flag_value = v;
end


function match_flag_list = loadMatchFlagList

match_flag_list = dictionary();

flag_codes = primaryKeyTable( 'match_flags' );

rst = {
    {'Manually Approved Match', 'MANUAL_GOOD'}
    {'Manually Rejected Match', 'MANUAL_BAD'}

    {'Algorithm Approved Metadata-Only Match', 'AUTOMATIC_METADATA_MATCH'}
    {'Algorithm Approved Data-Based Match', 'AUTOMATIC_MATCH'}
    {'Transitive Match', 'TRANSITIVE_MATCH'}
    {'Transitive Metadata Match', 'TRANSITIVE_METADATA_MATCH'}
        
    {'Exact match on station name', 'STATION_NAME_MATCH'}    
    {'Partial match on station name', 'PARTIAL_NAME_MATCH'}

    {'Match on country', 'COUNTRY_MATCH'}
    {'Country conflict', 'COUNTRY_CONFLICT'}
       
    {'Match on county', 'COUNTY_MATCH'}
    {'County conflict', 'COUNTY_CONFLICT'}
    
    {'Match on state', 'STATE_MATCH'}
    {'State conflict', 'STATE_CONFLICT'}
    
    {'WMO ID Match', 'WMO_MATCH'}
    {'WMO ID Conflict', 'WMO_CONFLICT'}

    {'WBAN ID Match', 'WBAN_MATCH'}
    {'WBAN ID Conflict', 'WBAN_CONFLICT'}

    {'COOP ID Match', 'COOP_MATCH'}
    {'COOP ID Conflict', 'COOP_CONFLICT'}
    
    {'ICAO ID Match', 'ICAO_MATCH'}
    {'ICAO ID Conflict', 'ICAO_CONFLICT'}

    {'ID Match', 'GENERIC_ID_MATCH'}
    {'ID Crossover Match', 'CROSSOVER_ID_MATCH'}
    {'ID WMO Padded Crossover Match', 'CROSSOVER_PADDED_WMO_MATCH'}

    {'Same Source', 'SAME_SOURCE'}
    {'Different Sources', 'DIFFERENT_SOURCE'}

    {'GSOD Duplicate Match', 'GSOD_DUPLICATE'}

    {'Identical Location', 'IDENTICAL_LOCATION'}
    {'Consistent Locations', 'CONSISTENT_LOCATION'}
    {'Inconsistent Locations', 'INCONSISTENT_LOCATION'}
    
    {'Identical Altitude', 'IDENTICAL_ALTITUDE'}
    {'Consistent Altitude', 'CONSISTENT_ALTITUDE'}
    {'Similar Altitude (+/- 10 m)', 'SIMILAR_ALTITUDE'}
    {'Different Altitude', 'DIFFERENT_ALTITUDE'}

    {'Distance less than 100 m', 'WITHIN_100_M'}
    {'Distance less than 1 km', 'WITHIN_1_KM'}
    {'Distance less than 10 km', 'WITHIN_10_KM'}
    {'Distance less than 50 km', 'WITHIN_50_KM'}
    {'Distance less than 100 km', 'WITHIN_100_KM'}
    {'Distance greater than 10 km', 'MORE_THAN_10_KM'}
    {'Distance greater than 50 km', 'MORE_THAN_50_KM'}
    {'Distance greater than 100 km', 'MORE_THAN_100_KM'}
    
    {'Nearest neighbors', 'NEAREST_NEIGHBOR'}
    {'Nearest neighbors for these sources', 'NEAREST_NEIGHBOR_SOURCE_RESTRICTED'}

    {'TMAX records short overlap', 'TMAX_SHORT_OVERLAP'}
    {'TMAX records don''t overlap', 'TMAX_NO_OVERLAP'}
    {'TMAX records match', 'TMAX_MATCH'}
    {'TMAX records ambiguous', 'TMAX_AMBIGUOUS'}
    {'TMAX records don''t match', 'TMAX_NO_MATCH'}
    
    {'TMIN records short overlap', 'TMIN_SHORT_OVERLAP'}
    {'TMIN records don''t overlap', 'TMIN_NO_OVERLAP'}
    {'TMIN records match', 'TMIN_MATCH'}
    {'TMIN records ambiguous', 'TMIN_AMBIGUOUS'}
    {'TMIN records don''t match', 'TMIN_NO_MATCH'}

    {'TAVG records short overlap', 'TAVG_SHORT_OVERLAP'}
    {'TAVG records don''t overlap', 'TAVG_NO_OVERLAP'}
    {'TAVG records match', 'TAVG_MATCH'}
    {'TAVG records ambiguous', 'TAVG_AMBIGUOUS'}
    {'TAVG records don''t match', 'TAVG_NO_MATCH'}

    {'TOBS records short overlap', 'TOBS_SHORT_OVERLAP'}
    {'TOBS records don''t overlap', 'TOBS_NO_OVERLAP'}
    {'TOBS records match', 'TOBS_MATCH'}
    {'TOBS records ambiguous', 'TOBS_AMBIGUOUS'}
    {'TOBS records don''t match', 'TOBS_NO_MATCH'}

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
        match_flag_list(rst{k}{j}) = index;
    end
    index = flag_codes(rst{k}{1});
    match_flag_list( index ) = rst{k}{1};    
end
    

    