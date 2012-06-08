function se = processGSODDataString( se, strs )

global GSOD_flag_reference 
if isempty(GSOD_flag_reference)
    GSOD_flag_reference = zeros(256,2);
end

global element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

global GSOD_data_unit_reference
if isempty(GSOD_data_unit_reference)
    GSOD_data_unit_reference = zeros(intmax('uint16'),1);
end

freq = stationFrequencyType('d');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if isa( strs, 'char' )
    strs = cellstr( strs );
end

element = stationRecordType( se.record_type );

switch element.abbrev;
    case {'AWND', 'F2MN-S', 'FSIN-S', 'TMAX', 'TMIN'}
        elements = 2;
    case {'DPTP', 'PRCP', 'PRES', 'SLVP', 'SNWD', 'TAVG', 'VISI' }
        elements = 3;
    otherwise
        error( 'GSOD can not be called if data type unknown.');
end

source_code = stationSourceType( 'GSOD' );

start_pos = length( se.dates ) + 1;
extend = length(strs)*31;

se.dates(start_pos:start_pos + extend) = NaN; 
se.data(start_pos:start_pos + extend) = NaN; 
se.time_of_observation(start_pos:start_pos + extend) = NaN; 
se.num_measurements(start_pos:start_pos + extend) = NaN; 
se.source(start_pos:start_pos + extend,1) = source_code; 
se.flags(start_pos:start_pos + extend,1) = NaN; 

true_start = start_pos;
val_cache = zeros(1,start_pos + extend);

for jj = 1:length(strs)
    str = strs{jj}(14:end);
    
    tm = sscanf( str(1:6), '%04d%02d' );
    year = tm(1);
    month = tm(2);
    
    vals = struct();

    if elements == 2
        [V1, V2, V3] = strread(str(7:end), '%d%*1c%f%1c', 'whitespace', '');
        if length(V3) < length(V2)
            V3(end+1) = ' ';
        end
        V4 = {};
    elseif elements == 3
        [V1, V2, V3, V4] = strread(str(7:end), '%d%*1c%f%1c%d', 'whitespace', '');
    else
        error( 'Unknown number of elements.' );
    end        
        
    vals.day = V1;
    vals.value = V2;    
    vals.flag_tok = V3;
        
    if ~isempty(V4)
        vals.num_measurements = V4;
    else
        vals.num_measurements = ones(length(V1),1)*NaN;
    end
    
    blocks = length(vals.day);
    
    uf1 = vals.flag_tok;
    vals.flag = zeros(length(uf1),1);
    
    f = find( uf1 ~= ' ' );
    last_tok = ' ';
    last_flag = -1;
    for mm = 1:length(f)
        k = f(mm);
        if uf1(k) == last_tok
            vals.flag(k) = last_flag;
            continue;
        end
        if GSOD_flag_reference(uf1(k),1)
            vals.flag(k) = GSOD_flag_reference(uf1(k),1);
        else
            vals.flag(k) = dataFlags( ['GSOD_' uf1(k)] );
            GSOD_flag_reference(uf1(k),1) = vals.flag(k);
        end
        
        last_tok = uf1(k);
        last_flag = vals.flag(k);
    end
    
    if GSOD_data_unit_reference( se.record_type ) == 0
        GSOD_data_unit_reference( se.record_type ) = unitConversion( ['GSOD_' element.abbrev] );
    end

    if element_unit_reference( element.index ) == 0
        element_unit_reference( element.index ) = unitConversion( element.units );
    end
    
    v = ones(blocks,3);
    v(:,1) = year;
    v(:,2) = month;
    v(:,3) = vals.day;

    v = datenum(v);

    val_cache(start_pos:start_pos+blocks-1) = vals.value;    
    
    se.dates(start_pos:start_pos+blocks-1) = v;
    se.flags(start_pos:start_pos+blocks-1,1) = vals.flag;
    start_pos = start_pos + blocks;
    
end

val_cache = val_cache(1:start_pos-1);
val_cache = unitConversion( val_cache, ...
    GSOD_data_unit_reference( se.record_type ), ...
    element_unit_reference( element.index ) );

se.data = se.data(1:start_pos-1);
se.data(true_start:end) = val_cache(true_start:end);

se.dates = se.dates(1:start_pos-1);
se.time_of_observation = se.time_of_observation(1:start_pos-1);
se.num_measurements = se.num_measurements(1:start_pos-1);
se.source = se.source(1:start_pos-1,:);
se.flags = se.flags(1:start_pos-1,:);
