function updateGISSData()
% Reads raw GISS files and updates the MAT files

temperatureGlobals;

names = {'global_annual','global_land','usa_annual'};

for k = 1:length(names)

    fid = fopen([temperature_raw_dir filesep ...
        'GISTEMP' filesep names{k} '.txt'],'r');

    temp = [];

    while ~feof(fid)
       A = fgetl(fid);
       A = strrep(A,'*','NaN');
       B = sscanf(A,'%f')';
       if length(B) == 3
           if ~isnan(B(2))
               temp(end+1,:) = B;
           end
       end
    end

    eval(['GISTEMP_' names{k} ' = temp;']);
    save([temperature_raw_dir filesep ...
        'GISTEMP' filesep names{k} '.mat'], ['GISTEMP_' names{k}]);
    
    fclose(fid);
end

names = {'global_monthly', 'land_monthly'};

for k = 1:length(names)
    fid = fopen([temperature_raw_dir filesep ...
        'GISTEMP' filesep names{k} '.txt'],'r');

    temp = [];
    B = [];

    while ~feof(fid)
        A = fgetl(fid);
        if length(A) < 4
            continue;
        end
        yr = str2num(A(1:4));
        if ~isempty(yr)
            for j = 1:12
                val = str2num(strtrim(A((7:11)+(j-1)*5)));
                if isempty(val)
                    val = NaN;
                end
                B(j) = val;
            end
            temp(end+1,:) = [yr, B];
        end
    end
    fclose(fid);

    temp2 = [];
    for n = 1:length(temp(:,1))
        for j = 1:12
            temp2(end+1,:) = [temp(n,1) + j/12 - 1/24, temp(n,j+1)/100];
        end
    end

    eval(['GISTEMP_' names{k} ' = temp2;']);
    save([temperature_raw_dir filesep ...
        'GISTEMP' filesep names{k} '.mat'], ['GISTEMP_' names{k}] );
end