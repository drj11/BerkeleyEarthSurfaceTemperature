% This example script lists the number of stations by country and the 
% number of measurements per stations.

% Load the 2% sample monthly average values
[se_m, sites_m] = loadTemperatureData( '2% Sample', 'Averaged', 'Monthly', 'TAVG' );

% Load the 2% sample daily average values
[se_d, sites_d] = loadTemperatureData( '2% Sample', 'Averaged', 'Daily', 'TAVG' );

% Create lists of country ids
countries_m = [sites_m(:).country_code];
countries_d = [sites_d(:).country_code];

% List of distinct countries
un_c = unique( union( countries_m, countries_d ) );

% Create Results List
results = zeros( length( un_c ), 3 );
results(:,1) = un_c;

% Loop over each monthly site
for k = 1:length(se_m)
    % Get Data
    [dates, data] = getData( se_m(k) );
    
    % Find location in result table
    fk = quickSearch( countries_m(k), un_c );
    
    % Update Monthly Count
    results(fk,2) = results(fk,2) + length(data);
end
    
% Loop over each daily site
for k = 1:length(se_d)
    % Get Data
    [dates, data] = getData( se_d(k) );
    
    % Find location in result table
    fk = quickSearch( countries_d(k), un_c );
    
    % Update Daily Count
    results(fk,3) = results(fk,3) + length(data);
end



