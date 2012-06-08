function se = processGHCNM3DataString( se, strs )
% Reads a cell array of GHCN-M raw data and populates the corresponding
% station element with the data.

% Verify the station element has the right frequency type
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

rec = stationRecordType( se.record_type );
source_code = stationSourceType( 'GHCN-M v3' );

original_data_code = dataFlags( 'FROM_C_TENTH' );

% Cut ID portion, not relevant at this stage
str = strs(:,12:end);

year = str2num(str(:,1:4));
year = meshgrid(year, 1:12);
year = year(:);

V = textscan( str(:,9:end)', '%5c%1c%1c%1c', 'whitespace', '' );
vals = sscanf( V{1}', '%5f' );
if length(V{1}) < length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

month = mod((1:length(V{1}))-1, 12)' + 1;
missing = lower(V{2});
qc = V{3};
source = V{4};

dt1 = datenum( year, month, ones(length(month), 1) );
dt2 = datenum( year, month + 1, ones(length(month), 1) );
dd = dt2 - dt1;

num = zeros( length(missing), 1 ).*NaN;

% Documentation on missing days does not appear to match the actual
% contents of the file. For the moment, this is being ignored.

% f = find(missing ~= ' ');
% if ~isempty(f)
%     num(f) = dd - double(( missing(f) - 'a' + 1));
% end

% Remove missing values
f  = find(vals == -9999);
vals(f) = [];
month(f) = [];
year(f) = [];
num(f) = [];
qc(f) = [];
source(f) = [];

f = ( qc ~= ' ' );
q_codes = unique( qc );
q_flags = zeros( length(qc), 1 );
for k = 1:length(q_codes)
    if q_codes(k) == ' '
        continue;
    end
    st = dataFlags( ['GHCN-M3_' q_codes(k)] );
    f = (qc == q_codes(k) );
    q_flags(f) = st;
end

source_codes = unique(source);
source_flags = zeros( length(source), 1 );

for k = 1:length(source_codes)
    if source_codes(k) == ' '
        continue;
    end
    st = stationSourceType( ['GHCN3_' source_codes(k)] );
    f = (source == source_codes(k) );
    source_flags(f) = st;
end


if rec.units == 'C'
    % Organized in raw lists with precision 0.1 C
    vals = vals / 10;
else
    error('Unknown Units');
end

v = (year - 1600)*12 + month;
blocks = length(v);

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals/10;
se.uncertainty(end+1:end+blocks, 1) = 0.05;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = num;
se.source(end+1:end+blocks, 1:2) = [ones(length(v),1)*source_code, ...
    source_flags];

se.flags(end+1:end+blocks, 1:2) = [ones(length(v),1)*original_data_code, ...
    q_flags];

