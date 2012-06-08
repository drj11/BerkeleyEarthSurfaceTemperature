function res = isMultiValued( se )

res = false( length(se), 1 );
for k = 1:length(se)
    dates = double( se(k).dates );
    un = unique( dates );
    
    res(k) = ~( length( un ) == length( dates ) );
end