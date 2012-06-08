function se = processUSSODDataString( se, strs )
% Process USSOD Data String into StationElement

persistent USSOD_flag_reference 
if isempty(USSOD_flag_reference)
    USSOD_flag_reference = zeros(256,3);
end

persistent element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

persistent USSOD_data_unit_reference
if isempty(USSOD_data_unit_reference)
    USSOD_data_unit_reference = zeros(intmax('uint16'),1);
end

% Verify Frequency
freq = stationFrequencyType('d');
if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if iscell( strs )
    str_c = strs;
    strs = char( strs );
else
    str_c = cellstr( strs );
end

fo_source_code = stationSourceType( 'USSOD-FO' );
c_source_code = stationSourceType( 'USSOD-C' );

dss_start = cellstr( strs(:,1:4) );

str = strs(:,9:end);

element_str = cellstr( str(:,9:12) );
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
    
    if se.record_type ~= element.index               
        error( 'Record has wrong type' );
    end
    element_str = element_str{1};
end
        
units_start = cellstr( str(:,13:14) );
tm = textscan( str(:, 15:20)', '%04d%02d' );
year_start = tm{1};
month_start = tm{2};

source = str(:,21:22);
last_source1 = '9';
last_source2 = '9';
source1s = zeros( length( source(:, 1) ), 1 );
source2s = source1s;
for k = 1:length(source(:,1))
    if ~strcmp( source(k,1), last_source1 )
        source1s(k) = stationSourceType( ['USSOD_' source(k, 1)] );
    end
    if ~strcmp( source(k,2), last_source2 )
        source2s(k) = stationSourceType( ['USSOD_' source(k, 2)] );
    end
    last_source1 = source(k, 1);
    last_source2 = source(k, 2);
end
source2s( source2s == source1s ) = 0;

% NOTE: The inline length of field indicator is not reliable.  Measure the
% number of fields directly.
ll = zeros( length(str_c), 1 );
for k = 1:length(str_c)
    ll(k) = length( str_c{k} );
end
blocks = (ll - 8 - 27) / 12;

f = find( abs(round(blocks) - blocks) > 0.05 );
if ~isempty(f)
    for k = 1:length(f)
        sessionWriteLog( ['Skipping malformed line: ' str(f,:)] );
    end
end

% Eliminate empty lines
f = ( blocks == 0 | abs(round(blocks) - blocks) > 0.05 );
blocks( f ) = [];
str(f,:) = [];
source1s(f) = [];
source2s(f) = [];
units_start(f) = [];
year_start(f) = [];
month_start(f) = [];
dss_start(f) = [];

units = cell( sum(blocks), 1 );
dss = cell( sum(blocks), 1 );
year = zeros( sum(blocks), 1 );
month = zeros( sum(blocks), 1 );
source1 = zeros( sum(blocks), 1 );
source2 = zeros( sum(blocks), 1 );
start = 0;

data_string = char( zeros( sum(blocks)*12, 1 ) );

for k = 1:length(blocks)
    [units{ start + (1:blocks(k)) }] = deal( units_start{k} );
    [dss{ start + (1:blocks(k)) }] = deal( dss_start{k} );
    year( start + (1:blocks(k)) ) = year_start(k);
    month( start + (1:blocks(k)) ) = month_start(k);
    source1( start + (1:blocks(k)) ) = source1s(k);
    source2( start + (1:blocks(k)) ) = source2s(k);
    data_string( start*12 + (1:blocks(k)*12) ) = str(k, 28:(28+12*blocks(k)-1) )';
    start = start + blocks(k);    
end

blocks = sum(blocks);
vals = struct();

V = textscan( data_string, '%02c%02c%06c%1c%1c', 'whitespace', '' );

I = strmatch( '  ', V{1} );
if ~isempty(I)
    V{1}(I,:) = ones(length(I),1)*'99';
end
I = strmatch( '  ', V{2} );
if ~isempty(I)
    V{2}(I,:) = ones(length(I),1)*'99';
end
I = strmatch( 'VA', V{2} );
if ~isempty(I)
    V{2}(I,:) = ones(length(I),1)*'99';
end
I = strmatch( 'MI', V{2} );
if ~isempty(I)
    V{2}(I,:) = ones(length(I),1)*'99';
end

vals.day = sscanf( V{1}', '%2d' );
vals.hour = sscanf( V{2}', '%2d' );
vals.value = sscanf( V{3}', '%6f' );
vals.flag_tok1 = V{4};
vals.flag_tok2 = V{5};
vals.flag1 = zeros(blocks,1);
vals.flag2 = zeros(blocks,1);

f = ( vals.value == -9999 | vals.value == 9999 | ...
    vals.value == 99999 | vals.value == -99999 );
if sum(f) > 0
    vals.value(f) = [];
    vals.day(f) = [];
    vals.hour(f) = [];
    vals.flag_tok1(f) = '';
    vals.flag_tok2(f) = '';
    vals.flag1(f) = [];
    vals.flag2(f) = [];
    year(f) = [];
    month(f) = [];
    units(f) = [];
    dss(f) = [];
    source1(f) = [];
    source2(f) = [];
end

blocks = length(year);
if blocks == 0
    return;
end

dss_un = unique( dss );
dss_code = zeros( length(dss), 1 );
for k = 1:length( dss_un )
    if length( dss_un ) == 1
        I = 1:length(dss);
    else
        I = strcmp( dss_un{k}, dss );
    end
    
    dss_code(I) = stationSourceType( ['NCDC_' dss_un{k}] );
end

uf1 = vals.flag_tok1;
fx = find( uf1 ~= ' ' );

for k = 1:length(fx)
    ind = fx(k);
    flag_c = uf1(ind);
    if USSOD_flag_reference(flag_c,1)
        vals.flag1(ind) = USSOD_flag_reference(flag_c,1);
    else
        try
            vals.flag1(ind) = dataFlags( ['USSOD_' flag_c] );
        catch
            sessionWriteLog( ['Error: Flag USSOD_' flag_c ...
                ' not found in: ' str(1,1:20) '...'] );
            return;
        end
        USSOD_flag_reference(flag_c,1) = vals.flag1(ind);
    end
end

uf2 = vals.flag_tok2;
first_order = ( strcmp( dss{1}, '3210') || strcmp( dss{1}, '3211') );
cdmp_version = ( strcmp( dss{1}, '3205') || strcmp( dss{1}, '3206') );

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
            try
                vals.flag2(ind) = dataFlags( ['USSOD_F2_' flag_c] );
            catch
                sessionWriteLog( ['Error: Flag USSOD_F2_' flag_c ...
                    ' not found in: ' str(1,1:20) '...'] );
                return;                
            end
            USSOD_flag_reference(flag_c,2) = vals.flag2(ind);
        end
    else
        if flag_c == 'V'
            if cdmp_version
                vals.flag2(ind) = dataFlags( ['USSOD_C2_' flag_c '_CDMP'] );
            end            
        end
        if USSOD_flag_reference(flag_c,3)
            vals.flag2(ind) = USSOD_flag_reference(flag_c,3);
        else
            try
                vals.flag2(ind) = dataFlags( ['USSOD_C2_' flag_c] );
            catch
                sessionWriteLog( ['Error: Flag USSOD_C2_' flag_c ...
                    ' not found in: ' str(1,1:20) '...'] );
                return;                
            end
            USSOD_flag_reference(flag_c,3) = vals.flag2(ind);
        end
    end
end

precision = vals.value.*NaN;
data_type_flag = zeros( length( units ), 1 );

unique_list = unique( units );

for k = 1:length(unique_list)
    unit_val = strtrim( unique_list{k} );
    if length(unique_list) == length(units)
        I = 1:length(units);
    else
        % Note: Don't strtrim here.
        I = find(strcmp( unique_list{k}, units ));
    end

    if isempty( unit_val )
        switch element_str
            case {'TMAX', 'TMIN', 'TAVG', ...
                    'TOBS', 'OT07', 'OT14', 'OT21'}
                unit_val = 'F';
            otherwise
                error( 'No default unit available.' );
        end
    end            
    
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
                vals.value(I) = unitConversion( v, 'ussod_DT', ...
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
                vals.value(I) = unitConversion( v, 'ussod_DT', ...
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
                vals.value(I) = unitConversion( v, 'ussod_DT', ...
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
                vals.value(I) = unitConversion( v, 'ussod_DT', ...
                    element_unit_reference(element.index) );
            end
        otherwise
            if length(unit_val) > 1
                ref_index = typecast( uint8(unit_val), 'uint16' );
            else
                ref_index = uint8(unit_val);
            end
            if USSOD_data_unit_reference(ref_index) == 0
                USSOD_data_unit_reference(ref_index) = unitConversion( ['ussod_' unit_val] );
            end

            try
                vals.value(I) = unitConversion( vals.value(I), ...
                    USSOD_data_unit_reference(ref_index), ...
                    element_unit_reference(element.index) );
                pp = unitConversion( [0 0.5], ...
                    USSOD_data_unit_reference(ref_index), ...
                    element_unit_reference(element.index) ); ...
                precision(I) = abs(pp(1) - pp(2));            
            catch
                sessionWriteLog( ['Error: Incorrect unit "' unit_val '" code ' ...
                    'found in: ' str(1,1:30) ' ...'] );
                return;                
            end
                            
            % Fix me; This only works of temperature types
            pp = round( abs(pp(1) - pp(2)) * 100000 ) / 100000;
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
    f = ( vals.value == 990 );
    vals(f) = [];
    
    % Fix me: need eliminate other elements
end

f = (vals.hour == 99) ;
vals.hour(f) = NaN;

v = ones(blocks,3);
v(:,1) = year;
v(:,2) = month;
v(:,3) = vals.day;

v = datenum(v);

if strcmp( element_str(1:2), 'OT' )
    hr = str2double( element_str(3:4) );
    vals.hour( isnan( vals.hour ) ) = hr;
end

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals.value;
se.uncertainty(end+1:end+blocks, 1) = precision;

% Special case, from XXX to XXX, USSOD erroneously reports all morning and
% evening observations as occuring at 6 PM.  This is spurious and we block
% them.

v1 = datenum( [1963,10,1] );
v2 = datenum( [1981,12,31] );

f = ( v >= v1 & v <= v2 & vals.hour ~= 24 );
vals.hour(f) = NaN;

se.time_of_observation(end+1:end+blocks, 1) = vals.hour;
se.num_measurements(end+1:end+blocks, 1) = NaN;
se.source(end+1:end+blocks,1:4) = [source1, source2, ones(blocks,1)*source_code, dss_code];
se.flags(end+1:end+blocks,1:3) = [vals.flag1 vals.flag2 data_type_flag];


% Eliminate unnecessary fields
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
