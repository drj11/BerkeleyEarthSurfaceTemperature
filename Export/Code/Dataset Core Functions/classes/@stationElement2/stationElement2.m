function se = stationElement2( varargin )
% se = stationElement2( record_type, record_frequency )
%
% Constructor for stationElement class
%
% record_type includes standard codes such as "TAVG", "TMAX", "TMIN", etc.
% that are defined by stationRecordType.
%
% record_frequency includes codes such as "d", "m", "a", which indicate the
% data frequency and are defined by stationFrequencyType

% Init the fields
se.record_type = NaN;
se.frequency = NaN;
se.site = md5hash;
se.dates = [];
se.time_of_observation = [];
se.data = [];
se.uncertainty = [];
se.num_measurements = [];
se.flags = [];
se.source = [];
se.record_flags = [];
se.primary_record_ids = [];
se.md5hash = md5hash;
se.auto_compress = 0;

if nargin == 0   
    % Support for null constructor
    se = class( se, 'stationElement2' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'stationElement2' )        
        % Support for copy constructor
        se = v;
        return;
    elseif isa( v, 'stationElement' )
        v = builtin( 'struct', v );
        
        se.record_type = v.record_type;
        se.frequency = v.frequency;

        se.dates = transpose( v.dates );
        se.data = transpose( v.data );
        se.uncertainty = se.data*0;
        se.time_of_observation = transpose( v.time_of_observation );
        se.num_measurements = transpose( v.num_measurements );
        se.flags = v.flags;
        se.source = v.source;
        
        se = class( se, 'stationElement2' );
        se = compress( se );
    else        
        error( 'Incomplete input' );
    end
elseif nargin == 2
    
    % Standard constructor.
    v1 = varargin{1};
    v2 = varargin{2};
    
    if ~isnumeric(v1)
        v1 = stationRecordType( v1 );
        v1 = v1.index;
    end
    if ~isnumeric(v2)
        v2 = stationFrequencyType( v2 );
    end
    
    se.record_type = v1;
    se.frequency = v2;

    se = class( se, 'stationElement2' );
else
    error( 'Too many inputs' );
end

