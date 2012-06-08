function [times, globe, land, month_times, month_globe, month_land] = getGISSData()
% Load GISS temperature series

temperatureGlobals;
updateGISSData;

names = {'global_annual', 'global_land', 'global_monthly', 'land_monthly'};
for k = 1:length(names)
    load( [temperature_raw_dir 'GISTEMP' filesep names{k} '.mat'] );
end

times = GISTEMP_global_annual(:,1);
globe = GISTEMP_global_annual(:,2);
land = GISTEMP_global_land(:,2);

month_times = GISTEMP_global_monthly(:,1);
month_globe = GISTEMP_global_monthly(:,2);
month_land = GISTEMP_land_monthly(:,2);