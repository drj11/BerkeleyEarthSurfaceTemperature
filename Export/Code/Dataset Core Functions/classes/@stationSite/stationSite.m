function ss = stationSite( varargin )

ss.id = 0;
ss.other_ids = {};
ss.country = NaN;
ss.state = '';
ss.county = NaN;
ss.location = NaN;
ss.all_locations = [];
ss.all_location_times = [];
ss.time_zone = NaN;
ss.primary_name = '';
ss.alt_names = {};
ss.relocated = [];
ss.possible_relocated = [];
ss.associated_uids = [];
ss.flags = [];
ss.sources = [];

if nargin == 0    
    ss = class( ss, 'stationSite' );
elseif nargin == 1
    if isa(varargin{1}, 'stationSite' )
        ss = varargin{1};
    elseif isa(varargin{1}, 'stationManifest')
        input = varargin{1};

        ss = class( ss, 'stationSite' );
        ss = computeFromManifestList( ss, input );
    else
        error( 'StationSite called with argument of wrong type' );
    end
else
    error( 'StationSite called with too many arguments' );
end    
