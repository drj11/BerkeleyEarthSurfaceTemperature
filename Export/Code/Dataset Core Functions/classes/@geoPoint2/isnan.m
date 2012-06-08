function result = isnan( gp )
% Returns true if the latitude or longitude is not set.

result = ( isnan([gp(:).latitude]) | isnan([gp(:).longitude]) );
    
result = reshape( result, size( gp ) );