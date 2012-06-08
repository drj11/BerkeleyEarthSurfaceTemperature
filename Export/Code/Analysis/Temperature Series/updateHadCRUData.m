function updateHadCRUData()
% Reads raw HadCRU files and updates the MAT files

temperatureGlobals;

names = {'global_monthly','global_land_monthly'};
names2 = {'global_annual','global_land_annual'};

for k = 1:length(names)

    fid = fopen([temperature_raw_dir filesep ...
        'HadCRU_Result' filesep names{k} '.txt'],'r');

    temp = [];
    temp2 = [];
    
    while ~feof(fid)
       A = fgetl(fid);
       A = strrep(A,'0.000','NaN');
       B = sscanf(A,'%f')';
       if length(B) == 14
           good = 1;
           for j = 1:12
               if ~isnan(B(j+1))                   
                   temp(end+1,:) = [B(1) + j/12 - 1/24, B(j+1)];
               else
                   good = 0;
               end
           end

           if good
               temp2(end+1,:) = [B(1), B(end)];
           end
       end
    end

    eval(['HadCRU_' names{k} ' = temp;']);
    save([temperature_raw_dir filesep ...
        'HadCRU_Result' filesep names{k} '.mat'], ['HadCRU_' names{k}]);

    eval(['HadCRU_' names2{k} ' = temp2;']);
    save([temperature_raw_dir filesep ...
        'HadCRU_Result' filesep names2{k} '.mat'], ['HadCRU_' names2{k}]);

    fclose(fid);
end