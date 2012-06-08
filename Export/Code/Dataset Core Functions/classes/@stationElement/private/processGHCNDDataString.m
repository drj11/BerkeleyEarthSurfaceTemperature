function se = processUSSODDataString( se, strs )

global GHCND_flag_reference 
if isempty(GHCND_flag_reference)
    GHCND_flag_reference = zeros(256,2);
end

global GHCND_source_reference 
if isempty(GHCND_source_reference)
    GHCND_source_reference = zeros(256,1);
end

global element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

global GHCND_data_unit_reference
if isempty(GHCND_data_unit_reference)
    GHCND_data_unit_reference = zeros(intmax('uint16'),1);
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

last_element_str = '';
last_source1 = '';
last_source2 = '';

source_code = stationSourceType( 'GHCN-D' );

start_pos = length(se.dates) + 1;
extend = length(strs)*31;

se.dates(start_pos:start_pos+extend) = NaN;
se.data(start_pos:start_pos+extend) = NaN;
se.time_of_observation(start_pos:start_pos+extend) = NaN;
se.num_measurements(start_pos:start_pos+extend) = NaN;
se.source(start_pos:start_pos+extend,1:2) = [ones(extend+1,1)*NaN, ones(extend+1,1)*source_code];
se.flags(start_pos:start_pos+extend,1:2) = NaN;

true_start = start_pos;
val_cache = zeros(1,start_pos + extend);

for jj = 1:length(strs)
    str = strs{jj}(12:end);
    element_str = str(7:10);
    
    if ~strcmp( element_str, last_element_str )
        element = stationRecordType( element_str );

        if element_unit_reference(element.index) == 0
            element_unit_reference(element.index) = unitConversion(element.units);
        end

        if isnan(se.record_type)
            se.record_type = element.index;
        end
        if se.record_type ~= element.index;
            error( 'Record has wrong type' );
        end
    end
    last_element_str = element_str;
    
    tm = sscanf( str(1:6), '%04d%02d' );
    year = tm(1);
    month = tm(2);
    
    blocks = 31;

    vals = struct();

    V = sscanf(str(11:end), '%05d%1c%1c%1c');
    
    vals.day = 1:31;
    vals.value = V(1:4:end);
    vals.flag_tok1 = V(2:4:end);
    vals.flag_tok2 = V(3:4:end);
    vals.source_tok = V(4:4:end);
    vals.flag1 = zeros(blocks,1);
    vals.flag2 = zeros(blocks,1);
    vals.source = zeros(blocks,1);
    
    f = find([vals.value] == -9999);
    if length(f) > 0
        vals.day(f) = [];
        vals.value(f) = [];
        vals.flag_tok1(f) = [];
        vals.flag_tok2(f) = [];
        vals.source_tok(f) = [];
        vals.flag1(f) = [];
        vals.flag2(f) = [];
        vals.source(f) = [];

        blocks = blocks - length(f);
    end
        
    uf1 = vals.flag_tok1;
    for k = 1:length(uf1)
        if uf1(k) == ' '
            continue;
        else
            if GHCND_flag_reference(uf1(k),1)
                vals.flag1(k) = GHCND_flag_reference(uf1(k),1);
            else
                vals.flag1(k) = dataFlags( ['GHCN_M' uf1(k)] );
                GHCND_flag_reference(uf1(k),1) = vals.flag1(k);
            end
        end
    end

    uf2 = vals.flag_tok2;
    for k = 1:length(uf2)
        if uf2(k) == ' '
            continue;
        else
            if GHCND_flag_reference(uf2(k),2)
                vals.flag2(k) = GHCND_flag_reference(uf2(k),2);
            else
                vals.flag2(k) = dataFlags( ['GHCN_Q' uf2(k)] );
                GHCND_flag_reference(uf2(k),2) = vals.flag2(k);
            end
        end
    end

    us = vals.source_tok;
    for k = 1:length(us)
        if us(k) == ' '
            continue;
        else
            if GHCND_source_reference(us(k))
                vals.source(k) = GHCND_source_reference(us(k));
            else
                vals.source(k) = stationSourceType( ['GHCN_' us(2)] );
                GHCND_source_reference(us(k)) = vals.source(k);
            end
        end
    end
    
    if GHCND_data_unit_reference( se.record_type ) == 0
        if strcmp( element_str(1:2), 'SN' ) || ...
                strcmp( element_str(1:2), 'SX' ) || ...
                strcmp( element_str(1:2), 'WT' )
            if strcmp( element_str, 'WTEQ' )
                GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str] );
            else
                GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str(1:2)] );
            end
        else
            GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str] );
        end
    end

    v = ones(blocks,3);
    v(:,1) = year;
    v(:,2) = month;
    v(:,3) = vals.day;

    v = datenum(v);

    val_cache(start_pos:start_pos+blocks-1) = vals.value;
   
    se.dates(start_pos:start_pos+blocks-1) = v;
    se.source(start_pos:start_pos+blocks-1,1) = vals.source;
    se.flags(start_pos:start_pos+blocks-1,1:2) = [vals.flag1 vals.flag2];
    start_pos = start_pos + blocks;

end

val_cache = val_cache(1:start_pos-1);
val_cache = unitConversion( val_cache, ...
    GHCND_data_unit_reference( se.record_type ), ...
    element_unit_reference(element.index) );

se.data = se.data(1:start_pos-1);
se.data(true_start:end) = val_cache(true_start:end);

se.dates = se.dates(1:start_pos-1);
se.time_of_observation = se.time_of_observation(1:start_pos-1);
se.num_measurements = se.num_measurements(1:start_pos-1);
se.source = se.source(1:start_pos-1,:);
se.flags = se.flags(1:start_pos-1,:);

S = sum( double( se.flags ) );
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.flags(:,f) = [];

S = sum( double( se.source ) );
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.source(:,f) = [];
