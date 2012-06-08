function val = subsref( ti, S );

if strcmp(S(1).type, '.')
    if length(ti) > 1
        for k = 1:length(ti)
            val(k) = subsref( ti(k), S );
        end
    else
        switch lower( S(1).subs )
            case { 'year', 'y' }
                val = ti.year;
            case { 'month', 'mon', 'mo' }
                val = ti.month;
            case { 'day', 'd' }
                val = ti.day;
            case { 'hour', 'h' }
                val = ti.hour;
            case { 'minute', 'min', 'mi' }
                val = ti.minute;
            case { 'second', 's' }
                val = ti.second;
            case { 'datenum' }
                val = datenum(ti);
            case { 'yearnum' }
                val = yearnum(ti);
            otherwise
                error( 'Unknown TimeInstant property' );
        end
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( ti( S(1).subs{:} ), S(2:end) );
    else
        val = ti( S(1).subs{:} );
    end
else
    error( 'Cell array of TimeInstant not supported' );
end