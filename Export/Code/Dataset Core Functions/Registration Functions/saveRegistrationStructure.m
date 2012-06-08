function saveRegistrationStructure( reg )

temperatureGlobals;

save( [temperature_data_dir psep 'Registered Data Sets' psep ...
    'Registration Records' psep 'registry.mat' ], 'reg' );
