function v = dataFlags( s, reload )
% value = dataFlags( flag_string )
% flag_structure = dataFlags( value )
% ... = dataFlags( ..., reload )
%
% Manages the lookup table for data flags.

persistent data_flag_list
if isempty( data_flag_list ) || ( nargin > 1 && reload == 1 )
    data_flag_list = loadDataFlagList();
end

if nargin == 0
    ks = keys( data_flag_list );
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
        display( [num2str(vs(k)) ' - ' data_flag_list(vs(k))] );
    end
    return
end

persistent data_flag_last data_flag_value;
if isa( s, 'char' )
    if strcmp( data_flag_last, s )
        v = data_flag_value;
        return
    end
end

try
    v = data_flag_list( s );
catch
    if isnumeric( s )
        v = ['Unknown Flag - ' num2str( s )];
    else
        error( ['Unknown Flag - ' s] );
    end
end
    
if isa( s, 'char' )
    data_flag_last = s;
    data_flag_value = v;
end


function data_flag_list = loadDataFlagList

data_flag_list = dictionary();

flag_codes = primaryKeyTable( 'data_flags' );

rst = {
    {'USSOD: Accumulated Amount', 'USSOD_A'}
    {'USSOD: Accumulated Amount (includes estimated values)', 'USSOD_B'}
    {'USSOD: Derived Value', 'USSOD_D'}
    {'USSOD: Estimated Value', 'USSOD_E'}
    {'USSOD: Value manually validated', 'USSOD_J'}
    {'USSOD: Data Element Missing', 'USSOD_M'}
    {'USSOD: Multiple Concurrent Peak Gust', 'USSOD_P'}
    {'USSOD: Included in Subsequent Value', 'USSOD_S'}
    {'USSOD: Trace Precipitation', 'USSOD_T'}
    {'USSOD: Expert system edited value, not validated', 'USSOD_('}
    {'USSOD: Expert system approved edited value', 'USSOD_)'}
    {'USSOD: UNKNOWN FLAG & !!', 'USSOD_&'}
    {'USSOD: UNKNOWN FLAG - !!', 'USSOD_-'}

    {'USSOD: Valid data element', 'USSOD_C2_0'}
    {'USSOD: Valid data element (from unknown source)', 'USSOD_C2_1'}
    {'USSOD: Invalid data element (subsequent value replacement)', 'USSOD_C2_2'}
    {'USSOD: Invalid data element (no replacement)', 'USSOD_C2_3'}
    {'USSOD: Validity unknown', 'USSOD_C2_4'}
    {'USSOD: Non-numeric data value replaced by its deciphered numeric value', 'USSOD_C2_5'}
    {'USSOD: Substituted TOBS for TMAX or TMIN', 'USSOD_C2_A'}
    {'USSOD: Time shifted value', 'USSOD_C2_B'}
    {'USSOD: Precipitation estimated from snowfall', 'USSOD_C2_C'}
    {'USSOD: Transposed digits', 'USSOD_C2_D'}
    {'USSOD: Changed units', 'USSOD_C2_E'}
    {'USSOD: Adjusted TMAX or TMIN by a multiple of + or -10 degrees', 'USSOD_C2_F'}
    {'USSOD: Changed algebraic sign', 'USSOD_C2_G'}
    {'USSOD: Moved decimal point', 'USSOD_C2_H'}
    {'USSOD: Rescaling other than F, G, or H', 'USSOD_C2_I'}
    {'USSOD: Subjectively derived value', 'USSOD_C2_J'}
    {'USSOD: Extracted from an accumulated value', 'USSOD_C2_K'}
    {'USSOD: Switched TMAX and/or TMIN', 'USSOD_C2_L'}
    {'USSOD: Switched TOBS with TMAX or TMIN', 'USSOD_C2_M'}
    {'USSOD: Substitution of 3 nearest station mean', 'USSOD_C2_N'}
    {'USSOD: Switched snow and precipitation data value', 'USSOD_C2_O'}
    {'USSOD: Added snowfall to snow depth', 'USSOD_C2_P'}
    {'USSOD: Switched snowfall and snow depth', 'USSOD_C2_Q'}
    {'USSOD: Precipitation not reported; estimated as "O"', 'USSOD_C2_R'}
    {'USSOD: Manually edited value', 'USSOD_C2_S'}
    {'USSOD: Failed internal consistency check', 'USSOD_C2_T'}
    {'USSOD: Failed areal consistency check', 'USSOD_C2_U'}
    {'USSOD: Replacement value based on TempVal QC process', 'USSOD_C2_V'}
    {'USSOD: Failed objective spatial tests, manually assessed as valid', 'USSOD_C2_V_CDMP'}
    {'USSOD: Data element passed through MCCDP QC', 'USSOD_C2_6'}
    {'USSOD: Value in MCCDP verifies, estimated value in TD-3200', 'USSOD_C2_7'}
    {'USSOD: Estimated value from Michigan quality control', 'USSOD_C2_8'}
    {'USSOD: Value shifted by a day (prior Z)', 'USSOD_C2_9'}
    {'USSOD: Failed spatial tests, assessed as plausible', 'USSOD_C2_W'}
    {'USSOD: Failed spatial tests, assessed as questionable', 'USSOD_C2_X'}
    {'USSOD: Failed spatial tests, assessed as invalid', 'USSOD_C2_Y'}
    {'USSOD: Value shifted by a day', 'USSOD_C2_Z'}
    {'USSOD: UNKNOWN FLAG C2-& !!', 'USSOD_C2_&'}

    {'USSOD: Passed consistency checks', 'USSOD_F2_0'}
    {'USSOD: Unknown validity', 'USSOD_F2_1'}
    {'USSOD: Consistency check failed (replacement value follows)', 'USSOD_F2_2'}
    {'USSOD: Consistency check failed (no replacement)', 'USSOD_F2_3'}
    {'USSOD: Data invalid (no replacement)', 'USSOD_F2_4'}
    {'USSOD: Data from TD-9750 exceeds climate extremes', 'USSOD_F2_5'}
    {'USSOD: Failed an internal consistency check but valid under manual inspection', 'USSOD_F2_A'}
    {'USSOD: Wind direction code is invalid', 'USSOD_F2_D'}
    {'USSOD: Edited data passes system checks', 'USSOD_F2_E'}
    {'USSOD: Manually edited value', 'USSOD_F2_S'}

    {'GSOD: Temperature extreme derived from hourly data', 'GSOD_*'}
    {'GSOD: 1 report of 6-hour precipitation amount', 'GSOD_A'}
    {'GSOD: Sum of 2 reports of 6-hour precipitation amount', 'GSOD_B'}
    {'GSOD: Sum of 3 reports of 6-hour precipitation amount', 'GSOD_C'}
    {'GSOD: Sum of 4 reports of 6-hour precipitation amount', 'GSOD_D'}
    {'GSOD: 1 report of 12-hour precipitation amount', 'GSOD_E'}
    {'GSOD: Sum of 2 reports of 12-hour precipitation amount', 'GSOD_F'}
    {'GSOD: 1 report of 24-hour precipitation amount', 'GSOD_G'}
    {'GSOD: Report conflict, zero daily total reported with non-zero hourly', 'GSOD_H'}
    {'GSOD: Station did not report any hourly or daily precipitation, but still possible some occurred', 'GSOD_I'}
    
    {'GHCN-D: Precipitation total formed from two 12-hour totals', 'GHCN_MB'}
    {'GHCN-D: Precipitation total formed from four six-hour totals', 'GHCN_MD'}
    {'GHCN-D: Converted from knots', 'GHCN_MK'}
    {'GHCN-D: Temperature appears to be lagged from reported hour of observation', 'GHCN_ML'}
    {'GHCN-D: Converted from oktas', 'GHCN_MO'}
    {'GHCN-D: Trace of precipitation, snowfall, or snow depth', 'GHCN_MT'}
    {'GHCN-D: Converted from 16-point WBAN code', 'GHCN_MW'}
    {'GHCN-D: Failed accumulation total check', 'GHCN_QA'}
    {'GHCN-D: Failed duplicate check', 'GHCN_QD'}
    {'GHCN-D: Failed gap check', 'GHCN_QG'}
    {'GHCN-D: Failed internal consistency check', 'GHCN_QI'}
    {'GHCN-D: Failed streak/frequent-value check', 'GHCN_QK'}
    {'GHCN-D: Failed length of multi-day period check', 'GHCN_QL'}
    {'GHCN-D: Failed megaconsistency check', 'GHCN_QM'}
    {'GHCN-D: Failed naught check', 'GHCN_QN'}
    {'GHCN-D: Failed climatological outlier check', 'GHCN_QO'}
    {'GHCN-D: Failed lagged range check', 'GHCN_QR'}
    {'GHCN-D: Failed spatial consistency check', 'GHCN_QS'}
    {'GHCN-D: Failed temporal consistency check', 'GHCN_QT'}
    {'GHCN-D: Temperature too warm for snow', 'GHCN_QW'}
    {'GHCN-D: Failed bounds check', 'GHCN_QX'}

    {'USSOM: Accumulated Amount', 'USSOM_A'}
    {'USSOM: Adjusted Total Based on Scaling over Missing Days', 'USSOM_B'}
    {'USSOM: Estimated Value', 'USSOM_E'}
    {'USSOM: 1 to 9 Days Missing', 'USSOM_I'}
    {'USSOM: Data Element Missing', 'USSOM_M'}
    {'USSOM: Included in Subsequent Value', 'USSOM_S'}
    {'USSOM: Trace Precipitation', 'USSOM_T'}
    {'USSOM: Occurred Over Several Days', 'USSOM_+'}

    {'USSOM: Accumulated Amount', 'USSOM_2_A'}
    {'USSOM: Estimated Value', 'USSOM_2_E'}
    {'USSOM: Occurred Over Several Days', 'USSOM_2_+'}

    {'USHCN-M: Estimated from surrounding values; no original', 'USHCN-M_E'}
    {'USHCN-M: 1 to 9 Days Missing', 'USHCN-M_I'}
    {'USHCN-M: Estimated from surrounding values; original failed quality check', 'USHCN-M_Q'}
    {'USHCN-M: Estimated from surrounding values; original missing too many days', 'USHCN-M_X'}
    
    {'GHCN-M3: Duplicated annual series', 'GHCN-M3_D'}
    {'GHCN-M3: Internal consistency fail', 'GHCN-M3_I'}
    {'GHCN-M3: Isolated temperature report', 'GHCN-M3_L'}
    {'GHCN-M3: Manually flagged as erroneous', 'GHCN-M3_M'}
    {'GHCN-M3: Outlier value', 'GHCN-M3_O'}
    {'GHCN-M3: Spatial consistency fail', 'GHCN-M3_S'}
    {'GHCN-M3: Temporal consistency fail', 'GHCN-M3_T'}
    {'GHCN-M3: Duplicated monthly value', 'GHCN-M3_W'}
    {'GHCN-M3: Removed by pairwise homogeneity', 'GHCN-M3_X'}

    {'Pre-existing bad flag', 'NEW_1'}
    {'Exceeds climate extreme', 'NEW_2'}
    {'Failed duplicate check', 'NEW_3'}
    {'Failed frame shift check', 'NEW_4'}
    {'Failed frequent value check', 'NEW_5'} % not used
    {'Failed second derivative check', 'NEW_6'}
    {'Failed climatological outlier check', 'NEW_7'}
    {'Failed TMAX > TMIN', 'NEW_8'}
    {'Failed TMAX >= observed T >= TMIN', 'NEW_9'}
    {'Perceived Unit Reporting Error Corrected', 'NEW_10'}
    {'Local Envelope Exceeded', 'NEW_11'}
    {'Preliminary derivative flag recinded', 'NEW_12'}
    {'Preliminary outlier flag recinded', 'NEW_13'}

    % Merge Codes: Daily
    {'Daily values combined via merge', 'DAILY_MULTIPLE_VALUES_MERGED'}
    {'Consistent daily values combined via merge', 'DAILY_CONSISTENT_VALUES_MERGED'}
    {'Multiple daily values of same type combined via average', 'DAILY_AVERAGED_SIMILAR_VALUES'}
    {'Multiple daily values of dissimilar type combined via average', 'DAILY_AVERAGED_DISSIMILAR_VALUES'}
    {'Duplicate daily values combined', 'DAILY_DUPLICATES_REMOVED'}    

    {'Average of daily values was constructed with fewer terms than expected', 'DAILY_AVERAGE_MISSING_VALUES'}
    {'Merger / average of daily values dropped terms with bad flags', 'DAILY_MERGER_BAD_FLAGGED_VALUE_DROPPED'}
    {'Merger / average of daily values provided conflicting number of measurements', 'DAILY_MERGER_CONFLICT_NUM'}
    {'Merger / average of daily values provided conflicting times of observation', 'DAILY_MERGER_CONFLICT_TOB'}
    {'Merger / average found time of observation for some but not all daily values', 'DAILY_MERGER_ESTIMATED_TOB'}
    {'Merger / average found number of measurements for some but not all daily values', 'DAILY_MERGER_ESTIMATED_NUM'}
    {'Merger of daily values found they were consistent within stated precision / uncertainty', 'DAILY_MERGED_CONSISTENT'}
    {'Merger included daily values that were inconsistent within the stated precision / uncertainty', 'DAILY_MERGED_INCONSISTENT'}
    {'Average was constructed from daily values that where inconsistent within the stated precision / uncertainty', 'DAILY_AVERAGED_INCONSISTENT'}

    {'Based on an average of multiple daily records', 'DAILY_AVERAGE_VALUE'}
    {'New daily TAVG constructed from average (TMAX + TMIN) / 2', 'DAILY_AVERAGE_MAX_MIN'}
    {'New daily TAVG constructed from three synoptc observations', 'DAILY_AVERAGE_TRIPLE'}        

    % Merge Codes: Monthly
    {'Monthly values combined via merge', 'MONTHLY_MULTIPLE_VALUES_MERGED'}
    {'Consistent monthly values combined via merge', 'MONTHLY_CONSISTENT_VALUES_MERGED'}
    {'Multiple monthly values of same type combined via average', 'MONTHLY_AVERAGED_SIMILAR_VALUES'}
    {'Multiple monthly values of dissimilar type combined via average', 'MONTHLY_AVERAGED_DISSIMILAR_VALUES'}
    {'Duplicate monthly values combined', 'MONTHLY_DUPLICATES_REMOVED'}    

    {'Average of monthly values was constructed with fewer terms than expected', 'MONTHLY_AVERAGE_MISSING_VALUES'}
    {'Merger / average of monthly values dropped terms with bad flags', 'MONTHLY_MERGER_BAD_FLAGGED_VALUE_DROPPED'}
    {'Merger / average of monthly values provided conflicting number of measurements', 'MONTHLY_MERGER_CONFLICT_NUM'}
    {'Merger / average of monthly values provided conflicting times of observation', 'MONTHLY_MERGER_CONFLICT_TOB'}
    {'Merger / average found time of observation for some but not all monthly values', 'MONTHLY_MERGER_ESTIMATED_TOB'}
    {'Merger / average found number of measurements for some but not all monthly values', 'MONTHLY_MERGER_ESTIMATED_NUM'}
    {'Merger of monthly values found they were consistent within stated precision / uncertainty', 'MONTHLY_MERGED_CONSISTENT'}
    {'Merger included monthly values that were inconsistent within the stated precision / uncertainty', 'MONTHLY_MERGED_INCONSISTENT'}
    {'Average was constructed from monthly values that where inconsistent within the stated precision / uncertainty', 'MONTHLY_AVERAGED_INCONSISTENT'}

    {'Based on an average of multiple monthly records', 'MONTHLY_AVERAGE_VALUE'}
    {'New monthly TAVG constructed from average (TMAX + TMIN) / 2', 'MONTHLY_AVERAGE_MAX_MIN'}
    {'New monthly TAVG constructed from three synoptc observations', 'MONTHLY_AVERAGE_TRIPLE'}        
    
    
    {'New Monthly Average from Daily Values', 'NEW_MONTHLY_AVERAGE'}
    {'Month had change in time of observation', 'MONTHLY_TOB_CHANGE'}
    {'Number of hourly observations hidden in monthly average', 'MONTHLY_NUM_DROPPED'}
    {'Month included multi-valued days', 'MONTHLY_INCLUDED_DUPLICATES'}
    {'Month included merged daily records', 'MONTHLY_INCLUDED_MERGES'}
    {'Days missing from monthly average', 'MONTHLY_INCOMPLETE'}
    {'10 or More days missing from monthly average', 'MONTHLY_HIGHLY_INCOMPLETE'}
    {'Dropped one or more values flagged as bad', 'MONTHLY_BAD_FLAGGED_VALUE_DROPPED'}

    {'New Monthly Average from Daily Values', 'NEW_ANNUAL_AVERAGE'}
    {'Year had change in time of observation', 'ANNUAL_TOB_CHANGE'}
    {'Number of daily observations hidden in yearly average', 'ANNUAL_NUM_DROPPED'}
    {'Year included multi-valued months', 'ANNUAL_INCLUDED_DUPLICATES'}
    {'Month included merged monthly records', 'ANNUAL_INCLUDED_MERGES'}
    {'Months missing from annual average', 'ANNUAL_INCOMPLETE'}    

    {'Indicates a low-resolution source when high-resolution is also available', 'FROM_LOWER_RESOLUTION'}    
    
    {'Original data was C, whole degrees', 'FROM_C_WHOLE'}
    {'Original data was C, tenths of degree', 'FROM_C_TENTH'}
    {'Original data was C, hundreths of degree', 'FROM_C_HUNDRETH'}
    {'Original data was F, whole degrees', 'FROM_F_WHOLE'}
    {'Original data was F, tenths of degree', 'FROM_F_TENTH'}
    {'Original data was F, hundreths of degree', 'FROM_F_HUNDRETH'}

    {'Number of observations estimated from percentage', 'NUM_ESTIMATED'}

    {'Number of observations estimated from percentage', 'EMPIRICAL_PRECISION'}

    {'Temporally isolated value', 'ISOLATED_VALUE'}

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
        data_flag_list(rst{k}{j}) = index;
    end
    index = flag_codes(rst{k}{1});
    data_flag_list( index ) = rst{k}{1};    
end
    

    