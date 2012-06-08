function [times, globe, land, month_times, month_globe, month_land] = getNOAAData()
% Load NOAA temperature series

temperatureGlobals;
updateNOAAData;

names = {'global_annual', 'land_annual', ...
    'global_monthly', 'land_monthly'};
for k = 1:length(names)
    load( [temperature_raw_dir 'NOAA_Result' filesep names{k} '.mat'] );
end

times = NOAA_global_annual(:,1);
globe = NOAA_global_annual(:,2);
land = NOAA_land_annual(:,2);

month_times = NOAA_global_monthly(:,1);
month_globe = NOAA_global_monthly(:,2);
month_land = NOAA_land_monthly(:,2);
