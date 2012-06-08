function convertToText( dataset )
% Takes a registeredDataSet and generates a text version

temperatureGlobals;

try
    load lastRegConvertToText
catch
    lastRegConvertToText = dictionary();
end

name = [dataset.collection ' : ' dataset.type ' : ' dataset.version];

target = getHash( dataset, name );

try
    previous = lastRegConvertToText( name );
    if previous == target
        if sessionActive()
            sessionWriteLog( 'No text output needed.' );
        else
            disp( 'No text output needed.' );
        end
        return;
    end
catch
    % Never run before, just continue;
end
lastRegConvertToText( name ) = target;

if sessionActive();    
    sessionSectionBegin( 'Convert RegisteredDataSet to Text Format' );
    sessionSectionBegin( 'Loading Data and Sites' );
end

[se_full, sites_full] = loadTemperatureData( dataset );

if sessionActive()
    sessionWriteLog( [num2str(length(se_full)) ' Records Loaded'] );
    sessionWriteLog( [num2str(length(sites_full)) ' Sites Loaded'] );
    sessionSectionEnd( 'Loading Data and Sites' );
end

%File headers

main_header = formatHeader( {'Station ID', 'Series Number', 'Date', ...
    'Temperature (C)', 'Uncertainty (C)', 'Observations', ...
    'Time of Observation'}, 'data', dataset );
flag_header = formatHeader( {'Station ID', 'Series Number', 'Date', ...
    'Flag list ...'}, 'flags', dataset );
source_header = formatHeader( {'Station ID', 'Series Number', 'Date', ...
    'Source list ...'}, 'sources', dataset );


data_flags_in_use = [];
source_flags_in_use = [];
site_flags_in_use = [];

se = se_full;
sites = sites_full;

% Name to use on files
nstem = findTextPath( dataset );

if sessionActive()
    sessionSectionBegin( ['Organize Records For ''' nstem '''']);
end

[ids, rec_num, order] = getExportNumbers( se, sites );
se = se( order );
sites = sites( order );

if sessionActive()
    sessionSectionEnd( ['Organize Records For ''' nstem '''']);
    sessionSectionBegin( ['Writing Files For ''' nstem '''']);
end

% Accumulators to know how much space is needed
max_source = 0;
max_flags = 0;
total_items = 0;

for k = 1:length(se)
    total_items = total_items + numItems( se(k) );
    
    sz = size( se(k).source );
    if sz(2) > max_source
        max_source = sz(2);
    end
    
    sz = size( se(k).flags );
    if sz(2) > max_flags
        max_flags = sz(2);
    end
end

% Placeholders for flags and sources
flag_code = '%i\t%i\t%7.3f\t';
for k = 1:max_flags
    flag_code = [flag_code '%i\t'];
end
flag_code(end-1:end+2) = '\r\n';

source_code = '%i\t%i\t%7.3f\t';
for k = 1:max_source
    source_code = [source_code '%i\t'];
end
source_code(end-1:end+2) = '\r\n';

output_dir = [temperature_data_dir 'Registered Data Sets' psep nstem];

% Open files and write headers
name_main = [output_dir 'data.txt'];
name_flags = [output_dir 'flags.txt'];
name_source = [output_dir 'sources.txt'];
checkPath( name_main );

fmain = fopen( name_main, 'w' );
fflags = fopen( name_flags, 'w' );
fsource = fopen( name_source, 'w' );

fprintf( fmain, '%s', main_header );
fprintf( fflags, '%s', flag_header );
fprintf( fsource, '%s', source_header );

try    
    block_size = 1000;
    
    buf_string = cell( block_size, 1 );
    buf_flags = cell( block_size, 1 );
    buf_source = cell( block_size, 1 );
    
    dflags = cell( block_size, 1 );
    sflags = cell( block_size, 1 );
    for block = 1:block_size:length(se)
        max_block = min( length(se), block+block_size-1 );
        timePlot( 'Writing Text Files', block/length(se) )
        
        se2 = se(block:max_block);
        ids2 = ids(block:max_block);
        rec_num2 = rec_num(block:max_block);
                
        parfor index = 1:max_block - block + 1
            sx = decompress(se2(index));
            count = numItems( sx );
            
            if count == 0
                continue;
            end
            
            nums = double( sx.num );
            nums( isnan(nums) ) = -99;
            
            tobs = double( sx.tob );
            tobs( isnan(tobs) ) = -99;
            
            flagv = sx.flags;
            if isempty( flagv )
                flagv( 1:count, 1 ) = 0;
            end
            flagv( isnan(flagv) ) = 0;
            flagv = double(flagv);
            s = size(flagv);
            flagv(:,s(2)+1:max_flags) = 0;
            
            dflags{index} = unique(flagv(:))';
            
            sourcev = sx.source;
            sourcev( isnan(sourcev) ) = 0;
            sourcev = double(sourcev);
            s = size(sourcev);
            sourcev(:,s(2)+1:max_source) = 0;
            
            sflags{index} = unique(sourcev(:))';
            
            dates = sx.dates;
            data = sx.data;
            unc = sx.uncertainty;
            dates = dates(:);
            data = data(:);
            
            data_block = [ ones(count,1)*ids2(index), ...
                ones(count,1)*rec_num2(index), ...
                dates, ...
                data, ...
                unc, ...
                nums, ...
                tobs];
            
            new_str = sprintf( '%i\t%i\t%8.3f\t%7.3f\t%7.4f\t%i\t%i\r\n', data_block' );
            buf_string{index} = new_str;
            
            new_str = sprintf( flag_code, [data_block(:, 1:3) flagv]' );
            buf_flags{index} = new_str;
            
            new_str = sprintf( source_code, [data_block(:, 1:3) sourcev]' );
            buf_source{index} = new_str;            
        end
        
        data_flags_in_use = union( data_flags_in_use, unique( [dflags{1:max_block-block+1}] ) );
        source_flags_in_use = union( source_flags_in_use, unique( [sflags{1:max_block-block+1}] ) );
        
        fprintf( fmain, '%s', [buf_string{1:max_block-block+1}] );
        fprintf( fflags, '%s', [buf_flags{1:max_block-block+1}]);
        fprintf( fsource, '%s', [buf_source{1:max_block-block+1}]);
    end
    
    timePlot( 'Writing Text Files', 1 )
catch e
    fclose( fmain );
    fclose( fflags );
    fclose( fsource );
    
    e.stack
    if sessionActive()
        sessionSectionEnd( ['Writing Files For ''' nstem '''']);
        sessionSectionEnd( 'Convert RegisteredDataSet to Text Format' );
    end

    error( e.message );
end

fclose( fmain );
fclose( fflags );
fclose( fsource );
writeShortSiteList( sites, dataset );

for k = 1:length( sites );
    site_flags_in_use = union( site_flags_in_use, sites(k).flags );
end

if sessionActive()
    sessionSectionEnd( ['Writing Files For ''' nstem '''']);
end

writeReadmeFile( dataset.collection, dataset );
writeLongSiteList( sites_full, dataset );
writeFlagList( data_flags_in_use, @dataFlags, 'data_flag_definitions', dataset );
writeFlagList( source_flags_in_use, @stationSourceType, 'source_flag_definitions', dataset );
writeFlagList( site_flags_in_use, @siteFlags, 'site_flag_definitions', dataset );

zip( [output_dir(1:end-1) '.zip'], '*.txt', output_dir );
pause(5);
try
    rmdir( output_dir, 's' );
catch     
    pause(120);
    try
        rmdir( output_dir, 's' );
    catch
        warning( 'Can''t remove output directory' );
    end
end

if sessionActive()
    sessionSectionEnd( 'Convert RegisteredDataSet to Text Format' );
    save( 'lastRegConvertToText', 'lastRegConvertToText' );
end


function [ids, rec_num, I] = getExportNumbers( data, sites )
% Assigns site ids and record numbers, as well as specifying the order in
% which the records should be exported
%
% Records are ordered by export ID number and then record numbers are
% assigned counting from the longest record to the shortest.

ids = getExportIds( sites );
[ids, I] = sort( ids );
data = data(I);

rec_num = ones( length(ids), 1 );

k = 1;
while k <= length(ids)
    j = k + 1;
    while j <= length(ids) && ids(j) == ids(k)
        j = j + 1;
    end
    j = j - 1;
    if j == k
        k = k + 1;
        continue;
    end
    
    c = zeros( j - k + 1, 1 );
    for p = k:j
        c(p - k + 1) = numItems( data(p) );
        
    end
    [~, I2] = sort(c);
    I2 = I2(end:-1:1);
    Ix = I(k:j);
    
    I(k:j) = Ix(I2);
    rec_num(k:j) = 1:(j-k+1);
    k = k + 1;
end


function writeFlagList( flags, flag_reference, name, dataset )
% Export flag values

temperatureGlobals;

flags = unique(flags);
flags( flags == 0 ) = [];

flag_text = cell( length(flags), 1 );
for k = 1:length(flags)
    flag_text{k} = flag_reference( flags(k) );
end

output_dir = [temperature_data_dir 'Registered Data Sets' psep findTextPath( dataset )];

head = formatHeader( {'Flag Code', 'Flag Description'}, name, dataset );
fout = fopen( [output_dir filesep name '.txt'], 'w' );
fprintf( fout, '%s', head );

for k = 1:length(flags)
    fprintf( fout, '  %4i:\t%s\r\n', flags(k), flag_text{k} );
end

fclose( fout );


function writeReadmeFile( name, dataset )
% Exports a short summary of the sites

temperatureGlobals;
output_dir = [temperature_data_dir 'Registered Data Sets' psep findTextPath( dataset )];

str_val = ['File Generated: ' datestr(now) char( [13, 10] )];
str_val = [str_val 'Dataset Collection: ' dataset.collection char( [13, 10] )];
str_val = [str_val 'Type: ' dataset.type char( [13, 10] )];
str_val = [str_val 'Version: ' dataset.version char( [13, 10] )];
str_val = [str_val 'Dataset Hash: ' num2str( md5hash( dataset ) ) char( [13, 10] )];
str_val = [str_val '' char( [13, 10] )];
str_val = [str_val '------------------------------------' char( [13, 10] )];
str_val = [str_val char( [13, 10] )];

fout = fopen( [output_dir filesep 'README.txt'], 'w' );
fname1 = [temperature_data_dir 'Dataset Descriptions' psep name '.txt'];
fname2 = [temperature_software_dir 'Dataset Core Functions' psep 'classes' ...
    psep '@registeredDataSet' psep 'Export Headers' ...
    psep 'text_header.README.txt'];


fprintf( fout, '%s', str_val );
try
    fprintf( fout, '%s', readFileBlock( fname1, '' ) );
catch
    fprintf( fout, '\n%s\n', ' ==== No Dataset Description File ==== ' );
    warning( 'registeredDataSet:writeReadmeFile', ['No Dataset Description File is Available for "' name '"'] );
end
str_val = char( [13, 10] );
str_val = [str_val '------------------------------------' char( [13, 10] )];
str_val = [str_val char( [13, 10] )];
fprintf( fout, '%s', str_val );

fprintf( fout, '%s', readFileBlock( fname2, '' ) );

fclose(fout);


function writeShortSiteList( sites, dataset )
% Exports a short summary of the sites

temperatureGlobals;
output_dir = [temperature_data_dir 'Registered Data Sets' psep findTextPath( dataset )];

ids = getExportIds( sites );
[ids, I] = unique( ids );
sites = sites(I);

fout = fopen( [output_dir filesep 'site_summary.txt'], 'w' );

head = formatHeader( {'Station ID', 'Latitude', 'Longitude', 'Elevation (m)'}, ...
    'site_summary', dataset );
fprintf( fout, '%s', head);

for k = 1:length(sites)
    lat = sites(k).lat;
    long = sites(k).long;
    elev = sites(k).elev;
    
    if isnan(lat)
        lat = -999;
    end
    if isnan(long)
        long = -999;
    end
    if isnan(elev)
        elev = -999;
    end
    
    fprintf( fout, '%i\t%9.4f\t%9.4f\t%7.2f\r\n', ids(k), lat, long, elev );
end

fclose(fout);


function writeLongSiteList( sites, dataset )
% Exports a long summary of the sites

ids = getExportIds( sites );
[ids, I] = unique( ids );
sites = sites(I);

temperatureGlobals;
output_dir = [temperature_data_dir 'Registered Data Sets' psep findTextPath( dataset )];

fout = fopen( [output_dir filesep 'site_detail.txt'], 'w' );

head = formatHeader( {'Station ID', 'Station Name', ...
    'Latitude', 'Longitude', 'Elevation (m)', 'Lat. Uncertainty', ...
    'Long. Uncertainty', 'Elev. Uncertainty (m)', ...
    'Country', 'State / Province Code', 'County', 'Time Zone', ...
    'WMO ID', 'Coop ID', 'WBAN ID', ...
    'ICAO ID', '# of Relocations', '# Suggested Relocations', ...
    '# of Sources', 'Hash'}, 'site_detail', dataset );
fprintf( fout, '%s', head);

for k = 1:length(sites)
    id = ids(k);
    lat = sites(k).lat;
    long = sites(k).long;
    elev = sites(k).elev;
    lat_unc = sites(k).lat_unc;
    long_unc = sites(k).long_unc;
    elev_unc = sites(k).elev_unc;
    
    name = sites(k).primary_name;
    country = sites(k).country;
    county = sites(k).county;
    state = sites(k).state;
    tz = sites(k).time_zone;
    
    wmo = sites(k).wmo_id;
    coop = sites(k).coop_id;
    wban = sites(k).wban_id;
    icao = sites(k).icao_id;
    
    num_reloc = length( sites(k).relocated );
    num_poss_reloc = length( sites(k).possible_relocated );
    num_sources = length( sites(k).sources );
    
    hash = num2str( md5hash( sites(k) ) );
    
    if isnan(lat)
        lat = -999;
        lat_unc = -9.9999;
    end
    if isnan(long)
        long = -999;
        long_unc = -9.9999;
    end
    if isnan(elev)
        elev = -999;
        elev_unc = -9.999;
    end
    if isnan(lat_unc)
        lat_unc = -9.9999;
    end
    if isnan(long_unc)
        long_unc = -9.9999;
    end
    if isnan(elev_unc)
        elev_unc = -9.999;
    end
    
    if iscell( state )
        state = '[Conflict]';
    end
    if iscell( county )
        county = '[Conflict]';
    end
    if isnan( county )
        county = '';
    end
    
    name = formatString( name );
    country = formatString( country );
    county = formatString( county );
    state = formatString( state );
    
    if isnan(tz)
        tz = -99;
    end
    
    if isempty(wmo)
        wmo = -9999;
    elseif length(wmo) > 1
        wmo = -5555;
    else
        wmo = wmo(1);
    end
    if isempty(coop)
        coop = -9999;
    elseif length(coop) > 1
        coop = -5555;
    else
        coop = coop(1);
    end
    if isempty(wban)
        wban = -9999;
    elseif length(wban) > 1
        wban = -5555;
    else
        wban = wban(1);
    end
    if isempty(icao)
        icao = formatString( '' );
    elseif length(icao) > 1
        icao = formatString( '[Conflict]' );
    else
        icao = formatString( icao{1} );
    end
    
    hash = formatString( hash );
    
%     id
%     name
%     lat
%     long
%     elev
%     lat_unc
%     long_unc
%     elev_unc
%     country
%     state
%     county
%     tz
%     wmo
%     coop
%     wban    
%     icao
%     num_reloc
%     num_poss_reloc
%     num_sources
%     hash
    fprintf( fout, ['%i\t%-40s\t%9.4f\t%9.4f\t%8.3f\t%7.4f\t%7.4f\t%6.3f\t' ...
        '%-40s\t%2s\t%-15s\t%3i\t%5i\t%6i\t%5i\t%6s\t%2i\t%2i\t%2i\t%s\r\n'], ...
        id, name, lat, long, elev, lat_unc, long_unc, elev_unc, ...
        country, state, county, tz, wmo, coop, wban, icao, ...
        num_reloc, num_poss_reloc, num_sources, hash );
end

fclose(fout);


function str_val = readFileBlock( fname, prefix )
% Reads a text file and turns it into a formatted block

fin = fopen( fname, 'r' );
A = char( fread( fin, Inf, 'char' ) )';
A = textwrap( cellstr(A), 80 );

if nargin < 2
    prefix = '% ';
end

str_val = '';
for k = 1:length(A)
    while length(A{k}) >= 1 && (A{k}(end) == 13 || A{k}(end) == 10)
        A{k}(end) = [];
    end
    str_val = [str_val prefix A{k} char( [13, 10] )];
end

fclose( fin );


function str_val = formatHeader(input, desc_file, dataset)
% Format header cells

temperatureGlobals;
fname = [temperature_software_dir 'Dataset Core Functions' psep 'classes' ...
    psep '@registeredDataSet' psep 'Export Headers' ...
    psep 'text_header.' desc_file '.txt'];

str_val = ['% File Generated: ' datestr(now) char( [13, 10] )];
str_val = [str_val '% Dataset Collection: ' dataset.collection char( [13, 10] )];
str_val = [str_val '% Type: ' dataset.type char( [13, 10] )];
str_val = [str_val '% Version: ' dataset.version char( [13, 10] )];
str_val = [str_val '% Dataset Hash: ' num2str( md5hash( dataset ) ) char( [13, 10] )];
str_val = [str_val '% ' char( [13, 10] )];
str_val = [str_val '% ------------------------------------' char( [13, 10] )];
str_val = [str_val '% ' char( [13, 10] )];

str_val = [str_val, readFileBlock( fname )];

str_val = [str_val '% ' char( [13, 10] )];

str_val = [str_val '% ' char( [13, 10] )];
str_val = [str_val '% ------------------------------------' char( [13, 10] )];
str_val = [str_val '% '];
for k = 1:length(input)
    str_val = [str_val input{k}];
    if k ~= length(input);
        str_val = [str_val, ', '];
    end
end

str_val = [str_val char(13), char(10)];
str_val = [str_val '% ' char( [13, 10] )];


function str_val = formatString( str_val )

str_val = strrep( str_val, char(9), ' ' );


function hash = getHash( dataset, name )

temperatureGlobals;
fname = [temperature_software_dir 'Dataset Core Functions' psep 'classes' ...
    psep '@registeredDataSet' psep 'Export Headers'];

hash(1) = md5hash( dataset );
hash(2) = md5hash( cleanMFile( which( mfilename('fullpath') ) ) );
dd = dir( fname );
for k = 1:length(dd)
    if ~dd(k).isdir
        fin = fopen( [fname psep dd(k).name], 'r' );
        text = fread( fin, Inf, '*char' )';
        fclose( fin );
        hash(k+2) = md5hash( text );
    end
end

fname1 = [temperature_data_dir 'Dataset Descriptions' psep name '.txt'];

try
    text = readFileBlock( fname1, '' );
catch
    text = ' ==== No Dataset Description File ==== ';
end
hash( end + 1) = md5hash(text);

hash = collapse( hash );

