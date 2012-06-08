function mn = stationManifest2( varargin )
% Constructor for stationManifest class

mn.source = NaN;
mn.ids = {};
mn.climate_division = NaN;
mn.country = NaN;
mn.state = '';
mn.county = NaN;
mn.duration = NaN;
mn.location = NaN;
mn.time_zone = NaN;
mn.instrument_type = NaN;
mn.name = {};
mn.alt_elevation = NaN;
mn.alt_elevation_type = NaN;
mn.reloc = NaN;
mn.site_flags = [];
mn.original_line = '';
mn.archive_key = '';
mn.hash = md5hash;

if nargin == 0
    mn = class( mn, 'stationManifest2' );
elseif nargin == 1
    if isa(varargin{1}, 'stationManifest2' )
        mn = varargin{1};
    else
        error( 'Called with argument of wrong type' );
    end
elseif nargin == 2
    source = varargin{1};
    st = varargin{2};
    if ischar( st ) && isnumeric( source )
        if strcmp( st(1:7), 'MISSING' )
            mn = addMissing( mn, source, st(9:end) );
            mn.original_line = st;
            mn.hash = computeHash( mn );
            return;
        end
        
        switch source
            case 75
                 mn = processMMTSstring( mn, st );
            case 3
                mn = processGHCNstring( mn, st );
            case 2
                mn = processUSSODCstring( mn, st );
            case 36
                mn = processUSSOMstring( mn, st );
            case 1
                mn = processUSSODFstring( mn, st );
            case 30
                mn = processGHCNMstring( mn, st );
            case 4
                mn = processGSODstring( mn, st );
            case 37
                mn = processUSHCNMstring( mn, st );
            case 38
                mn = processWMSSCstring( mn, st );
            case 34
                mn = processSCARstring( mn, st );
            case 35
                mn = processHadCRUstring( mn, st );
            case 53
                mn = processGSNMONstring( mn, st );
            case 54
                mn = processMCDWstring( mn, st );
            case 55
                mn = processGCOSstring( mn, st );
            case 56
                mn = processGHCNM3string( mn, st );
            case 76
                mn = processWWRstring( mn, st );
            case 77
                mn = processCAstring( mn, st );
            case 78
                mn = processWMOstring( mn, st );
            otherwise
                error( 'StationManifest2 called with unrecognizable source' );
        end
        
        mn.source = source;
        mn.original_line = st;
        
        mn = class( mn, 'stationManifest2' );
    else
        error( 'StationManifest2 called with argument of wrong type' );
    end
else
    error( 'StationManifest2 called with too many arguments' );
end

mn.site_flags = sort(mn.site_flags);
mn.ids = sort(mn.ids);
mn.name = sort(mn.name);

mn.hash = computeHash( mn );


function mn = addMissing( mn, source, id )
% Formats a missing id based on source type

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    [country_codes_dictionary] = loadCountryCodes();
end

switch source
    case 3
        type_code = id(3);
        id2 = id(4:11);
        switch type_code
            case 'W'
                mn.ids = {['wban_' num2str(str2double(id2))]};
            case 'C'
                mn.ids = {['coop_' num2str(str2double(id2))]};
            case 'M'
                mn.ids = {['wmo_' num2str(str2double(id2))]};
            otherwise
        end
        
        FIPS = id(1:2);
        mn.country = country_codes_dictionary(FIPS);
        
        mn.ids{end+1} = ['ghcnd_' id];
        mn.archive_key = ['GHCN-D_' id];
    case {2, 36, 37}
        id2 = str2double(id);
        switch source
            case 2
                mn.archive_key = ['USSOD-C_' num2str(id2)];
            case 36
                mn.archive_key = ['USSOM' num2str(id2)];
            case 37
                mn.archive_key = ['USHCN-M_' num2str(id2)];
                mn.country = country_codes_dictionary( 'UNITED STATES' );
        end
        mn.ids{end+1} = ['coop_' num2str( id2 )];
    case 1
        mn.ids{end+1} = ['wban_' num2str( str2double(id) )];
        mn.archive_key = ['USSOD-FO_' num2str( str2double(id) )];
        
        % Presumptive US, but not all stations actually are.
        mn.country = country_codes_dictionary( 'UNITED STATES' );        
    case {30, 56}
        mn.ids{end+1} = ['ghcnm_' id];

        if source == 30
            mn.archive_key = ['GHCN-M_' id];
        else
            mn.archive_key = ['GHCN-M3_' id];
        end
        
        if strcmp(id(end-2:end), '000')
            mn.ids{end+1} = ['wmo_' num2str( str2double( id(4:end-3) ) )];
        end
        
        try
            mn.country = country_codes_dictionary(['cc' id(1:3)]);
        catch
            mn.country = 0;
        end        
    case 4
        USAF_id = str2double(id(1:6));
        if ~(USAF_id == 999999 || USAF_id == 949999 || USAF_id == 49999)
            mn.ids{end+1} = ['usaf_' num2str(USAF_id)];
        end

        WBAN_id = str2double(id(8:12));
        if WBAN_id ~= 99999
            mn.ids{end+1} = ['wban_' num2str(WBAN_id)];
        end

        GSOD_id = [id(1:6) '-' id(8:12)];
        mn.archive_key = ['GSOD_' GSOD_id];
        if ~strcmp( GSOD_id, '999999-99999' )
            mn.ids{end+1} = ['gsod_' GSOD_id];
        end
    case 38        
        mn.ids{end+1} = ['wmssc_' num2str( str2double( id ) )];
        mn.archive_key = ['WMSSC_' num2str( str2double( id ) )];
    case 34
        mn.ids{end+1} = ['wmo_' num2str( str2double( id ) )];
        mn.archive_key = ['SCAR_' num2str( str2double( id ) )];
    case 35
        mn.ids{end+1} = ['hadcru_' num2str( str2double( id ) )];
        mn.archive_key = ['HadCRU_' num2str( str2double( id ) )];
    case 53
        mn.ids{end+1} = ['wmo_' num2str( str2double( id ) )];
        mn.archive_key = ['GSNMON_' num2str( str2double( id ) )];
    case 54        
        mn.ids{end+1} = ['wmo_' num2str( str2double( id ) )];
        mn.archive_key = ['MCDW_' num2str( str2double( id ) )];
    case 76        
        mn.ids{end+1} = ['wmo_' num2str( str2double( id ) )];
        mn.archive_key = ['WWR_' num2str( str2double( id ) )];
    otherwise
        error( 'Source id code unknown' );
end

mn.source = source;
mn.location  = geoPoint2( NaN, NaN, NaN );
mn.name = { ['Missing Station ID - ' id ] };
mn.ids = sort(mn.ids);
mn.site_flags(end+1) = siteFlags( 'MISSING_SITE' );
mn = class( mn, 'stationManifest2' );
        
