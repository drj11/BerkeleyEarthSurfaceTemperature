function se = processUSSODDataString( se, strs )

global USSOD_flag_reference 
if isempty(USSOD_flag_reference)
    USSOD_flag_reference = zeros(256,3);
end

global element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

global USSOD_data_unit_reference
if isempty(USSOD_data_unit_reference)
    USSOD_data_unit_reference = zeros(intmax('uint16'),1);
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

fo_source_code = stationSourceType( 'USSOD-FO' );
c_source_code = stationSourceType( 'USSOD-C' );

start_pos = length(se.dates) + 1;
extend = length(strs)*62;

se.dates(start_pos:start_pos+extend) = NaN;
se.data(start_pos:start_pos+extend) = NaN;
se.time_of_observation(start_pos:start_pos+extend) = NaN;
se.num_measurements(start_pos:start_pos+extend) = NaN;
se.source(start_pos:start_pos+extend,1:3) = NaN;
se.flags(start_pos:start_pos+extend,1:2) = NaN;

for jj = 1:length(strs)
    str = strs{jj}(5:end);
    element_str = str(12:15);
    
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
    
    units = strtrim(str(16:17));
    tm = sscanf( str(18:23), '%04d%02d' );
    year = tm(1);
    month = tm(2);
    source = str(24:25);

    if ~strcmp( source(1), last_source1 )
        source1 = stationSourceType( ['USSOD_' source(1)] );
    end
    if ~strcmp( source(2), last_source2 )
        source2 = stationSourceType( ['USSOD_' source(2)] );
    end
    last_source1 = source(1);
    last_source2 = source(2);
        
    if source2 == source1
        source2 = 0;
    end

    blocks = sscanf(str(28:30), '%03d');
    if blocks == 0
        continue;
    end

    vals = struct();

    V = sscanf(str(31:end), '%02d%02d%06d%2c');
    vals.day = V(1:5:end);
    vals.hour = V(2:5:end);
    vals.value = V(3:5:end);
    vals.flag_tok1 = V(4:5:end);
    vals.flag_tok2 = V(5:5:end);
    vals.flag1 = zeros(blocks,1);
    vals.flag2 = zeros(blocks,1);

    f = find( vals.value == -9999 | vals.value == 9999 | vals.value == 99999 | vals.value == -99999);
    if length(f) > 0
        vals.value(f) = [];
        vals.day(f) = [];
        vals.hour(f) = [];
        vals.flag_tok1(f) = '';
        vals.flag_tok2(f) = '';
        vals.flag1(f) = [];
        vals.flag2(f) = [];
        blocks = blocks - length(f);
        if blocks == 0
            continue;
        end
    end
        
    uf1 = vals.flag_tok1;
    fx = find( uf1 ~= ' ' );
    
    for k = 1:length(fx)
        ind = fx(k);
        flag_c = uf1(ind);
        if USSOD_flag_reference(flag_c,1)
            vals.flag1(ind) = USSOD_flag_reference(flag_c,1);
        else
            vals.flag1(ind) = dataFlags( ['USSOD_' flag_c] );
            USSOD_flag_reference(flag_c,1) = vals.flag1(ind);
        end            
    end

    uf2 = vals.flag_tok2;
    first_order = strcmp(str(4:6), '000');
    
    if first_order
        source_code = fo_source_code;
    else
        source_code = c_source_code;
    end

    fx = find( uf2 ~= ' ' );    
    
    for k = 1:length(fx)
        ind = fx(k);
        flag_c = uf2(ind);
        
        if first_order
            if USSOD_flag_reference(flag_c,2)
                vals.flag2(ind) = USSOD_flag_reference(flag_c,2);
            else
                vals.flag2(ind) = dataFlags( ['USSOD_F2_' flag_c] );
                USSOD_flag_reference(flag_c,2) = vals.flag2(ind);
            end
        else
            if USSOD_flag_reference(flag_c,3)
                vals.flag2(ind) = USSOD_flag_reference(flag_c,3);
            else
                vals.flag2(ind) = dataFlags( ['USSOD_C2_' flag_c] );
                USSOD_flag_reference(flag_c,3) = vals.flag2(ind);
            end
        end
    end

    switch lower(units)
        case {'hr'}
            v = vals.value;
            hr = floor(v/100);
            mn = v - 100*hr;
            v = hr + mn/60;
            vals.value = unitConversion( v, 'hr', ...
                element_unit_reference(element.index) );
        case {'kd'} % Is this correct??
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value;
                v = floor(v/100);
                vals.value = unitConversion( v, 'kt', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                v = vals.value;
                v = v - floor(v/100)*100;
                vals.value = unitConversion( v, 'ussod_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'ks'}
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value;
                v = v - floor(v/1000)*1000;
                vals.value = unitConversion( v, 'kt', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                p16 = [0, 0;
                    12, 360 * 1/16;
                    22, 360 * 2/16;
                    32, 360 * 3/16;
                    33, 360 * 4/16;
                    34, 360 * 5/16;
                    44, 360 * 6/16;
                    54, 360 * 7/16;
                    55, 360 * 8/16;
                    56, 360 * 9/16;
                    66, 360 * 10/16;
                    76, 360 * 11/16;
                    77, 360 * 12/16;
                    78, 360 * 13/16;
                    88, 360 * 14/16;
                    18, 360 * 15/16;
                    11, 360 * 16/16;
                    ];

                v = vals.value;
                v = floor(v/1000);
                for k = 1:length(v)
                    fk = findk(p16(:,1), v(k));
                    v(k) = p16(fk, 2);
                end
                vals.value = unitConversion( v, 'ussod_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'md'} % Is this correct?
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value;
                v = floor(v/100);
                vals.value = unitConversion( v, 'mph', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                v = vals.value;
                v = v - floor(v/100)*100;
                vals.value = unitConversion( v, 'ussod_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'ms'}
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value;
                v = v - floor(v/1000)*1000;
                vals.value = unitConversion( v, 'mph', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                p16 = [0, 0;
                    12, 360 * 1/16;
                    22, 360 * 2/16;
                    32, 360 * 3/16;
                    33, 360 * 4/16;
                    34, 360 * 5/16;
                    44, 360 * 6/16;
                    54, 360 * 7/16;
                    55, 360 * 8/16;
                    56, 360 * 9/16;
                    66, 360 * 10/16;
                    76, 360 * 11/16;
                    77, 360 * 12/16;
                    78, 360 * 13/16;
                    88, 360 * 14/16;
                    18, 360 * 15/16;
                    11, 360 * 16/16;
                    ];

                v = vals.value;
                v = floor(v/1000);
                for k = 1:length(v)
                    fk = findk(p16(:,1), v(k));
                    v(k) = p16(fk, 2);
                end
                vals.value = unitConversion( v, 'ussod_DT', ...
                    element_unit_reference(element.index) );
            end
        otherwise
            if length(units) > 1
                ref_index = typecast( uint8(units), 'uint16' );
            else
                ref_index = uint8(units);
            end
            if USSOD_data_unit_reference(ref_index) == 0
                USSOD_data_unit_reference(ref_index) = unitConversion( ['ussod_' units] );
            end

            vals.value = unitConversion( vals.value, ...
                USSOD_data_unit_reference(ref_index), ...
                element_unit_reference(element.index) );
    end

    if strcmp( element.abbrev, 'FSMI' ) || strcmp( element.abbrev, 'FSMN' )
        f = find( vals.value == 990 );
        vals(f) = [];
    end

    f = find(vals.hour == 99 );
    vals.hour(f) = NaN;

    v = ones(blocks,3);
    v(:,1) = year;
    v(:,2) = month;
    v(:,3) = vals.day;

    v = datenum(v);

    se.dates(start_pos:start_pos+blocks-1) = v;
    se.data(start_pos:start_pos+blocks-1) = vals.value;
    se.time_of_observation(start_pos:start_pos+blocks-1) = vals.hour;
    se.source(start_pos:start_pos+blocks-1,1:3) = ones(blocks,1)*[source1, source2, source_code];
    se.flags(start_pos:start_pos+blocks-1,1:2) = [vals.flag1 vals.flag2];

    start_pos = start_pos + blocks;
end

se.data = se.data(1:start_pos-1);
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

S = sum( double(se.source) );
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.source(:,f) = [];
