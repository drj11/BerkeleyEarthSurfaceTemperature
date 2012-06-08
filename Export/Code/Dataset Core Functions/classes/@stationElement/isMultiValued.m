function res = isMultiValued( se )

dates = double( se.dates );
un = unique( dates );

res = ~( length( un ) == length( dates ) );
