function ss = stationSite2( varargin )
% ss = stationSite2( StationManifests, [StationManifests] )
%
% Constructor for StationSite class
%
% Takes as input one or two lists of stationManifests.  The information in
% each list is combined to create a best guess of the true station details.
% The second list is considered "supplemental" and is only used to fill in
% information that is completely missing after considering the first list.

ss.ids = {};
ss.country = NaN;
ss.state = '';
ss.county = '';
ss.location = geoPoint2( NaN, NaN );
ss.all_locations = [];
ss.all_location_times = [];
ss.time_zone = NaN;
ss.instrument_type = NaN;
ss.primary_name = '';
ss.alt_names = {};
ss.relocated = [];
ss.possible_relocated = [];
ss.instrument_changes = [];
ss.primary_manifests = [];
ss.secondary_manifests = [];
ss.flags = [];
ss.sources = [];
ss.archive_keys = {};
ss.hash = md5hash();

if nargin == 0    
    ss = class( ss, 'stationSite2' );
elseif nargin == 1
    if isa(varargin{1}, 'stationSite2' )
        ss = varargin{1};
    elseif isa(varargin{1}, 'stationSite' )
        sa = varargin{1};
        ss.ids = sa.other_ids;
        ss.country = sa.country_code;
        ss.state = sa.state;
        ss.county = sa.county;     
        if isa( sa.location, 'geoPoint' )
            ss.location = geoPoint2( sa.location );
        end            
        ss.all_locations = sa.all_locations;
        ss.all_location_times = sa.all_location_times;
        ss.primary_name = sa.name;
        ss.alt_names = sa.alt_names;
        ss.relocated = sa.relocated;
        ss.possible_relocated = sa.possible_relocated;
        ss.sources = sa.source;
        ss = class( ss, 'stationSite2' );
    elseif isa(varargin{1}, 'stationManifest2')
        input = varargin{1};

        ss = class( ss, 'stationSite2' );
        ss = computeFromManifestList( ss, input );
    else
        error( 'StationSite2 called with argument of wrong type' );
    end
elseif nargin == 2
    if isa(varargin{1}, 'stationManifest2') && isa(varargin{2}, 'stationManifest2')
        input1 = varargin{1};
        input2 = varargin{2};

        ss = class( ss, 'stationSite2' );
        ss = computeFromManifestList( ss, input1, input2 );
    else
        error( 'StationSite2 called with argument of wrong type' );
    end
else
    error( 'StationSite2 called with too many arguments' );
end    

ss.flags = unique( ss.flags );
ss.sources = sort( ss.sources );
ss.primary_manifests = sort( ss.primary_manifests );
ss.secondary_manifests = sort( ss.secondary_manifests );
ss.relocated = sort( ss.relocated );
ss.possible_relocated = sort( ss.possible_relocated );
ss.alt_names = sort( ss.alt_names );
ss.ids = sort( ss.ids );
ss.archive_keys = sort( ss.archive_keys );

ss.hash = computeHash( ss );

