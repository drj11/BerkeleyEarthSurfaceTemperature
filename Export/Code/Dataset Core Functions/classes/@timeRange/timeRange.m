function tr = timeRange( varargin )
% tr = timeRange( year, month, day, hour, minute, second );
% tr = timeRange( instant1, instant2 );
%
% Specifies a time range.

if nargin == 0
    tr.first = timeInstant();
    tr.last = timeInstant();
    
    tr = class( tr, 'timeRange' );
elseif nargin == 1
    if isa(varargin{1}, 'timeRange')
        tr = varargin{1};
    elseif isa(varargin{1}, 'double') && length(varargin{1}) == 1
        v = varargin{1};
        tr.first = timeInstant( round(v), 1, 1, 0, 0, 0 );
        tr.last = addInterval( tr.first, 1, 'year' );
        
        tr = class( tr, 'timeRange' );
    else
        error( 'Unrecognized arguments' );
    end
elseif nargin == 2
    if isa(varargin{1}, 'timeInstant') && isa(varargin{2}, 'timeInstant')
        v1 = varargin{1};
        v2 = varargin{2};
        if v1 > v2 && ~isnan( v1 ) && ~isnan( v2 );
            t = v1;
            v1 = v2;
            v2 = t;
        end
        tr.first = v1;
        tr.last = v2;
        
        tr = class( tr, 'timeRange' );
    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'double')
        v1 = varargin{1};
        v2 = varargin{2};
        if length(v1) == 1 && length(v2) == 1
            tr.first = timeInstant( round(v1), round(v2), 1, 0, 0, 0 );
            tr.last = addInterval( tr.first, 1, 'month' );
            tr = class( tr, 'timeRange' );
        else
            error( 'Unrecognized Arguments' );
        end
    else
        error( 'Unrecognized Arguments' );
    end
elseif nargin <= 6
    v = ones(1,6)*NaN;
    for k = 1:nargin
        if length(varargin{k}) == 1
            v(k) = round(varargin{k});
        else
            error( 'Inputs should have length 1.' );
        end
    end
    
    switch nargin
        case 3
            tr.first = timeInstant( v(1), v(2), v(3), 0, 0, 0 );
            tr.last = addInterval( tr.first, 1, 'day' );
        case 4
            tr.first = timeInstant( v(1), v(2), v(3), v(4), 0, 0 );
            tr.last = addInterval( tr.first, 1, 'hour' );
        case 5
            tr.first = timeInstant( v(1), v(2), v(3), v(4), v(5), 0 );
            tr.last = addInterval( tr.first, 1, 'minute' );
        case 6
            tr.first = timeInstant( v(1), v(2), v(3), v(4), v(5), v(6) );
            tr.last = addInterval( tr.first, 1, 'second' );
    end
    
    tr = class( tr, 'timeRange' );
else
    error( 'Too many inputs.' );
end