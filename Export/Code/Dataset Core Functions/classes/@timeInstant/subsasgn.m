function val = subsref( ti, S, values);

val = subsasgn( struct(ti), S, values );
val.yearnum = NaN;
val.yearnum = yearnum( val );