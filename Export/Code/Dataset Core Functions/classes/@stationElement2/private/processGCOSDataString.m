function se = processGCOSDataString( se, strs )
% Reads a cell array of GCOS raw data and populates the corresponding
% station element with the data.

% Verify the station element has the right frequency type
freq = stationFrequencyType('m');

if isnan(se.frequency)
    se.frequency = freq;
end
if se.frequency ~= freq;
    error( 'Record has wrong data frequency' );
end

if ischar( strs )
    strs = cellstr( strs );
end

source_code = stationSourceType( 'GCOS' );
original_data_code = dataFlags( 'FROM_C_TENTH' );

str = strvcat(strs);

year = sscanf( str(:,1:4)','%4d' );
month = sscanf( str(:,5:6)','%2d' );

if length(year) ~= length(str(:,1))
    sessionWriteLog( ['Error: Too few lines read in "' str(1,1:30) '"...'] );
end

element = stationRecordType( se.record_type );
abbrev = element.abbrev;

switch abbrev
    case 'TAVG'
        f = strcmp( '', cellstr( str(:,67:69) ) ) | ...
            str(:,67) == '/' | str(:,68) == '/' | str(:,69) == '/';
        str(f,:) = [];
        year(f) = [];
        month(f) = [];
        if isempty(str)
            return;
        end
                
        vals = sscanf( str(:,67:69)','%3f' )/10;
        
        f = ( str(:,66) == '1' );
        vals(f) = -vals(f);
        
        missing = vals.*NaN;
        f = find(str(:,110) ~= ' ' & str(:,110) ~= '/' ...
            & str(:,109) ~= '/' & str(:,109) ~= ' '); 
        missing(f) = sscanf( str(f,109:110)','%2d' );
    case 'TMAX'
        f = strcmp( '', cellstr(str(:,76:78)) ) | ...
            str(:,76) == '/' | str(:,77) == '/' | str(:,78) == '/';
        str(f,:) = [];
        year(f) = [];
        month(f) = [];
        if isempty(str)
            return;
        end
        
        vals = sscanf( str(:,76:78)','%3f' )/10;
        f = ( str(:,75) == '1' );
        vals(f) = -vals(f);

        missing = vals.*NaN;
        f = find(str(:,111) ~= ' ' & str(:,111) ~= '/');        
        missing(f) = sscanf( str(f,111)','%1d' );
    case 'TMIN'
        f = strcmp( '', cellstr(str(:,80:82)) ) | ...
            str(:,80) == '/' | str(:,81) == '/' | str(:,82) == '/';
        str(f,:) = [];
        year(f) = [];
        month(f) = [];
        if isempty(str)
            return;
        end
        
        vals = sscanf( str(:,80:82)','%3f' )/10;
        f = ( str(:,79) == '1' );
        vals(f) = -vals(f);

        missing = vals.*NaN;
        f = find(str(:,112) ~= ' ' & str(:,112) ~= '/');        
        missing(f) = sscanf( str(f,112)','%1d' );
    otherwise
        error( 'Type not defined' );
end

v = (year - 1600)*12 + month;
blocks = length(v);

dd1 = datenum( year, month, ones(length(month),1) );
dd2 = datenum( year, month + 1, ones(length(month),1) );
dt = dd2 - dd1;
num = dt - missing;

se.dates(end+1:end+blocks, 1) = v;
se.data(end+1:end+blocks, 1) = vals;
se.uncertainty(end+1:end+blocks, 1) = 0.05;
se.time_of_observation(end+1:end+blocks, 1) = NaN;
se.num_measurements(end+1:end+blocks, 1) = num;
se.source(end+1:end+blocks,1) = source_code;
se.flags(end+1:end+blocks, 1) = original_data_code;

