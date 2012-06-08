function reg = getRegistrationStructure()

temperatureGlobals;

try
    A = load( [temperature_data_dir psep 'Registered Data Sets' psep ...
        'Registration Records' psep 'registry.mat' ] );
    reg = A.reg;
catch
    reg = dictionary();
    warning( 'No registration records found' );
end
    