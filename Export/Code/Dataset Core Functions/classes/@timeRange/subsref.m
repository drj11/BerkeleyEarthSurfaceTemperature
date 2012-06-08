function val = subsref( ti, S )

if strcmp(S(1).type, '.')
    if length(ti) > 1
        for k = 1:length(ti)
            val(k) = subsref( ti(k), S );
        end
    else
        switch lower( S(1).subs )
            case { 'first','start', 'st' }
                val = yearnum(ti.first);
            case { 'end', 'last' }
                val = yearnum(ti.last);
            case { 'first_instant' }
                val = ti.first;
            case { 'last_instant' }
                val = ti.last;
            case { 'days' }
                val = datenum( ti.last ) - datenum( ti.first );
            case { 'years' }
                val = yearnum( ti.last ) - yearnum( ti.first );
            case { 'hours' }
                val = (datenum( ti.last ) - datenum( ti.first )) * 24;
            case { 'mid', 'middle' }
                val = (yearnum( ti.last ) + yearnum( ti.first )) / 2;
            otherwise
                error( 'Unknown TimeRange property' );
        end
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( ti( S(1).subs{:} ), S(2:end) );
    else
        val = ti( S(1).subs{:} );
    end
else
    error( 'Cell array of TimeRange not supported' );
end