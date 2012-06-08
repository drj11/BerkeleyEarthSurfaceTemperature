function v = stationRecordType( c, reload )

persistent record_type_specification
if isempty( record_type_specification ) || (nargin > 1 && reload == 1)
    record_type_specification = loadRecordTypes();
end

persistent last_record_key last_record_value;

if isnumeric( c ) 
    if length( c ) > 1
        v = stationRecordType( c(1) );
        v(length(c)) = v(1);
        for k = 2:length(c)
            v(k) = stationRecordType( c(k) );
        end
        return;
    end
end

if isa( c, 'char' )
    c = lower( c );
    
    if strcmp( last_record_key, c )
        v = last_record_value;
        return
    end
end

try
    v = record_type_specification( c );
catch
    v = NaN;
end

if isa( c, 'char' )
    last_record_key = c;
    last_record_value = v;
end
    
if isempty(v)
    error( 'Type Specification not Found' );
end


function record_type_specification = loadRecordTypes()

rset = {
    {'Maximum Temperature', 'TMAX', 'C'},
    {'Minimum Temperature', 'TMIN', 'C'},
    {'Average Temperature', 'TAVG', 'C'},
    {'Temperature at Observation', 'TOBS', 'C'},
    {'Precipitation', 'PRCP', 'mm'},
    {'Weather Events', 'DYSW', 'Weather Codes'},
    {'Evaporation', 'EVAP', 'mm'},
    {'Minimum Temperature in Water Pan', 'MNPN', 'C'},
    {'Maximum Temperature in Water Pan', 'MXPN', 'C'},
    {'Snowfall', 'SNOW', 'mm'},
    {'Snow Depth', 'SNWD', 'mm'},
    {'Wind Movement', 'WDMV', 'km'},
    {'Water Equivalent of Snow Depth', 'WTEQ', 'mm'},
    {'Average Cloudiness Midnight to Midnight', 'ASMM', '%'},
    {'Average Cloudiness Sunrise to Sunset', 'ASSS', '%'},
    {'Average Wind Speed', 'AWND', 'm / s'},;
    {'Cooling Degree Day (base 18.33 C)', 'CLDG', 'C'},
    {'Heating Degree Day (base 18.33 C)', 'HTDG', 'C'},
    {'Departure from Normal Temperature', 'DPNT', 'C'},
    {'Dew-Point Temperature', 'DPTP', 'C'},
    {'Days with Weather in Vicinity', 'DYVC', 'Weather Codes'},
    {'Fastest 2-min Wind', 'F2MN', 'Wind Speed and Direction'},
    {'Fastest 2-min Wind Speed', 'F2MN-S', 'm / s'},
    {'Fastest 2-min Wind Direction', 'F2MN-D', 'direction'},
    {'Fastest 5-sec Wind', 'F5SC', 'Wind Speed and Direction'},
    {'Fastest 5-sec Wind Speed', 'F5SC-S', 'm / s'},
    {'Fastest 5-sec Wind Direction', 'F5SC-D', 'degrees'},
    {'Time of Fastest Mile', 'FMTM', 'hr'},
    {'Base Depth of Frozen Ground', 'FRGB', 'm'},
    {'Top Depth of Frozen Ground', 'FRGT', 'm'},
    {'Thickness of Frozen Ground', 'FRTH', 'm'},
    {'Fastest Instantaneous Wind', 'FSIN', 'Wind Speed and Direction'},
    {'Fastest Instantaneous Wind', 'FSIN-S', 'm / s'},
    {'Fastest Instantaneous Wind', 'FSIN-D', 'degrees'},
    {'Fastest Mile Wind', 'FSMI', 'Wind Speed and Direction'},
    {'Fastest Mile Wind Speed', 'FSMI-S', 'm / s'},
    {'Fastest Mile Wind Direction', 'FSMI-D', 'degrees'},
    {'Fastest Observed 1-min Wind', 'FSMN', 'Wind Speed and Direction'},
    {'Fastest Observed 1-min Wind Speed', 'FSMN-S', 'm / s'},
    {'Fastest Observed 1-min Wind Direction', 'FSMN-D', 'degrees'},
    {'River Gauge Height', 'GAHT', 'm'},
    {'Minimum Relative Humidity', 'MNRH', '%'},
    {'Maximum Relative Humidity', 'MXRH', '%'},
    {'Mean Temperature (2)', 'MNTP', 'C'},
    {'Peak Gust Time', 'PGTM', 'hr'},
    {'Peak Gust', 'PKGS', 'Wind Speed and Direction'},
    {'Peak Gust Speed', 'PKGS-S', 'km / hr'},
    {'Peak Gust Direction', 'PKGS-D', 'degrees'},
    {'Pressure', 'PRES', 'Pa'},
    {'Percent of Possible Sunshine', 'PSUN', '%'},
    {'Resultant Wind Direction', 'RDIR', 'degrees'},
    {'Resultant Wind Speed', 'RWND', 'm / s'},
    {'Average Cloudiness Midnight to Midnight (2)', 'SAMM', '%'},
    {'Average Cloudiness Sunrise to Sunset (2)', 'SASS', '%'},
    {'Average Sky Cover Midnight to Midnight', 'SCMM', '%'},
    {'Average Sky Cover Sunrise to Sunset', 'SCSS', '%'},
    {'Average Cloudiness Midnight to Midnight (regional)', 'SGMM', '%'},
    {'Average Cloudiness Sunrise to Sunset (regional)', 'SGSS', '%'},
    {'Sea Level Pressure', 'SLVP', 'Pa'},
    {'Average Sky Cover Midnight to Midnight (2)', 'SMMM', '%'},
    {'Average Sky Cover Sunrise to Sunset (2)', 'SMSS', '%'},
    {'Average Sky Cover Sunrise to Sunset', 'SCSS', '%'},
    {'Average Sky Cover Sunrise to Sunset', 'SCSS', '%'},
    {'Average Cloudiness Midnight to Midnight (regional 2)', 'STMM', '%'},
    {'Average Cloudiness Sunrise to Sunset (regional 2)', 'STSS', '%'},
    {'Thickness of Ice on Water', 'THIC', 'mm'},
    {'Wet-Bulb Temperature', 'TMPW', 'C'},
    {'Total Sunshine', 'TSUN', 'hr'},

    {'Prevailing Daily Wind Direction', 'PWND', 'degrees'},
    {'Daily Cloudiness', 'SKYC', 'unknown'}, %units???
    {'Daily Temperature Range', 'TRNG', 'C'},

    {'UNKNOWN DATA TYPE', 'WT00', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT01', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT02', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT03', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT04', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT05', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT06', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT07', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT08', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT09', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT10', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT11', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT12', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT13', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT14', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT15', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT16', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT17', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT18', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT19', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT20', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT21', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT22', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT23', 'unknown'},
    {'UNKNOWN DATA TYPE', 'WT24', 'unknown'},

    {'Visibility', 'VISI', 'km'},
    
    {'Monthly cooling degree days (base 65F)', 'CLDD', 'C-day'},
    {'Monthly heating degree days (base 65F)', 'HTDD', 'C-day'},

    {'Days with >= 0.1 inch precipitation', 'DP01', 'NA'},
    {'Days with >= 3 mm precipitation', 'DP03', 'NA'},
    {'Days with >= 0.5 inch precipitation', 'DP05', 'NA'},
    {'Days with >= 0.01 inch precipitation', 'DP0H', 'NA'},
    {'Days with >= 0.25 inch precipitation', 'DP0Q', 'NA'},
    {'Days with >= 1 inch precipitation', 'DP10', 'NA'},
    {'Days with >= 25 mm precipitation', 'DP25', 'NA'},
    {'Days with >= 50 mm precipitation', 'DP50', 'NA'},

    {'Departure from normal monthly precipitation', 'DPNP', 'mm'},
    {'Departure from normal monthly temperature', 'DPNT', 'C'},
    {'Days with snow depth >= 1 inch', 'DSNW', 'NA'},
    {'Days with min temperature <= 0 F', 'DT00', 'NA'},
    {'Days with max temperature <= 15 C', 'DT15', 'NA'},
    {'Days with max temperature >= 30 C', 'DT30', 'NA'},
    {'Days with min temperature <= 32 F', 'DT32', 'NA'},
    {'Days with min temperature <= 59 F', 'DT60', 'NA'},
    {'Days with max temperature >= 70 F', 'DT70', 'NA'},
    {'Days with max temperature >= 90 F', 'DT90', 'NA'},
    {'Days with max temperature <= 15 C', 'DX15', 'NA'},
    {'Days with max temperature <= 32 F', 'DX32', 'NA'},
    {'Days with max temperature <= 59 F', 'DX60', 'NA'},

    {'Highest precip in month', 'EMXP', 'mm'},
    {'Lowest min temperature in month', 'EMNT', 'C'},
    {'Highest max temperature in month', 'EMXT', 'C'},
    {'Maximum snow depth in month', 'MXSD', 'mm'},

    {'Freeze Dates', 'FRZD', 'Freeze Data'},

    {'Monthly mean minimum temperature of evaporation pan', 'MMNP', 'C'},
    {'Monthly mean minimum temperature', 'MMNT', 'C'},
    {'Monthly mean maximum temperature of evaporation pan', 'MMXP', 'C'},
    {'Monthly mean maximum temperature', 'MMXT', 'C'},
    {'Monthly mean temperature', 'MNTM', 'C'},

    {'Total monthly evaporation', 'TEVP', 'mm'},
    {'Total monthly precipitation', 'TPCP', 'mm'},
    {'Total monthly snowfall', 'TSNW', 'mm'},
    {'Total wind movement', 'TWND', 'km'},
    
    
    };

soils = {0, 'Unknown';
    1, 'Grass';
    2, 'Fallow';
    3, 'Bare Ground';
    4, 'Brome Grasss';
    5, 'Sod';
    6, 'Straw mulch';
    7, 'Grass muck',
    8, 'Bare muck'};

soil_depths = {1, '5 cm';
    2, '10 cm';
    3, '20 cm';
    4, '50 cm';
    5, '100 cm';
    6, '150 cm';
    7, '180 cm';
    0, 'Unknown'};

for k = 1:length(soils)
    for j = 1:length(soil_depths)
        rset{end+1} = ...
            {['Soil Minimum Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['SN' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Soil Maximum Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['SX' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Soil Temperature at Observation in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['SO' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};

        rset{end+1} = ...
            {['Monthly Mean Minimum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['MN' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Highest Minimum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['HN' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Lowest Minimum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['LN' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};

        rset{end+1} = ...
            {['Monthly Mean Soil Temperature at Observation Time in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['MO' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Highest Soil Temperature at Observation Time in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['HO' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Lowest Soil Temperature at Observation Time in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['LO' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};

        rset{end+1} = ...
            {['Monthly Mean Maximum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['MX' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Highest Maximum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['HX' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        rset{end+1} = ...
            {['Lowest Maximum Soil Temperature in ' soils{k,2} ' at ' ...
            soil_depths{j,2} ' Depth'], ...
            ['LX' num2str(soils{k,1}) num2str(soils{j,1})], 'C'};
        
    end
end

for k = 0:24
    rset{end+1} = ...
        {['UNKNOWN Temperature OT' sprintf( '%02i', k ) ], ...
        ['OT' sprintf( '%02i', k )], 'C'};
end

record_keys = primaryKeyTable( 'record_type_keys' );
record_type_specification = dictionary();

index = [];
for k = 1:length(rset)
    index(k) = lookup( record_keys, rset{k}{2} );
    if isnan(index(k))
        record_keys = add( record_keys, rset{k}{2} );
        index(k) = lookup( record_keys, rset{k}{2} );
    end

    rst = struct();
    rst.desc = rset{k}{1};
    rst.abbrev = rset{k}{2};
    rst.units = rset{k}{3};
    rst.index = index(k);
    
    record_type_specification(index(k)) = rst;
    record_type_specification(lower(rset{k}{2})) = rst;
end

                