%Startup script to be run before working with Temperature Study files

temperatureGlobals

cd( [temperature_software_dir psep 'Dataset Core Functions' psep 'Misc Core Functions' ])

P = genPath2(temperature_software_dir);
path(P, path);

path(temperature_data_dir, path);
cd(temperature_scratch_dir);

if exist( 'matlabpool', 'file' )
    sz = matlabpool('size');
    if sz == 0 
        matlabpool open
    end
end