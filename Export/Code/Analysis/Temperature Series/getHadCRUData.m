function [times, globe, land, month_times, month_globe, month_land] = getHadCRUData()
% Load HadCRU temperature series

temperatureGlobals;
updateHadCRUData;

names = {'global_annual', 'global_land_annual', ...
    'global_monthly', 'global_land_monthly'};
for k = 1:length(names)
    load( [temperature_raw_dir 'HadCRU_Result' filesep names{k} '.mat'] );
end

times = HadCRU_global_annual(:,1);
globe = HadCRU_global_annual(:,2);
land = HadCRU_global_land_annual(:,2);

times2 = unique( [HadCRU_global_monthly(:,1);  ...
    HadCRU_global_land_monthly(:,1)] );
result = zeros( length(times2), 2 ) * NaN;
result( 1:length( HadCRU_global_monthly(:,1) ), 1 ) = HadCRU_global_monthly(:,2);
result( 1:length( HadCRU_global_land_monthly(:,1) ), 2 ) = HadCRU_global_land_monthly(:,2);
month_times = times2;


month_globe = result(:, 1);
month_land = result(:, 2);