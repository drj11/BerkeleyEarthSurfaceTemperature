function mn = stationManifest( varargin )

mn.source = NaN;
mn.ids = {};
mn.climate_division = NaN;
mn.country = NaN;
mn.state = '';
mn.county = NaN;
mn.duration = NaN;
mn.location = NaN;
mn.time_zone = NaN;
mn.name = {};
mn.location_precision = NaN;
mn.alt_elevation = NaN;
mn.alt_elevation_type = NaN;
mn.reloc = NaN;
mn.station_type = NaN;

if nargin == 0    

    mn = class( mn, 'stationManifest' );
elseif nargin == 1
    if isa(varargin{1}, 'stationManifest' )
        mn = varargin{1};
    elseif isa(varargin{1}, 'char')
        st = varargin{1};

        switch length(st)
            case 294
                mn = processMMTSstring( mn, st );
            case 136
                mn = processUSSODCstring( mn, st(10:end) );
            case 127
                mn = processUSSOMstring( mn, st );
            case 110                
                mn = processUSSODFstring( mn, st(11:end) );
            case 101
                mn = processGHCNMstring( mn, st );
            case 79
                mn = processGSODstring( mn, st );
            case 90
                mn = processUSHCNMstring( mn, st );
            case 85
                mn = processGHCNstring( mn, st );
            case 64
                mn = processSCARstring( mn, st );
            otherwise
                if strcmp( st(1:7), 'Number=' )
                    mn = processHadCRUstring( mn, st );
                elseif strcmp( st(1:6), 'WMSSC:' )
                    mn = processWMSSCstring( mn, st(8:end) );
                else
                    length( st )
                    st
                    error( 'StationManifest called with unrecognizable input' );
                end
        end

        mn = class( mn, 'stationManifest' );
    else
        error( 'StationManifest called with argument of wrong type' );
    end
else
    error( 'StationManifest called with too many arguments' );
end    
