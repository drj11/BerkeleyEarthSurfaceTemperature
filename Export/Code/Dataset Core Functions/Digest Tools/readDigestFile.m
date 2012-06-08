function dat = readDigestFile( fname )
% Reads the contents of a digest file and loads it into a matlab structure.

temperatureGlobals;

persistent digest_reader_cache
if isempty(digest_reader_cache)
    digest_reader_cache = dictionary();
end

dd = dir( [temperature_data_dir fname '.digest'] );
try
    rec = digest_reader_cache( fname );
    if strcmp( dd(1).date, rec.date ) 
        dat = rec.entry;
        return;
    end
catch
end

dat = struct;

fin = fopen( [temperature_data_dir fname '.digest'], 'r' );
while ~feof(fin);
    A = fgetl(fin);
    
    f = find(A == ':');
    nm = A(1:f(1)-1);
    val = strtrim(A(f(1)+1:end));
    
    nm = strrep( lower(nm), ' ', '_' );

    switch lower(nm)
        case {'accessed', 'accesed', 'generated', 'created'}
            if ~isempty(find(val == '.'))
                val = datevec( val, 'yyyy-mm-ddTHH:MM:SS.FFF' );
            else
                val = datevec( val, 'yyyy-mm-ddTHH:MM:SS' );
            end
        case {'dependency'}
            f = find(val == ' ');
            fn = val(f(1)+1:end);
            hash = val(1:f(1)-1);
            if ismember('dependency', fields(dat))
                val = {dat.dependency{:}, {hash, fn}};
            else
                val = {{hash, fn}};
            end
    end

    eval( ['dat.' nm ' = val;'] );
end

fclose(fin);

rec.entry = dat;
rec.date = dd(1).date;
digest_reader_cache( fname ) = rec;

if length(digest_reader_cache) > 5000
    digest_reader_cache = dictionary();
end
