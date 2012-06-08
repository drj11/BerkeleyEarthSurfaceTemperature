function mn = setEndDate( mn, dt )

if ~isa( mn.duration, 'timeRange' )
    tm1 = NaN;
    tm2 = timeInstant( dt );

    mn.duration = timeRange( timeInstant( tm1 ), ...
        tm2 );
else    
    tm2 = timeInstant( dt );
    tm1 = mn.duration.first_instant;

    mn.duration = timeRange( tm1, tm2 );    
end
  