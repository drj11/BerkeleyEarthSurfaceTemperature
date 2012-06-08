function ti = addInterval( t0, value, type )

v0 = datenum( t0 );

switch lower(type)
    case {'days','d','day'}
        v0 = v0 + value;
        ti = timeInstant( v0 );
    case {'hour','h','hours'}
        v0 = v0 + value / 24;
        ti = timeInstant( v0 );
    case {'minutes','mi','min','mins','minute'}
        v0 = v0 + value / 24 / 60;
        ti = timeInstant( v0 );
    case {'second','s','seconds','sec','secs'}
        v0 = v0 + value / 24 / 60 / 60;
        ti = timeInstant( v0 );
    case {'months','mo','mon','month','mons'}
        v0 = datevec( t0 );
        v0(2) = v0(2) + value;
        while v0(2) > 12
            v0(2) = v0(2) - 12;
            v0(1) = v0(1) + 1;
        end
        while v0(2) < 1
            v0(2) = v0(2) + 12;
            v0(1) = v0(1) - 1;
        end
        ti = timeInstant( v0 );
    case {'year','years','y','yr','yrs'}
        v0 = yearnum(ti);
        v0 = v0 + value;
        ti = timeInstant( v0 );
    otherwise
        error( 'Interval term not recognized.' );
end
        