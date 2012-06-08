function [mean_value, std_high, std_low] = mapPeriodicity( means, var_high, var_low, dates )
% function [mean_value, std_high, std_low] = mapPeriodicity( means, var_high, var_low, dates )
% function [mean_value, std_high, std_low] = mapPeriodicity( result_struct, dates )

% Map structure into inputs.
if nargin == 2 && isstruct( means )
    dates = var_high;
    
    res = means;
    means = [res.mean_constant res.mean_periodicity'];
    var_high = [res.variance_constant_high res.variance_periodicity_high'];
    var_low = [res.variance_constant_high res.variance_periodicity_high'];
end

dates = dates(:);
degree = (length(means)-1) / 2;

A = zeros( length(dates), 2*degree + 1 );

A(:, 1) = 1;
dates_val = dates .* ones(length(dates),1)*(1:degree);

A( :, 2:degree + 1 ) = sin( 2*pi*dates_val );
A( :, degree + 2 : 2*degree + 1 ) = cos( 2*pi*dates_val );

mean_value = A*means';

if nargout > 1
    var_high_value = A*var_high';
    var_low_value = A*var_low';

    f = (var_high_value < 1e-4);
    var_high_value(f) = 1e-4;

    f = (var_low_value < 1e-4);
    var_low_value(f) = 1e-4;

    std_high = sqrt(var_high_value);
    std_low = sqrt(var_low_value);
end