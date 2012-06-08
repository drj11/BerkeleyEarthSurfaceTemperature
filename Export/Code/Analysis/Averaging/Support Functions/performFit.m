function [t_res, b_res] = performFit( base_map, base_constants, temperature_map, ...
    temperature_constant, cross_map, all_station_mix )
% Actually computes the fit parameters for global temperature and station
% baseline.

sessionSectionBegin( 'Perform Fit' );

pool_size = matlabPoolSize();
if pool_size == 0 
    pool_size = 1;
end

% Remove baseline ambiguity by setting global baseline average to zero
base_mix = all_station_mix*base_map;
base_mix_constant = all_station_mix*base_constants;

mix_map = full( cross_map'*base_map );
temperature_map_mix = bsxfun( @minus, temperature_map - mix_map, base_mix ) ;
temperature_constant_mix = temperature_constant - cross_map'*base_constants - base_mix_constant;

len_t = length( temperature_constant );

% Eliminate any entries that are unconstrained
f = find( sum(temperature_map_mix, 1) == 0 );
temperature_map_mix(:,f) = [];
temperature_map_mix(f,:) = [];
temperature_constant_mix(f) = [];

new_map = 1:len_t;
new_map(f) = [];

while condest( temperature_map_mix ) > 1e6
    temperature_map_mix = temperature_map_mix(2:end, 2:end);
    temperature_constant_mix = temperature_constant_mix(2:end);
    new_map(1) = [];
end

% Use parallel processing if available
if exist( 'distributed', 'file' ) && pool_size > 1
    temperature_map_mix = distributed( temperature_map_mix );
    temperature_constant_mix = distributed( temperature_constant_mix );
end

% Solve for temperature series
t_fit = temperature_map_mix \ temperature_constant_mix;

t_res = ones( len_t, 1 ).*NaN;
if exist( 'distributed', 'file' ) && pool_size > 1
    t_res( new_map ) = gather( t_fit );
else
    t_res( new_map ) = t_fit;
end

% Compute baseline values
b_res = base_constants - base_map( :, new_map )*t_res(new_map);

% Residual zeroing, due to round off error, etc.
t_res = t_res + all_station_mix*b_res;
b_res = b_res - all_station_mix*b_res;

sessionSectionEnd( 'Perform Fit' );
