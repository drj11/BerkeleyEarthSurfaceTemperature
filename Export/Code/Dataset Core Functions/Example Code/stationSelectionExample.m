% Load the 2% sample monthly average values with seasonality removed
[se, sites] = loadTemperatureData( '2% Sample', 'Detrended', 'Monthly', 'TAVG' );

% List of locations
locations = [sites(:).location];

%Example: Find sites near a fixed location
target_location = geoPoint( 40, -90 );  %Create reference point at 35 N, 90 W
dist = distance( locations, target_location );  %Compute distances in km
select = find( dist <= 250 ); %Find stations less than 250 km away.

nearby_se = se( select );
nearby_sites = sites( select );


%Example: Find site by name
select = findByName( sites, 'DALLAS' );  %Anywhere in primary name
select = findByName( sites, 'KEMP', 'exact' );  %Exact match in primary name
select = findByName( sites, 'LAKE', 'alt' );  %Anywhere in primary or alternate names
select = findByName( sites, 'LAKE', 'alt', 'exact' );  %Exact match in primary or alternate name


%Example: List of primary names
name = [sites(:).name];


%Example: Find stations by country
country_code = stationCountryCode( 'Spain' );
cc = [sites(:).country_code];
select = find( cc == country_code );