function updateNOAAData()
% Reads raw NOAA files and updates the MAT files

temperatureGlobals;

names = {'global_monthly', 'land_monthly'};

for k = 1:length(names)

    fid = fopen([temperature_raw_dir filesep ...
        'NOAA_Result' filesep names{k} '.txt'],'r');

    temp = [];
    
    while ~feof(fid)
       A = fgetl(fid);
       A = strrep(A,'-999.0000','NaN');
       B = sscanf(A,'%f')';
       if length(B) == 3
            temp(end+1,:) = [B(1) + B(2)/12 - 1/24, B(3)];
       end
    end

    eval(['NOAA_' names{k} ' = temp;']);
    save([temperature_raw_dir filesep ...
        'NOAA_Result' filesep names{k} '.mat'], ['NOAA_' names{k}]);

    fclose(fid);
end


names = {'global_annual','land_annual'};

for k = 1:length(names)

    fid = fopen([temperature_raw_dir filesep ...
        'NOAA_Result' filesep names{k} '.txt'],'r');

    temp = [];
    
    while ~feof(fid)
       A = fgetl(fid);
       A = strrep(A,'-999.0000','NaN');
       B = sscanf(A,'%f')';
       if length(B) == 2
            temp(end+1,:) = [B(1), B(2)];
       end
    end


    eval(['NOAA_' names{k} ' = temp;']);
    save([temperature_raw_dir filesep ...
        'NOAA_Result' filesep names{k} '.mat'], ['NOAA_' names{k}]);

    fclose(fid);
end
