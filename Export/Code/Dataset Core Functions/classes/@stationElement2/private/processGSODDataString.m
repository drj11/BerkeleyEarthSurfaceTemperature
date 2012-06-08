function se = processGSODDataString( se, strs )

persistent GSOD_flag_reference
if isempty(GSOD_flag_reference)
    GSOD_flag_reference = zeros(256,2);
end

persistent element_unit_reference
if isempty(element_unit_reference)
    element_unit_reference = zeros(3000,1);
end

persistent GSOD_data_unit_reference
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

persistent last_record last_element
if ~isempty( last_record ) && last_record == se.record_type
    element = last_element;
else
    element = stationRecordType( se.record_type );
    last_element = element;
    last_record = se.record_type;
end

switch element.abbrev
    case {'AWND', 'F2MN-S', 'FSIN-S', 'TMAX', 'TMIN'}
        elements = 2;
    case {'DPTP', 'PRCP', 'PRES', 'SLVP', 'SNWD', 'TAVG', 'VISI' }
        elements = 3;
    otherwise
        error( 'GSOD can not be called if data type unknown.');
end

source_code = stationSourceType( 'GSOD' );

% Only valid for temperatures.  Should be updated.
switch element.abbrev
    case {'TAVG', 'TMAX', 'TMIN'}        
        original_data_code = dataFlags( 'FROM_F_TENTH' );
        uncertainty_val = 0.05 * 5/9;
    otherwise
        error( 'Not available for this data type.' );
end
        
% Collapse strings
str = sprintf( '%s\n', strs{:} );

% Dummy variable
vals = struct();

if elements == 2
    C = textscan(str, '%*13c%4d%2d%2d%*1c%f%1c', 'whitespace', '');
    [VY, VM, VD, V2, V3] = deal(C{:});
    if length(V3) < length(V2)
        V3(end+1) = ' ';
    end
    V4 = {};
elseif elements == 3
    C = textscan(str, '%*13c%4d%2d%2d%*1c%f%1c%d', 'whitespace', '');
    [VY, VM, VD, V2, V3, V4] = deal(C{:});
else
    error( 'Unknown number of elements.' );
end

f = find( V2 >= 9000 );
VY(f) = [];
VM(f) = [];
VD(f) = [];
V2(f) = [];
V3(f) = [];
if ~isempty( V4 )
    V4(f) = [];
end
if isempty( V2 )
    return;
end

% New lines are not flags
V3( V3 == 13 | V3 == 10 ) = ' ';
vals.year = VY;
vals.month = VM;
vals.day = VD;
vals.value = V2;
vals.flag_tok = V3;

if ~isempty(V4)
    vals.num_measurements = V4;
else
    vals.num_measurements = ones(length(VY),1)*NaN;
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
v(:,1) = vals.year;
v(:,2) = vals.month;
v(:,3) = vals.day;

v = datenum(v);

se.dates(end+1:end+blocks, 1) = v;
se.flags(end+1:end+blocks, 1:2) = [vals.flag original_data_code*ones(blocks, 1)];

vals.value = unitConversion( vals.value, ...
    GSOD_data_unit_reference( se.record_type ), ...
    element_unit_reference( element.index ) );

se.data(end+1:end+blocks, 1) = vals.value;
se.uncertainty(end+1:end+blocks, 1) = uncertainty_val;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = vals.num_measurements;
se.source(end+1:end+blocks, 1) = source_code;
