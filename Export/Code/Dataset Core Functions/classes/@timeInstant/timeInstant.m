function ti = timeInstant( varargin )
% ti = timeInstant( year, month, day, hour, minute, second );
% ti = timeInstant( datevec );
% ti = timeInstant( datestr );
% ti = timeInstant( datenum );
% ti = timeInstant( yearnum );
%
% Specifies an instant in time.

if nargin == 0
    ti.year = NaN;
    ti.month = NaN;
    ti.day = NaN;
    ti.hour = NaN;
    ti.minute = NaN;
    ti.second = NaN;
    ti.yearnum = NaN;
    
    ti = class( ti, 'timeInstant' );
elseif nargin == 1
    if isa(varargin{1}, 'timeInstant')
        ti = varargin{1};
    else
        v = varargin{1};
        if isa(v, 'char')
            v = datevec(v);
            ti.year = v(1);
            ti.month = v(2);
            ti.day = v(3);
            ti.hour = v(4);
            ti.minute = v(5);
            ti.second = v(6);
        elseif length(v) == 6
            ti.year = v(1);
            ti.month = v(2);
            ti.day = v(3);
            ti.hour = v(4);
            ti.minute = v(5);
            ti.second = v(6);
        elseif length(v) == 1 && isa(v,'double')
            if v(1) > 3000
                v = datevec(v);
                ti.year = v(1);
                ti.month = v(2);
                ti.day = v(3);
                ti.hour = v(4);
                ti.minute = v(5);
                ti.second = floor(v(6)*10^4) / 10^4;
            else
                ti.year = floor(v(1));
                
                date1 = datenum( [ti.year, 1, 1] );
                date2 = datenum( [ti.year + 1, 1, 1] );
                
                dur = date2 - date1;
                pos = (v(1) - ti.year)*dur + date1;
                
                v = datevec(pos);
                
                ti.month = v(2);
                ti.day = v(3);
                ti.hour = v(4);
                ti.minute = v(5);
                ti.second = floor(v(6)*10^4)/10^4;
            end
        else
            error( 'TimeInstant called with argument of wrong type' );
        end
        ti.yearnum = NaN;
        
        ti = class( ti, 'timeInstant' );
        ti.yearnum = yearnum( ti );
    end
elseif nargin >= 2 && nargin <= 6
    v = ones(1,6)*NaN;
    for k = 1:nargin
        if length(varargin{k}) == 1
            v(k) = varargin{k};
        else
            error( 'Inputs should have length 1.' );
        end
    end
    ti.year = v(1);
    ti.month = v(2);
    ti.day = v(3);
    ti.hour = v(4);
    ti.minute = v(5);
    ti.second = v(6);
    
    ti.yearnum = NaN;
    ti = class( ti, 'timeInstant' );
    ti.yearnum = yearnum( ti );
else
    error( 'Too many inputs.' );
end

if daysInMonth(ti) < ti.day || ti.day < 1 
    error( 'Specified Day is Out of Bounds.' );
elseif ti.hour >= 24 || ti.hour < 0
    error( 'Specified Hour is Out of Bounds.' );
elseif ti.month > 12 || ti.month < 1
    error( 'Specified Month is Out of Bounds.' );
elseif ti.minute >= 60 || ti.minute < 0
    error( 'Specified Minute is Out of Bounds.' );
elseif ti.second >= 60 || ti.second < 0
    struct(ti)
    error( 'Specified Second is Out of Bounds.' );
end
