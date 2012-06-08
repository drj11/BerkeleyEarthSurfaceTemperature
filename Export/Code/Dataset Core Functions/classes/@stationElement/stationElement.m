function se = stationElement( varargin )

se.record_type = NaN;
se.frequency = NaN;
se.dates = [];
se.time_of_observation = [];
se.data = [];
se.num_measurements = [];
se.flags = [];
se.source = [];
se.auto_compress = 0;

if nargin == 0    
    se = class( se, 'stationElement' );
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'stationElement' )
        se = v;
        return;
    else
        error( 'Incomplete input' );
    end
elseif nargin == 2
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

    se = class( se, 'stationElement' );
else
    error( 'Too many inputs' );
end

