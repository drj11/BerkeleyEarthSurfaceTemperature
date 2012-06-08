function se = processUSSOMDataString( se, strs )

global USSOM_flag_reference 
if isempty(USSOM_flag_reference)
    USSOM_flag_reference = zeros(256,3);
end

global element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

global USSOM_data_unit_reference
if isempty(USSOM_data_unit_reference)
    USSOM_data_unit_reference = zeros(intmax('uint16'),1);
end

freq = stationFrequencyType('m');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if isa( strs, 'char' )
    strs = cellstr( strs );
end

source_code = stationSourceType( 'USSOM' );

last_element_str = '';

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

    blocks = sscanf(str(28:30), '%03d');
    if blocks == 0
        continue;
    end

    vals = struct();

    V = sscanf(str(31:end), '%02d%02d%06d%2c');
    vals.month = V(1:5:end);
    vals.day = V(2:5:end);
    vals.value = V(3:5:end);
    vals.flag_tok1 = V(4:5:end);
    vals.flag_tok2 = V(5:5:end);

    f = find( vals.value == -9999 | vals.value == 9999 | ...
        vals.value == 99999 | vals.value == -99999 | ...
        vals.month == 13 );
    vals.value(f) = [];
    vals.month(f) = [];
    vals.day(f) = [];
    vals.flag_tok1(f) = '';
    vals.flag_tok2(f) = '';
    blocks = blocks - length(f);
    if blocks == 0
        continue;
    end

    vals.flag1 = zeros(blocks,1);
    vals.flag2 = zeros(blocks,1);
    
    uf1 = vals.flag_tok1;
    for k = 1:length(uf1)
        if uf1(k) == ' '
            continue;
        else
            if USSOM_flag_reference(uf1(k),1)
                vals.flag1(k) = USSOM_flag_reference(uf1(k),1);
            else
                vals.flag1(k) = dataFlags( ['USSOM_' uf1(k)] );
                USSOM_flag_reference(uf1(k),1) = vals.flag1(k);
            end
        end
    end

    uf2 = vals.flag_tok2;
    
    for k = 1:length(uf2)
        if uf2(k) == ' '
            continue;
        else
            if USSOM_flag_reference(uf2(k),3)
                vals.flag2(k) = USSOM_flag_reference(uf2(k),3);
            else
                vals.flag2(k) = dataFlags( ['USSOM_2_' uf2(k)] );
                USSOM_flag_reference(uf2(k),3) = vals.flag2(k);
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
                vals.value = unitConversion( v, 'USSOM_DT', ...
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
                vals.value = unitConversion( v, 'USSOM_DT', ...
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
                vals.value = unitConversion( v, 'USSOM_DT', ...
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
                vals.value = unitConversion( v, 'USSOM_DT', ...
                    element_unit_reference(element.index) );
            end
        otherwise
            if length(units) > 1
                ref_index = typecast( uint8(units), 'uint16' );
            else
                ref_index = uint8(units);
            end
            if USSOM_data_unit_reference(ref_index) == 0
                USSOM_data_unit_reference(ref_index) = unitConversion( ['ussom_' units] );
            end

            vals.value = unitConversion( vals.value, ...
                USSOM_data_unit_reference(ref_index), ...
                element_unit_reference(element.index) );
    end

    if strcmp( element.abbrev, 'FSMI' ) || strcmp( element.abbrev, 'FSMN' )
        f = find( vals.value == 990 );
        vals(f) = [];
    end

    v = (year - 1600)*12 + vals.month;

    se.dates(end+1:end+blocks) = v;
    se.data(end+1:end+blocks) = vals.value;
    se.time_of_observation(end+1:end+blocks) = NaN;
    se.num_measurements(end+1:end+blocks) = NaN;

    se.source(end+1:end+blocks,1) = source_code;

    se.flags(end+1:end+blocks,1:2) = [vals.flag1 vals.flag2];

end

S = sum( double( se.flags ));
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.flags(:,f) = [];

