function se = processGHCNDDataString( se, strs )
% Process GHCN-D Data String and store in stationElement

% Caches for faster operation
persistent GHCND_flag_reference
if isempty(GHCND_flag_reference)
    GHCND_flag_reference = zeros(256,2);
end

persistent GHCND_source_reference
if isempty(GHCND_source_reference)
    GHCND_source_reference = zeros(256,1);
end

persistent element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

persistent GHCND_data_unit_reference
if isempty(GHCND_data_unit_reference)
    GHCND_data_unit_reference = zeros(intmax('uint16'),1);
end

persistent GHCND_data_flag_reference
if isempty(GHCND_data_flag_reference)
    GHCND_data_flag_reference = zeros(intmax('uint16'),1);
end


% Verify that frequency matches.
freq = stationFrequencyType('d');
if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if iscell( strs )
    strs = char( strs );
end

source_code = stationSourceType( 'GHCN-D' );

% Check element type
str = strs(:, 12:end);
element_str = cellstr( str(:, 7:10) );
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
    if se.record_type ~= element.index;
        error( 'Record has wrong type' );
    end
    element_str = element_str{1};
end

% Dates
tm = textscan( str(:,1:6)', '%04d%02d' );
year = tm{1};
month = tm{2};

vals = struct();

% Load data
V = textscan( str(:,11:end)', '%05f%1c%1c%1c',...
    'whitespace', '' );

blocks = length(year)*31;

year = meshgrid(year, 1:31);
year = reshape( year, blocks, 1 );
month = meshgrid(month, 1:31);
month = reshape( month, blocks, 1 );

vals.day = mod( (1:blocks) - 1, 31 ) + 1;
vals.value = V{1};
vals.flag_tok1 = V{2};
vals.flag_tok2 = V{3};
vals.source_tok = V{4};
vals.flag1 = zeros(blocks,1);
vals.flag2 = zeros(blocks,1);
vals.source = zeros(blocks,1);

% Remove missing values
f = find([vals.value] == -9999);
if ~isempty(f)
    vals.day(f) = [];
    vals.value(f) = [];
    vals.flag_tok1(f) = [];
    vals.flag_tok2(f) = [];
    vals.source_tok(f) = [];
    vals.flag1(f) = [];
    vals.flag2(f) = [];
    vals.source(f) = [];
    year(f) = [];
    month(f) = [];
end

blocks = length(vals.day);

% Look up flag1 
uf1 = vals.flag_tok1;
f = find( uf1 ~= ' ' );
for k1 = 1:length(f)
    k = f(k1);
    if GHCND_flag_reference(uf1(k),1)
        vals.flag1(k) = GHCND_flag_reference(uf1(k),1);
    else
        vals.flag1(k) = dataFlags( ['GHCN_M' uf1(k)] );
        GHCND_flag_reference(uf1(k),1) = vals.flag1(k);
    end
end

% Look up flag2
uf2 = vals.flag_tok2;
f = find( uf2 ~= ' ' );
for k1 = 1:length(f)
    k = f(k1);
    if GHCND_flag_reference(uf2(k),2)
        vals.flag2(k) = GHCND_flag_reference(uf2(k),2);
    else
        vals.flag2(k) = dataFlags( ['GHCN_Q' uf2(k)] );
        GHCND_flag_reference(uf2(k),2) = vals.flag2(k);
    end
end

% Look up source flag
us = vals.source_tok;
un2 = unique( us );
for k = 1:length(un2)
    us2 = un2(k);
    if us2 == ' '
        continue;
    else
        if GHCND_source_reference(us2)
            f = ( us == us2 );
            vals.source(f) = GHCND_source_reference(us2);
        else
            f = ( us == us2 );
            GHCND_source_reference(us2) = stationSourceType( ['GHCN_' us2] );
            vals.source(f) = GHCND_source_reference(us2);
        end
    end
end

% Look up units
if GHCND_data_unit_reference( se.record_type ) == 0 || ...
        GHCND_data_flag_reference( se.record_type ) == 0
    if strcmp( element_str(1:2), 'SN' ) || ...
            strcmp( element_str(1:2), 'SX' ) || ...
            strcmp( element_str(1:2), 'WT' )
        if strcmp( element_str, 'WTEQ' )
            GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str] );
        else
            GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str(1:2)] );
        end
        error( 'Need to configure data type flag' );
    else
        GHCND_data_unit_reference( se.record_type ) = unitConversion( ['GHCND_' element_str] );
        data_type_flag = dataFlags( 'FROM_C_TENTH' );
        GHCND_data_flag_reference( se.record_type ) = data_type_flag;
    end
else
    data_type_flag = GHCND_data_flag_reference( se.record_type );
end

% Figure Julian Day
v = ones(blocks,3);

v(:,1) = year;
v(:,2) = month;
v(:,3) = vals.day;
v = datenum(v);

% Store Data
se.dates(end+1:end+blocks, 1) = v;
se.source(end+1:end+blocks, 1:2) = [vals.source, ones(blocks,1)*source_code];
se.flags(end+1:end+blocks, 1:3) = [vals.flag1 vals.flag2 ones(blocks, 1)*data_type_flag];

vals.value = unitConversion( vals.value, ...
    GHCND_data_unit_reference( se.record_type ), ...
    element_unit_reference(element.index) );
precision = unitConversion( [0, 0.5], ...
    GHCND_data_unit_reference( se.record_type ), ...
    element_unit_reference(element.index) );

se.uncertainty( end+1:end+blocks, 1 ) = abs(precision(1) - precision(2));
se.data(end+1:end+blocks, 1) = vals.value;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = NaN;

% Remove blank flags
S = sum( double( se.flags ) );
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.flags(:,f) = [];

% Remove blank sources
S = sum( double( se.source ) );
f = find(S == 0);
if length(f) == length(S)
    f(1) = [];
end

se.source(:,f) = [];
