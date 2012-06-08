function mn = setStartDate( mn, dt )

if ~isa( mn.duration, 'timeRange' )

    tm1 = timeInstant( dt );
    tm2 = NaN;

    mn.duration = timeRange( tm1, ...
        timeInstant( tm2 ) );
else
    
    tm1 = timeInstant( dt );
    tm2 = mn.duration.last_instant;

    mn.duration = timeRange( tm1, tm2 );
    
end
  