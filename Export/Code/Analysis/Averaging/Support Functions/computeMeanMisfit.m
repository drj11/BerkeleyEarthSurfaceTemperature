function [sigma, sigma_full] = computeMeanMisfit( ...
    data_array, dates_array, t_res, b_res, map, near_index, options )
% Compute the mean quality of fit globally.

if matlabPoolSize > 1
    spmd
        [A,B] = globalIndices( data_array, 1 );
        
        [dcount, dlist, dlist2] = reallyComputeMeanMisfit( ...
            getLocalPart( data_array ), ...
            getLocalPart( dates_array ), ...
            t_res, b_res(A:B), map, near_index(A:B), options );
        
        dcount = gplus( dcount, 1 );
        dlist = gplus( dlist, 1 );
        dlist2 = gplus( dlist2, 1 );
    end
    dcount = dcount{1};
    dlist = dlist{1};
    dlist2 = dlist2{1};    
else
    [dcount, dlist, dlist2] = reallyComputeMeanMisfit( ...
        data_array, dates_array, t_res, b_res, map, near_index, options );
end

% Determine RMS across all of the data
sigma = sqrt( dlist / dcount ); % Local
sigma_full = sqrt( dlist2 / dcount ); % Global


function [dcount, dlist, dlist2] = reallyComputeMeanMisfit( ...
    data_array, dates_array, t_res, b_res, map, near_index, options )

len_s = length(data_array);

dlist = 0;
dlist2 = 0;
dcount = 0;

for j = 1:len_s
    if isnan( b_res(j) )
        % Station was underconstrained, skip.
        % Does this ever still happen?
        continue;
    end
    
    % Load data from station
    monthnum = dates_array{j};
    data = data_array{j};
    
    fs = isnan( t_res( monthnum ) );
    monthnum(fs) = [];
    data(fs) = [];
    if isempty( monthnum )
        continue;
    end
    
    if options.LocalMode
        % If local, adjust from local anomaly map
        compare = map( near_index( j ), monthnum ) + t_res( monthnum )';
    else
        compare = t_res( monthnum )';
    end
    
    % Measure quality of fit.
    list_sum = sum((data' - compare - b_res(j)).^2);
    dlist = dlist + list_sum;
    list_count = length( data );
    dcount = dcount + list_count;
    
    list_sum = sum((data' - t_res( monthnum )' - b_res(j)).^2);
    dlist2 = dlist2 + list_sum;
end


