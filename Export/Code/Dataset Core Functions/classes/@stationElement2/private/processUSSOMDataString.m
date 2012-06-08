function se = processUSSOMDataString( se, strs )
% Read USSOM data string and store it in StationElement

persistent USSOM_flag_reference
if isempty(USSOM_flag_reference)
    USSOM_flag_reference = zeros(256,3);
end

persistent element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

persistent USSOM_data_unit_reference
if isempty(USSOM_data_unit_reference)
    USSOM_data_unit_reference = zeros(intmax('uint16'),1);
end

% Verify appropriate frequency
freq = stationFrequencyType('m');
if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if iscell( strs )
    strs = char( strs );
end

source_code = stationSourceType( 'USSOM' );

str = strs;
element_str = cellstr( str(:, 14:17) );
element_str = unique( element_str );

if length(element_str) > 1
    error( 'Too many element types' );
else
    element = stationRecordType( element_str{1} );
    
    if element_unit_reference(element.index) == 0
        element_unit_reference(element.index) = unitConversion(element.units);
    end
    
    if isnan(se.record_type)
        se.record_type = element.index;
    end
    
% Fix this...  Type cross-mapping...
%     if se.record_type ~= element.index               
%         error( 'Record has wrong type' );
%     end
    element_str = element_str{1};
end

units_start = cellstr( str(:,18:19) );
units = cell( 13*length(units_start), 1 );
for k = 1:length( units_start )
    [units{ 13*(k-1) + (1:13) }] = deal( units_start{k} );
end

tm = textscan( str(:, 20:25)', '%04d%02d' );
year = tm{1};
year = meshgrid( year, 1:13 );
year = year(:);

vals = struct();

V = textscan( str(:,26:end)', '%02d%02d%06c%1c%1c',...
    'whitespace', '' );
vals.month = V{1};
vals.day = V{2};
vals.value = sscanf( V{3}', '%f' );
vals.flag_tok1 = V{4};
vals.flag_tok2 = V{5};

sz = size( str(:, 26:end) );
if length(V{1}) ~= sz(1)*sz(2)/12
    sessionWriteLog( ['Error: Wrong number of elements read in "' str(1,1:30) '"...'] );
end

f = find( vals.value == -9999 | vals.value == 9999 | ...
    vals.value == 99999 | vals.value == -99999 | ...
    vals.month == 13 );
vals.value(f) = [];
vals.month(f) = [];
vals.day(f) = [];
vals.flag_tok1(f) = '';
vals.flag_tok2(f) = '';
year(f) = [];
units(f) = [];

blocks = length(vals.value);
if blocks == 0
    return;
end

vals.flag1 = zeros(blocks,1);
vals.flag2 = zeros(blocks,1);

uf1 = vals.flag_tok1;
f = find( uf1 ~= ' ' );
for k1 = 1:length(f)
    k = f(k1);
    if USSOM_flag_reference(uf1(k),1)
        vals.flag1(k) = USSOM_flag_reference(uf1(k),1);
    else
        vals.flag1(k) = dataFlags( ['USSOM_' uf1(k)] );
        USSOM_flag_reference(uf1(k),1) = vals.flag1(k);
    end
end

uf2 = vals.flag_tok2;
f = find( uf2 ~= ' ' );
for k1 = 1:length(f)
    k = f(k1);
    if USSOM_flag_reference(uf2(k),3)
        vals.flag2(k) = USSOM_flag_reference(uf2(k),3);
    else
        vals.flag2(k) = dataFlags( ['USSOM_2_' uf2(k)] );
        USSOM_flag_reference(uf2(k),3) = vals.flag2(k);
    end
end

precision = zeros( length( units ), 1 ) * NaN;
data_type_flag = zeros( length( units ), 1 );

unique_list = unique( units );

for k = 1:length(unique_list)
    unit_val = strtrim( unique_list{k} );
    if length(unique_list) == length(units)
        I = 1:length(units);
    else
        % Note: Don't strtrim here.
        I = strcmp( unique_list{k}, units );
    end
    
    % Find Correct Unit Conversion
    switch lower(unit_val)
        case {'hr'}
            v = vals.value(I);
            hr = floor(v/100);
            mn = v - 100*hr;
            v = hr + mn/60;
            vals.value(I) = unitConversion( v, 'hr', ...
                element_unit_reference(element.index) );
        case {'kd'} % Is this correct??
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value(I);
                v = floor(v/100);
                vals.value(I) = unitConversion( v, 'kt', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                v = vals.value(I);
                v = v - floor(v/100)*100;
                vals.value(I) = unitConversion( v, 'USSOM_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'ks'}
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value(I);
                v = v - floor(v/1000)*1000;
                vals.value(I) = unitConversion( v, 'kt', ...
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

                v = vals.value(I);
                v = floor(v/1000);
                for m = 1:length(v)
                    fk = findk(p16(:,1), v(m));
                    v(m) = p16(fk, 2);
                end
                vals.value(I) = unitConversion( v, 'USSOM_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'md'} % Is this correct?
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value(I);
                v = floor(v/100);
                vals.value(I) = unitConversion( v, 'mph', ...
                    element_unit_reference(element.index) );
            elseif strcmp( element.abbrev(end-1:end), '-D' )
                v = vals.value(I);
                v = v - floor(v/100)*100;
                vals.value(I) = unitConversion( v, 'USSOM_DT', ...
                    element_unit_reference(element.index) );
            end
        case {'ms'}
            if strcmp( element.abbrev(end-1:end), '-S' )
                v = vals.value(I);
                v = v - floor(v/1000)*1000;
                vals.value(I) = unitConversion( v, 'mph', ...
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

                v = vals.value(I);
                v = floor(v/1000);
                for m = 1:length(v)
                    fk = findk(p16(:,1), v(m));
                    v(m) = p16(fk, 2);
                end
                vals.value(I) = unitConversion( v, 'USSOM_DT', ...
                    element_unit_reference(element.index) );
            end
        otherwise
            if length(unit_val) > 1               
                ref_index = typecast( uint8(unit_val), 'uint16' );
            else
                ref_index = uint8(unit_val);
            end
            if USSOM_data_unit_reference(ref_index) == 0
                USSOM_data_unit_reference(ref_index) = unitConversion( ['ussom_' unit_val] );
            end
            
            vals.value(I) = unitConversion( vals.value(I), ...
                USSOM_data_unit_reference(ref_index), ...
                element_unit_reference(element.index) );
            pp = unitConversion( [0 0.5], ...
                USSOM_data_unit_reference(ref_index), ...
                element_unit_reference(element.index) ); ...
            precision(I) = abs(pp(1) - pp(2));
        
            % Fix me; This only works of temperature types
            pp = round( abs(pp(1)-pp(2)) * 100000 ) / 100000;
            switch pp
                case 0.5
                    data_type_flag(I) = dataFlags( 'FROM_C_WHOLE' );
                case 0.05
                    data_type_flag(I) = dataFlags( 'FROM_C_TENTH' );
                case 0.005
                    data_type_flag(I) = dataFlags( 'FROM_C_HUNDREDTH' );
                case round( 0.5 * 5/9 * 100000 ) / 100000
                    data_type_flag(I) = dataFlags( 'FROM_F_WHOLE' );
                case round( 0.05 * 5/9 * 100000 ) / 100000
                    data_type_flag(I) = dataFlags( 'FROM_F_TENTH' );
                case round( 0.005 * 5/9 * 100000 ) / 100000
                    data_type_flag(I) = dataFlags( 'FROM_F_HUNDREDTH' );
                otherwise
                    error( 'Type not recognized' );
            end
    end
end
    
if strcmp( element.abbrev, 'FSMI' ) || strcmp( element.abbrev, 'FSMN' )
    f = find( vals.value == 990 );
    vals(f) = [];
    % Fix me, need eleminate other elements.
end

% Convert to monthnum
v = (year - 1600)*12 + vals.month;

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals.value;
se.uncertainty(end+1:end+blocks, 1) = precision;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = NaN;
se.source(end+1:end+blocks, 1) = source_code;
se.flags(end+1:end+blocks, 1:3) = [vals.flag1 vals.flag2 data_type_flag];

S = sum( double( se.flags ));
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.flags(:,f) = [];

