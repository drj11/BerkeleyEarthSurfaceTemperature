function res = stationID( varargin )

temperatureGlobals;
persistent station_id_codes station_id_data
persistent sources_allowed source_codes_allowed;

psep = filesep();

if isempty( station_id_codes )
    try
        load( [temperature_data_dir 'Unique ID Codes' psep 'record_id_assignments'] );
    catch
        station_id_data = struct();
        station_id_codes = dictionary();
        error( 'Station ID Data Missing' );
    end
end

if isempty( sources_allowed )
    source_codes_allowed = {'GHCN-D', 'GHCN-M', 'USSOD-C', 'USSOD-FO', ...
        'GSOD', 'Merged', 'SCAR', 'HadCRU', 'USSOM', 'USHCN-M', 'WMSSC', ...
        'Synthesis', 'Duplicate' };
    
    sources_allowed = [];
    for k = 1:length(source_codes_allowed)
        sources_allowed(k) = stationSourceType( source_codes_allowed{k} );
    end
end

nargs = nargin;
vargs = varargin;

if nargin == 0
    error( 'Need Input' );
end

if strcmp( vargs{end}, 'save' )
    saves = 1;
    vargs = vargs(1:end-1);
    nargs = nargs - 1;
    
    if nargs == 0
       save( [temperature_data_dir 'Unique ID Codes' sep 'record_id_assignments'], ...
           'station_id_codes', 'station_id_data' );
       return;
    end
        
elseif strcmp( vargs{end}, 'no-save' )
    saves = -1;
    vargs = vargs(1:end-1);
    nargs = nargs - 1;
else
    saves = 0;
end

if nargs == 1
    code = vargs{1};
    if isa( code, 'char' )
        try
            res = station_id_codes( code );
        catch
            error( ['Code "' code '" Not Found'] );
        end
    elseif isnumeric( code )
        res = station_id_data( code );
    else
        error( 'Code Type Unknown' );
    end
elseif nargs == 2
    source = vargs{1};
    code = vargs{2};

    if isa( source, 'char' )
        source = stationSourceType( source );
    end
    
    fk = findk( sources_allowed, source );
    if sources_allowed(fk) ~= source
        error( 'Not Permitted Source Code' );
    end
    
    code2 = [source_codes_allowed{fk} ': ' code];
    
    try
        index = station_id_codes( code2 );
    catch
        disp( ['Allocating new code: ' code2] );
        station_id_codes( code2 ) = length(station_id_data) + 1;
        
        index = length(station_id_data) + 1;
        
        station_id_data(index).source = source;
        station_id_data(index).code = code;
        
        if saves == 0 
            saves = 1;
        end        
    end
    
    res = index;
end

if saves == 1
   save( [temperature_data_dir 'Unique ID Codes' psep 'record_id_assignments'],...
       'station_id_codes', 'station_id_data' );
end
    